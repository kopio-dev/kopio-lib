// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {mAddr, mPk, mvm, pkAddr, envOr} from "./MinVm.s.sol";

string constant testMnemonic = "error burger code";

contract Wallet {
    string private __mEnv = "MNEMONIC_DEVNET";
    string private __pkEnv = "PRIVATE_KEY";
    string internal defaultRPC = "RPC_ARBITRUM_ALCHEMY";

    address internal sender;

    modifier mnemonic(string memory _env) virtual {
        useMnemonic(_env);
        _;
    }

    modifier mnemonicAt(string memory _env, uint32 _idx) virtual {
        useMnemonic(_env, _idx);
        _;
    }

    modifier wallets(string[2] memory _envs) virtual {
        useWallets(_envs);
        _;
    }

    modifier Wallets(string memory _mnemonic, string memory _pk) virtual {
        useWallets([_mnemonic, _pk]);
        _;
    }

    modifier pk(string memory _env) virtual {
        usePk(_env);
        _;
    }

    /// @param _env name of the env variable, default is MNEMONIC_DEVNET
    function useMnemonic(
        string memory _env
    ) internal virtual returns (address) {
        return useMnemonic(_env, 0);
    }

    function useMnemonic(
        string memory _env,
        uint32 _idx
    ) internal virtual returns (address) {
        __mEnv = _env;
        return sender = mAddr(__mEnv, _idx);
    }

    function useMnemonic() internal virtual returns (address) {
        return useMnemonic(__mEnv);
    }

    function useMnemonicAt(uint32 _mIdx) internal virtual returns (address) {
        return useMnemonic(__mEnv, _mIdx);
    }

    /// @param _env name of the env variable, default is PRIVATE_KEY
    function usePk(string memory _env) internal virtual returns (address) {
        __pkEnv = _env;
        return sender = getAddr(__pkEnv);
    }

    function usePk() internal virtual returns (address) {
        return usePk(__pkEnv);
    }

    /// @param _envs use mnemonic + private key, eg. ["MNEMONIC_DEVNET", "PRIVATE_KEY"]
    function useWallets(
        string[2] memory _envs
    ) internal virtual returns (address maddr, address pkaddr) {
        maddr = useMnemonic(_envs[0]);
        pkaddr = usePk(_envs[1]);
    }

    function senderOr(address _sender) internal virtual returns (address) {
        if (sender != address(0)) return sender;
        return (sender = _sender);
    }

    function senderOr(uint32 _mIdx) internal virtual returns (address) {
        return senderOr(getAddr(_mIdx));
    }

    function senderOr(string memory _pkEnv) internal virtual returns (address) {
        return senderOr(getAddr(_pkEnv));
    }

    /// @param _mIdx mnemonic index
    function getPkAt(uint32 _mIdx) internal view virtual returns (uint256) {
        return mPk(__mEnv, _mIdx);
    }

    /// @param _mIdx mnemonic index
    function getAddr(uint32 _mIdx) internal virtual returns (address) {
        return mAddr(__mEnv, _mIdx);
    }

    /// @param _pkEnv name of the env variable
    function getAddr(string memory _pkEnv) internal virtual returns (address) {
        return pkAddr(_pkEnv);
    }

    function getEnv(
        string memory _envKey,
        string memory _defaultKey
    ) internal view virtual returns (string memory) {
        return envOr(_envKey, _defaultKey);
    }

    function getRPC(
        string memory _idOrURL
    ) internal view virtual returns (string memory rpc_) {
        try mvm.rpcUrl(_idOrURL) returns (string memory url) {
            return url;
        } catch {
            return getEnv(_idOrURL, defaultRPC);
        }
    }

    function _setMnemonic(
        string memory _mnemonic
    ) internal virtual returns (address) {
        __mEnv = _mnemonic;
        return mAddr(__mEnv, 0);
    }

    function _setPk(string memory _pk) internal virtual returns (address) {
        __pkEnv = _pk;
        return getAddr(__pkEnv);
    }

    function _setWallets(
        string[2] memory _envs
    ) internal virtual returns (address, address) {
        return _setWallets(_envs[0], _envs[1]);
    }

    function _setWallets(
        string memory _mnemonic,
        string memory _pk
    ) internal virtual returns (address, address) {
        return (_setMnemonic(_mnemonic), _setPk(_pk));
    }
}
