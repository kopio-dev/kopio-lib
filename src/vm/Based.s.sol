// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Scripted} from "./Scripted.s.sol";
import {PLog} from "./PLog.s.sol";
import {PythScript} from "../vm-ffi/PythScript.s.sol";

abstract contract Based is PythScript, Scripted {
    string internal defaultRPC = "RPC_ARBITRUM_ALCHEMY";
    address internal sender;

    modifier based(string memory _mnemonic, string memory _network) {
        base(_mnemonic, _network);
        _;
    }
    modifier forked(string memory _network, uint256 _blockNr) {
        base(_network, _blockNr);
        _;
    }

    function base(
        string memory _mnemonic,
        string memory _network,
        uint256 _blockNr
    ) internal returns (uint256 forkId) {
        PLog.clg(
            "***************************************************************"
        );
        base(_mnemonic);
        forkId = createSelectFork(_network, _blockNr);
        PLog.clg(
            "***************************************************************\n"
        );
    }

    function base(
        string memory _mnemonic,
        string memory _network
    ) internal returns (uint256 forkId) {
        forkId = base(_mnemonic, _network, 0);
    }

    function base(string memory _mnemonic) internal {
        useMnemonic(_mnemonic);
        sender = getAddr(0);
        PLog.clg(sender, "sender:");
    }

    function base(
        string memory _network,
        uint256 _blockNr
    ) internal returns (uint256 forkId) {
        forkId = createSelectFork(_network, _blockNr);
    }

    function createSelectFork(string memory _env) internal returns (uint256) {
        return createSelectFork(_env, 0);
    }

    function createSelectFork(
        string memory _network,
        uint256 _blockNr
    ) internal returns (uint256 forkId_) {
        string memory rpc;
        try vm.rpcUrl(_network) returns (string memory url) {
            rpc = url;
        } catch {
            rpc = getEnv(_network, defaultRPC);
        }
        forkId_ = _blockNr != 0
            ? vm.createSelectFork(rpc, _blockNr)
            : vm.createSelectFork(rpc);

        PLog.clg(
            "rpc:",
            string.concat(
                vm.rpcUrl(rpc),
                " (",
                vm.toString(block.chainid),
                "@",
                vm.toString(_blockNr),
                ", ",
                vm.toString(((getTime() - block.timestamp) / 60)),
                "m ago)"
            )
        );
    }

    function syncTime() internal {
        vm.warp(getTime());
    }
}
