// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Utils} from "./Libs.sol";
import {Permit} from "./Permit.sol";
import {IERC20Permit, IERC20} from "../token/IERC20Permit.sol";
import {mvm, msgSender} from "../vm/MinVm.s.sol";

library Tokens {
    using Tokens for *;
    using Permit for IERC20Permit;
    using Utils for *;

    function dec(address tAddr) internal view returns (uint8) {
        return dec(tAddr.I20());
    }

    function dec(IERC20 token) internal view returns (uint8) {
        return token.decimals();
    }

    function one(address tAddr) internal view returns (uint256) {
        return one(tAddr.I20());
    }

    function one(IERC20 token) internal view returns (uint256) {
        return 1.toDec(0, token.decimals());
    }

    function toWad(uint256 amt, address tAddr) internal view returns (uint256) {
        return amt.toWad(tAddr.I20());
    }

    function toWad(uint256 amt, IERC20 token) internal view returns (uint256) {
        return amt.toWad(token.decimals());
    }

    function fromWad(
        uint256 amt,
        address tAddr
    ) internal view returns (uint256) {
        return amt.fromWad(tAddr.I20());
    }

    function fromWad(
        uint256 amt,
        IERC20 token
    ) internal view returns (uint256) {
        return amt.fromWad(token.decimals());
    }

    function toDec(
        uint256 amt,
        address tAddr,
        uint8 to
    ) internal view returns (uint256) {
        return toDec(amt, tAddr.I20(), to);
    }

    function toDec(
        uint256 amt,
        IERC20 token,
        uint8 to
    ) internal view returns (uint256) {
        return amt.toDec(token.decimals(), to);
    }

    function toDec(
        uint256 amt,
        address from,
        address to
    ) internal view returns (uint256) {
        return amt.toDec(from.I20(), to.I20());
    }

    function toDec(
        uint256 amt,
        IERC20 from,
        address to
    ) internal view returns (uint256) {
        return amt.toDec(from, to.I20());
    }

    function toDec(
        uint256 amt,
        IERC20 from,
        IERC20 to
    ) internal view returns (uint256) {
        return amt.toDec(from.decimals(), to.decimals());
    }

    function allowMax(
        address tAddr,
        address spender
    ) internal returns (IERC20) {
        return allowMax(tAddr.I20(), spender);
    }

    function allowMax(IERC20 token, address spender) internal returns (IERC20) {
        if (token.allowance(msgSender(), spender) == 0) {
            token.approve(spender, type(uint256).max);
        }
        return token;
    }

    function allowMax(
        address owner,
        address token,
        address spender
    ) internal returns (address payable) {
        return allowMax(owner, token.I20(), spender);
    }

    function allowMax(
        address owner,
        IERC20 token,
        address spender
    ) internal returns (address payable owner_) {
        allowMax(token, spender);
        return payable(owner);
    }

    function I20(address token) internal pure returns (IERC20) {
        return IERC20(token);
    }
    function P20(address token) internal pure returns (IERC20Permit) {
        return IERC20Permit(token);
    }

    function bal(
        address account,
        address token
    ) internal view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }

    function sendBal(
        address from,
        address token,
        address to
    ) internal returns (address payable from_) {
        sendBalance(from, token.I20(), to);
        return payable(from);
    }

    function sendBalance(
        address from,
        address token,
        address to
    ) internal returns (uint256 amount) {
        return sendBalance(from, token.I20(), to);
    }

    function sendBalance(
        address from,
        IERC20 token,
        address to
    ) internal returns (uint256 amount) {
        token.transfer(to, (amount = token.balanceOf(from)));
    }

    function getPermit(
        IERC20 token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        return getPermit(address(token), owner, spender, amount, deadline);
    }

    function getPermit(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        return
            mvm.sign(
                owner,
                token.P20().getPermitHash(owner, spender, amount, deadline)
            );
    }
    function getPermit(
        address token,
        address owner,
        address spender,
        uint256 amount
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        return
            mvm.sign(
                owner,
                token.P20().getPermitHash(owner, spender, amount, 100000000000)
            );
    }
}
