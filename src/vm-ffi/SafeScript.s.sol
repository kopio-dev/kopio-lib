// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {MultisendAddr} from "./Multisends.s.sol";
import {mvm, execFFI, getFFIPath} from "../vm/MinVm.s.sol";
import {Revert} from "../utils/Funcs.sol";
import {Utils} from "../utils/Libs.sol";
import {PLog} from "../vm/PLog.s.sol";

// solhint-disable

contract SafeScript is MultisendAddr {
    using PLog for *;
    using Utils for *;
    string private _SAFE_FFI_SCRIPT;

    enum Operation {
        CALL,
        DELEGATECALL
    }

    struct Payload {
        address to;
        uint256 value;
        bytes data;
    }

    struct Batch {
        address to;
        uint256 value;
        bytes data;
        Operation operation;
        uint256 safeTxGas;
        uint256 baseGas;
        uint256 gasPrice;
        address gasToken;
        address refundReceiver;
        uint256 nonce;
        bytes32 txHash;
        bytes signature;
    }

    address immutable MULTI_SEND_ADDRESS;
    address immutable SAFE_ADDRESS;
    uint256 immutable CHAIN_ID;
    string NETWORK;

    constructor() {
        _SAFE_FFI_SCRIPT = getFFIPath("ffi-safe.ts");
        NETWORK = mvm.envString("SAFE_NETWORK");
        CHAIN_ID = mvm.envUint("SAFE_CHAIN_ID");
        SAFE_ADDRESS = mvm.envAddress("SAFE_ADDRESS");
        MULTI_SEND_ADDRESS = _multisend[CHAIN_ID];
        require(
            SAFE_ADDRESS != address(0),
            "SAFE_ADDRESS not set, chain: ".cc(mvm.toString(CHAIN_ID))
        );
        require(
            MULTI_SEND_ADDRESS != address(0),
            "MULTI_SEND_ADDRESS not set, chain:".cc(mvm.toString(CHAIN_ID))
        );
    }

    bytes32 constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
    bytes32 constant SAFE_TX_TYPEHASH =
        0xbb8310d486368db6bd6f849402fdd73ad53d316b5a4b2644ad6efe0f941286d8;

    bytes[] transactions;
    string[] private argsFFI;

    function sendBatch(string memory broadcastId) public {
        sendBatch(broadcastId, 0);
    }

    function sendBatch(string memory broadcastId, uint256 nonce) public {
        (, string memory fileName) = simulateAndSign(broadcastId, nonce);
        proposeBatch(fileName);
    }

    function simulateAndSign(
        string memory broadcastId,
        uint256 nonce
    ) public returns (bytes32 safeTxHash, string memory fileName) {
        (
            bytes32 txHash,
            string memory file,
            bytes memory sig,
            address signer
        ) = signBatch(simulate(broadcastId, nonce));
        "Hash:".clg(mvm.toString(txHash));
        "Signer:".clg(mvm.toString(signer));
        "Signature:".clg(mvm.toString(sig));
        "Output File:".clg(file);
        return (txHash, file);
    }

    function simulate(
        string memory broadcastId,
        uint256 nonce
    ) public returns (Batch memory batch) {
        mvm.createSelectFork(NETWORK);
        Payloads memory data = getPayloads(broadcastId, nonce);
        printPayloads(data);
        for (uint256 i; i < data.payloads.length; ++i) {
            require(
                !data.extras[i].transactionType.equals("CREATE"),
                "Only CALL transactions are supported"
            );
        }

        batch = _simulate(data);
        writeOutput(broadcastId, batch, data.payloads);
    }

    // Encodes the stored encoded transactions into a single Multisend transaction
    function createBatch(
        Payloads memory data
    ) private view returns (Batch memory batch) {
        batch.to = MULTI_SEND_ADDRESS;
        batch.value = 0;
        batch.operation = Operation.DELEGATECALL;

        bytes memory calls;
        for (uint256 i; i < data.payloads.length; ++i) {
            calls = bytes.concat(
                calls,
                abi.encodePacked(
                    Operation.CALL,
                    data.payloads[i].to,
                    data.payloads[i].value,
                    data.payloads[i].data.length,
                    data.payloads[i].data
                )
            );
        }

        batch.data = abi.encodeWithSignature("multiSend(bytes)", calls);
        batch.nonce = data.safeNonce;
        batch.txHash = getSafeTxHash(batch);
    }

    function _simulate(
        Payloads memory payloads
    ) private returns (Batch memory batch) {
        batch = createBatch(payloads);
        "Simulating TX in ".clg(NETWORK.cc(" (", block.chainid.str(), ")"));
        "Hash: ".clg(mvm.toString(batch.txHash));
        mvm.prank(SAFE_ADDRESS);
        (bool success, bytes memory returnData) = SAFE_ADDRESS.call(
            abi.encodeWithSignature(
                "simulateAndRevert(address,bytes)",
                batch.to,
                batch.data
            )
        );
        if (!success) {
            (bool successRevert, bytes memory successReturnData) = abi.decode(
                returnData,
                (bool, bytes)
            );
            if (!successRevert) {
                "Simulation fail: ".clg(mvm.toString(successReturnData));
                Revert(successReturnData);
            }
            if (successReturnData.length == 0) {
                "Simulation success.".clg();
            } else {
                "Simulation success:".clg(mvm.toString(successReturnData));
            }
        }
    }

    // Computes the EIP712 hash of a Safe transaction.
    // Look at https://github.com/safe-global/safe-eth-py/blob/174053920e0717cc9924405e524012c5f953cd8f/gnosis/safe/safe_tx.py#L186
    // and https://github.com/safe-global/safe-eth-py/blob/master/gnosis/eth/eip712/__init__.py
    function getSafeTxHash(Batch memory batch) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    hex"1901",
                    keccak256(
                        abi.encode(
                            DOMAIN_SEPARATOR_TYPEHASH,
                            CHAIN_ID,
                            SAFE_ADDRESS
                        )
                    ),
                    keccak256(
                        abi.encode(
                            SAFE_TX_TYPEHASH,
                            batch.to,
                            batch.value,
                            keccak256(batch.data),
                            batch.operation,
                            batch.safeTxGas,
                            batch.baseGas,
                            batch.gasPrice,
                            batch.gasToken,
                            batch.refundReceiver,
                            batch.nonce
                        )
                    )
                )
            );
    }

    function getSafeTxFromSafe(
        Batch memory batch
    ) internal view returns (bytes32) {
        (bool success, bytes memory returnData) = SAFE_ADDRESS.staticcall(
            abi.encodeWithSignature(
                "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)",
                batch.to,
                batch.value,
                batch.data,
                uint8(batch.operation),
                batch.safeTxGas,
                batch.baseGas,
                batch.gasPrice,
                batch.gasToken,
                batch.refundReceiver,
                batch.nonce
            )
        );
        if (!success) Revert(returnData);

        return abi.decode(returnData, (bytes32));
    }

    function getPayloads(
        string memory broadcastId,
        uint256 nonce
    ) public returns (Payloads memory) {
        argsFFI = [
            "bun",
            _SAFE_FFI_SCRIPT,
            "getSafePayloads",
            broadcastId,
            mvm.toString(block.chainid),
            mvm.toString(SAFE_ADDRESS),
            mvm.toString(nonce)
        ];
        return abi.decode(execFFI(argsFFI), (Payloads));
    }

    function signBatch(
        Batch memory batch
    )
        internal
        returns (
            bytes32 txHash,
            string memory fileName,
            bytes memory signature,
            address signer
        )
    {
        argsFFI = [
            "bun",
            _SAFE_FFI_SCRIPT,
            "signBatch",
            mvm.toString(SAFE_ADDRESS),
            mvm.toString(CHAIN_ID),
            mvm.toString(abi.encode(batch))
        ];

        (fileName, signature, signer) = abi.decode(
            execFFI(argsFFI),
            (string, bytes, address)
        );
        txHash = batch.txHash;
    }

    function proposeBatch(
        string memory fileName
    ) public returns (string memory response, string memory json) {
        argsFFI = ["bun", _SAFE_FFI_SCRIPT, "proposeBatch", fileName];
        (response, json) = abi.decode(execFFI(argsFFI), (string, string));
        response.clg();
        json.clg();
    }

    function deleteProposal(bytes32 safeTxHash, string memory filename) public {
        deleteTx(safeTxHash);
        (bool success, bytes memory ret) = address(mvm).call(
            abi.encodeWithSignature("removeFile(string)", filename)
        );
        if (!success) Revert(ret);

        "Removed Safe Tx: ".clg(mvm.toString(safeTxHash));
        "Deleted file: ".clg(filename);
    }

    function deleteProposal(bytes32 safeTxHash) public {
        deleteTx(safeTxHash);
        "Removed Safe Tx: ".clg(mvm.toString(safeTxHash));
    }

    function deleteTx(bytes32 txHash) private {
        argsFFI = [
            "bun",
            _SAFE_FFI_SCRIPT,
            "deleteBatch",
            mvm.toString(txHash)
        ];
        execFFI(argsFFI);
    }

    function writeOutput(
        string memory broadcastId,
        Batch memory data,
        Payload[] memory payloads
    ) private {
        string memory path = "temp/batch/";
        string memory fileName = string.concat(
            path,
            broadcastId,
            "-",
            mvm.toString(SAFE_ADDRESS),
            "-",
            mvm.toString(CHAIN_ID),
            ".json"
        );
        if (!mvm.exists(path)) {
            mvm.createDir(path, true);
        }
        string memory out = "values";
        mvm.serializeBytes(out, "id", abi.encode(broadcastId));
        mvm.serializeBytes(out, "batch", abi.encode(data));
        mvm.serializeAddress(out, "multisendAddr", MULTI_SEND_ADDRESS);
        mvm.writeFile(
            fileName,
            mvm.serializeBytes(out, "payloads", abi.encode(payloads))
        );
        "Output File: ".clg(fileName);
    }

    function printPayloads(Payloads memory payloads) public pure {
        for (uint256 i; i < payloads.payloads.length; ++i) {
            Payload memory payload = payloads.payloads[i];
            "to: ".cc(mvm.toString(payload.to)).clg(
                " value: ".cc(mvm.toString(payload.value))
            );
            string
                .concat(
                    "new contracts -> ",
                    mvm.toString(payloads.extras[i].creations.length),
                    "\n  function -> ",
                    payloads.extras[i].func,
                    "\n  args -> ",
                    join(payloads.extras[i].args)
                )
                .clg("\n");
        }
    }

    function join(
        string[] memory arr
    ) private pure returns (string memory result) {
        for (uint256 i; i < arr.length; ++i) {
            uint256 len = bytes(arr[i]).length;
            string memory suffix = i == arr.length - 1 ? "" : ",";

            if (len > 500) {
                result = result.cc("bytes(".cc(mvm.toString(len), ")"), suffix);
            } else {
                result = result.cc(arr[i], suffix);
            }
        }
    }

    struct PayloadExtra {
        string name;
        address contractAddr;
        string transactionType;
        string func;
        string funcSig;
        string[] args;
        address[] creations;
        uint256 gas;
    }

    struct Payloads {
        Payload[] payloads;
        PayloadExtra[] extras;
        uint256 txCount;
        uint256 creationCount;
        uint256 totalGas;
        uint256 safeNonce;
        string safeVersion;
        uint256 timestamp;
        uint256 chainId;
    }

    struct Load {
        SavedBatch batch;
    }

    struct SavedBatch {
        Payload[] payloads;
        Batch batch;
    }
}
