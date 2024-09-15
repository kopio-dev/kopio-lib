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
    bytes4 lastId;
    string[] files;
}

function store() view returns (Store storage s) {
    if (!hasVM()) revert("no hevm");
    assembly {
        s.slot := 0x35b9089429a720996a27ffd842a4c293f759fc6856f1c672c8e2b5040a1eddfe
    }
}

function getSeconds() returns (uint256) {
    return uint256(mvm.unixTime() / 1000);
}

function mPk(string memory _mEnv, uint32 _idx) view returns (uint256) {
    return mvm.deriveKey(mvm.envOr(_mEnv, "error burger code"), _idx);
}

function mAddr(string memory _mEnv, uint32 _idx) returns (address) {
    return mvm.rememberKey(mPk(_mEnv, _idx));
}

function pkAddr(string memory _pkEnv) returns (address) {
    return mvm.rememberKey(mvm.envOr(_pkEnv, 0));
}

function envOr(
    string memory _envKey,
    string memory _fbKey
) view returns (string memory) {
    return mvm.envOr(_envKey, mvm.envString(_fbKey));
}

function getId() returns (bytes4 b) {
    store().lastId = (b = bytes4(bytes32(vmFFI.randomUint())));
}
