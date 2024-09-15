// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {IMinVm} from "./MinVm.s.sol";
import {Scripted, VmCaller} from "./Scripted.s.sol";
import {IERC20} from "../token/IERC20.sol";
import {Tokens} from "../utils/Tokens.sol";

abstract contract Tested is Test, Scripted {
    using VmCaller for IMinVm.CallerMode;
    address payable user0;
    address payable user1;
    address payable user2;

    address payable bank;

    modifier users(
        address _u0,
        address _u1,
        address _u2
    ) {
        user0 = payable(_u0);
        user1 = payable(_u1);
        user2 = payable(_u2);
        _;
    }

    modifier pranked(address addr) {
        prank(addr);
        _;
        VmCaller.clear();
    }

    modifier prankedById(uint32 mIdx) {
        prank(mIdx);
        _;
        VmCaller.clear();
    }

    modifier prankedByKey(string memory pkEnv) {
        prank(pkEnv);
        _;
        VmCaller.clear();
    }

    modifier hoaxMake(string memory lbl) {
        prank(makeHoax(lbl));
        _;
        VmCaller.clear();
    }

    modifier rehoaxed(
        address who,
        address tkn,
        uint256 amt
    ) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        hoaxed(who, tkn, amt);
        _;
        _m.restore(_s, _o);
    }

    /// @dev clear call modes, prank function body and restore callers after
    modifier repranked(address addr) {
        (IMinVm.CallerMode _m, address _s, address _o) = prank(addr);
        _;
        _m.restore(_s, _o);
    }

    modifier reprankedById(uint32 mIdx) {
        (IMinVm.CallerMode _m, address _s, address _o) = prank(mIdx);
        _;
        _m.restore(_s, _o);
    }

    modifier reprankedByKey(string memory pkEnv) {
        (IMinVm.CallerMode _m, address _s, address _o) = prank(pkEnv);
        _;
        _m.restore(_s, _o);
    }

    modifier remakeHoax(string memory lbl) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        makeHoax(lbl);
        _;

        VmCaller.clear();
        _m.restore(_s, _o);
    }

    /// @notice vm.prank, but clears callers first
    function prank(
        address addr
    ) internal returns (IMinVm.CallerMode, address, address) {
        return prank(addr, addr);
    }

    function prank(
        address _s,
        address _o
    )
        internal
        returns (
            IMinVm.CallerMode prevMode,
            address prevSender,
            address prevOrigin
        )
    {
        (prevMode, prevSender, prevOrigin) = VmCaller.clear();
        vm.startPrank(_s, _o);
    }

    function prank(
        uint32 mIdx
    ) internal returns (IMinVm.CallerMode, address, address) {
        return prank(getAddr(mIdx));
    }

    function prank(
        string memory pkEnv
    ) internal returns (IMinVm.CallerMode, address, address) {
        return prank(getAddr(pkEnv));
    }

    function prank(address addr, string memory lbl) internal {
        vm.label(addr, lbl);
        prank(addr);
    }

    function prank(string memory pkEnv, string memory lbl) internal {
        prank(getAddr(pkEnv), lbl);
    }

    function prank(uint32 mIdx, string memory lbl) internal {
        prank(getAddr(mIdx), lbl);
    }

    function hoaxed(address who) internal returns (address payable) {
        deal(who, 420.69 ether);
        prank(who, who);
        return payable(who);
    }

    function hoaxed(string memory pkEnv) internal returns (address payable) {
        return hoaxed(getAddr(pkEnv));
    }

    function hoaxed(uint32 idx) internal returns (address payable) {
        return hoaxed(getAddr(idx));
    }

    function hoaxed(
        address who,
        address token,
        uint256 amount,
        address spender
    ) internal virtual returns (address payable addr) {
        deal(token, addr = hoaxed(who), amount);
        if (spender != address(0)) allowMax(token, who, spender);
    }

    function hoaxed(
        address who,
        address token,
        uint256 amount
    ) internal virtual returns (address payable) {
        return hoaxed(who, token, amount, address(0));
    }

    function hoaxed(
        uint32 idx,
        address token,
        uint256 amount
    ) internal virtual returns (address payable) {
        return hoaxed(getAddr(idx), token, amount);
    }

    function hoaxed(
        string memory pkEnv,
        address token,
        uint256 amount
    ) internal virtual returns (address payable) {
        return hoaxed(getAddr(pkEnv), token, amount);
    }

    /// @notice Pranks with a new account derived from label with ether (and the label).
    function makeHoaxAccount(
        string memory lbl
    ) internal returns (Account memory acc) {
        hoaxed((acc = makeAccount(lbl)).addr);
    }
    function makeHoax(string memory lbl) internal returns (address payable) {
        return hoaxed(makePayable(lbl));
    }

    function makeHoax(
        string memory lbl,
        address tkn,
        uint256 amt
    ) internal returns (address payable) {
        return hoaxed(makePayable(lbl), tkn, amt);
    }

    function make(
        string memory lbl,
        address tkn,
        uint256 amt
    ) internal returns (address payable addr) {
        deal(tkn, (addr = makePayable(lbl)), amt);
    }

    function make(
        string memory lbl,
        address tkn,
        uint256 amt,
        address spender
    ) internal returns (address payable addr) {
        deal(tkn, (addr = makePayable(lbl)), amt, spender);
    }

    function deal(
        address tkn,
        address to,
        uint256 amt,
        address spender
    ) internal virtual returns (IERC20) {
        deal(tkn, to, amt);
        allowMax(tkn, to, spender);
        return Tokens.I20(tkn);
    }
}
