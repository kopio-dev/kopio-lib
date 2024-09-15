// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Scripted} from "./Scripted.s.sol";
import {PLog} from "./PLog.s.sol";
import {PythScript} from "../vm-ffi/PythScript.s.sol";
import {File} from "./Files.s.sol";

abstract contract Based is PythScript, Scripted {
    File internal _file;

    modifier useFile(string memory _loc) {
        _file = fileAt(_loc);
        _;
    }

    modifier usePythSync() {
        updatePythSync();
        _;
    }

    function updatePythSync() internal {
        syncTime();
        updatePyth();
    }

    modifier forked(string memory _network, uint256 _blockNr) {
        base(_network, _blockNr);
        _;
    }

    modifier highlight() {
        PLog.clg(
            "***************************************************************"
        );
        _;
        PLog.clg(
            "***************************************************************\n"
        );
    }

    function base(
        string memory _mnemonic,
        string memory _network,
        uint256 _blockNr
    ) internal highlight returns (uint256 forkId) {
        base(_mnemonic);
        forkId = createSelectFork(_network, _blockNr);
    }

    function base(
        string memory _mnemonic,
        string memory _network
    ) internal returns (uint256 forkId) {
        forkId = base(_mnemonic, _network, 0);
    }

    function base(
        string[2] memory mnemonic_pk,
        string memory _network,
        uint256 _blockNr
    ) internal returns (uint256 forkId) {
        base(mnemonic_pk);
        forkId = createSelectFork(_network, _blockNr);
    }

    function base(string memory _mnemonic) internal {
        useMnemonic(_mnemonic);
        if (sender == address(0)) sender = getAddr(0);
        PLog.clg(sender, "sender:");
    }

    function base(string[2] memory mnemonic_pk) internal {
        useMnemonic(mnemonic_pk[0]);
        sender = getAddr(mnemonic_pk[1]);
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
}
