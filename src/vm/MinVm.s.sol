// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Base.s.sol";
import {IMinVm} from "./IMinVm.sol";
IMinVm constant mvm = IMinVm(vmAddr);

struct Store {
    bool _failed;
    bool logDisabled;
    string logPrefix;
}

function store() view returns (Store storage s) {
    if (!hasVM()) revert("no hevm");
    assembly {
        s.slot := 0x35b9089429a720996a27ffd842a4c293f759fc6856f1c672c8e2b5040a1eddfe
    }
}

function mPk(string memory _mEnv, uint32 _idx) view returns (uint256) {
    return mvm.deriveKey(mvm.envOr(_mEnv, "error burger code"), _idx);
}

function mAddr(string memory _mEnv, uint32 _idx) returns (address) {
    return mvm.rememberKey(mPk(_mEnv, _idx));
}
