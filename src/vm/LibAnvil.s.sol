// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PLog} from "./PLog.s.sol";
import {IMinVm, VmHelp, VmCaller, mvm} from "./VmLibs.s.sol";

// solhint-disable

library LibAnvil {
    using PLog for *;

    modifier noCallers() {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        _;
        VmCaller.restore(_m, _s, _o);
    }

    function setStorage(
        address account,
        bytes32 slot,
        bytes32 value
    ) internal noCallers {
        mvm.rpc(
            "anvil_setStorageAt",
            string.concat(
                '["',
                mvm.toString(account),
                '","',
                mvm.toString(slot),
                '","',
                mvm.toString(value),
                '"]'
            )
        );
        mine();
    }

    function mine() internal noCallers {
        uint256 blockNr = block.number;

        mvm.rpc("evm_mine", "[]");
        mvm.createSelectFork("localhost", blockNr + 1);
    }

    function syncTime(uint256 time) internal noCallers {
        uint256 current = time != 0 ? time : VmHelp.getTime();
        mvm.rpc(
            "evm_setNextBlockTimestamp",
            string.concat("[", mvm.toString(current), "]")
        );
        mine();
    }
}
