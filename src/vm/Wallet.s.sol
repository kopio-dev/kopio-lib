// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {mAddr, mPk, mvm} from "./MinVm.s.sol";

string constant testMnemonic = "error burger code";

contract Wallet {
    string private __mEnv = "MNEMONIC_DEVNET";

    modifier mnemonic(string memory _env) {
        __mEnv = _env;
        _;
    }

    /// @param _env name of the env variable, default is MNEMONIC_DEVNET
    function useMnemonic(string memory _env) internal {
        __mEnv = _env;
    }

    /// @param _mIdx mnemonic index
    function getPk(uint32 _mIdx) internal view returns (uint256) {
        return mPk(__mEnv, _mIdx);
    }

    /// @param _mIdx mnemonic index
    function getAddr(uint32 _mIdx) internal returns (address) {
        return mAddr(__mEnv, _mIdx);
    }

    /// @param _pkEnv name of the env variable
    function getAddr(string memory _pkEnv) internal returns (address) {
        return mvm.rememberKey(mvm.envOr(_pkEnv, 0));
    }

    function getEnv(
        string memory _envKey,
        string memory _defaultKey
    ) internal view returns (string memory) {
        return mvm.envOr(_envKey, mvm.envString(_defaultKey));
    }
}
