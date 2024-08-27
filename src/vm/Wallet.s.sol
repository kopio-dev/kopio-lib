// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {mAddr, mPk, mvm} from "./MinVm.s.sol";

string constant testMnemonic = "error burger code";

contract Wallet {
    string private __mEnv = "MNEMONIC_DEVNET";
    string private __pkEnv = "PRIVATE_KEY";
    string internal defaultRPC = "RPC_ARBITRUM_ALCHEMY";

    address internal sender;

    modifier mnemonic(string memory _env) {
        useMnemonic(_env);
        _;
    }

    modifier mnemonicAt(string memory _env, uint32 _idx) {
        useMnemonic(_env, _idx);
        _;
    }

    modifier wallets(string[2] memory _envs) {
        useWallets(_envs);
        _;
    }
    modifier Wallets(string memory _mnemonic, string memory _pk) {
        useWallets([_mnemonic, _pk]);
        _;
    }

    modifier pk(string memory _env) {
        __pkEnv = _env;
        _;
    }

    /// @param _env name of the env variable, default is MNEMONIC_DEVNET
    function useMnemonic(string memory _env) internal returns (address) {
        return useMnemonic(_env, 0);
    }

    function useMnemonic(
        string memory _env,
        uint32 _idx
    ) internal returns (address) {
        __mEnv = _env;
        return sender = mAddr(__mEnv, _idx);
    }

    /// @param _envs use mnemonic + private key, eg. ["MNEMONIC_DEVNET", "PRIVATE_KEY"]
    function useWallets(
        string[2] memory _envs
    ) internal returns (address m0Addr, address pkAddr) {
        m0Addr = useMnemonic(_envs[0]);
        pkAddr = usePk(_envs[1]);
    }

    /// @param _env name of the env variable, default is PRIVATE_KEY
    function usePk(string memory _env) internal returns (address) {
        __pkEnv = _env;
        return sender = getAddr(__pkEnv);
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
