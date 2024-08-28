// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {IMinVm} from "./MinVm.s.sol";
import {Scripted, VmCaller} from "./Scripted.s.sol";
import {IERC20} from "../token/IERC20.sol";
import {Tokens} from "../utils/Tokens.sol";

abstract contract Tested is Scripted, Test {
    using VmCaller for IMinVm.CallerMode;
    address user0;
    address user1;
    address user2;

    modifier users(
        address _u0,
        address _u1,
        address _u2
    ) {
        user0 = _u0;
        user1 = _u1;
        user2 = _u2;
        _;
    }

    modifier prankedById(uint32 _mIdx) {
        address who = getAddr(_mIdx);
        vm.startPrank(who, who);
        _;
        VmCaller.clear();
    }

    modifier prankedByKey(string memory _pkEnv) {
        address who = getAddr(_pkEnv);
        vm.startPrank(who, who);
        _;
        VmCaller.clear();
    }

    modifier prankedMake(string memory _label) {
        address who = prankMake(_label).addr;
        vm.startPrank(who, who);
        _;
        VmCaller.clear();
    }

    modifier reprankedById(uint32 _mIdx) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        address who = getAddr(_mIdx);
        vm.startPrank(who, who);
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
    }

    modifier reprankedByKey(string memory _pkEnv) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        address who = getAddr(_pkEnv);
        vm.startPrank(who, who);
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
    }

    modifier reprankedByNew(string memory _label) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        prankMake(_label);
        _;

        VmCaller.clear();
        _m.restore(_s, _o);
    }

    function prank(string memory _pkEnv, string memory _label) internal {
        address who = getAddr(_pkEnv);
        vm.label(who, _label);
        prank(who, who);
    }

    function prank(address _sno, string memory _label) internal {
        vm.label(_sno, _label);
        prank(_sno, _sno);
    }

    function prank(uint32 _mIdx, string memory _label) internal {
        address who = getAddr(_mIdx);
        vm.label(who, _label);
        prank(who, who);
    }

    /// @notice Pranks with a new account derived from label with ether (and the label).
    function prankMake(
        string memory _label
    ) internal returns (Account memory who) {
        who = makeAccount(_label);
        vm.deal(who.addr, 420.69 ether);
        vm.label(who.addr, _label);
        prank(who.addr, who.addr);
    }

    function dealMake(
        string memory user,
        address tAddr,
        uint256 amt
    ) internal returns (address addr) {
        deal(tAddr, (addr = makeAddr(user)), amt);
    }

    function dealMake(
        string memory user,
        address tAddr,
        uint256 amt,
        address spender
    ) internal returns (address addr) {
        allowMax(tAddr, (addr = dealMake(user, tAddr, amt)), spender);
    }

    function deal(
        address to,
        address tAddr,
        uint256 amt,
        address spender
    ) internal virtual returns (IERC20) {
        deal(tAddr, to, amt);
        allowMax(tAddr, to, spender);
        return Tokens.I20(tAddr);
    }

    function i20(address tAddr) internal pure virtual returns (IERC20) {
        return Tokens.I20(tAddr);
    }

    function getBal(
        address user,
        address tAddr
    ) internal view virtual returns (uint256) {
        return Tokens.bal(user, tAddr);
    }

    function allowMax(
        address owner,
        address tAddr,
        address spender
    ) internal virtual repranked(owner) returns (address) {
        Tokens.allowMax(tAddr, spender);
        return owner;
    }

    function sendBalance(
        address from,
        address tAddr,
        address to
    ) internal virtual repranked(from) returns (uint256 amt) {
        return Tokens.sendBalance(from, tAddr, to);
    }
}
