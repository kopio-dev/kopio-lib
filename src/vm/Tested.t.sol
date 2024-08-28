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

    modifier hoaxMake(string memory _label) {
        address who = makeHoax(_label);
        vm.startPrank(who, who);
        _;
        VmCaller.clear();
    }

    modifier rehoaxed(
        address who,
        address token,
        uint256 amount
    ) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        hoaxed(who, token, amount);
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
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

    modifier remakeHoax(string memory _label) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        makeHoax(_label);
        _;

        VmCaller.clear();
        _m.restore(_s, _o);
    }

    function prank(address _sno, string memory _label) internal {
        vm.label(_sno, _label);
        prank(_sno, _sno);
    }

    function prank(string memory _pkEnv, string memory _label) internal {
        prank(getAddr(_pkEnv), _label);
    }

    function prank(uint32 _mIdx, string memory _label) internal {
        prank(getAddr(_mIdx), _label);
    }

    function hoaxed(address who) internal returns (address payable) {
        deal(who, 420.69 ether);
        prank(who, who);
        return payable(who);
    }

    function hoaxed(string memory _pkEnv) internal returns (address payable) {
        return hoaxed(getAddr(_pkEnv));
    }

    function hoaxed(uint32 idx) internal returns (address payable) {
        return hoaxed(getAddr(idx));
    }

    function hoaxed(
        address who,
        address token,
        uint256 amount,
        address spender
    ) internal virtual returns (address payable addr_) {
        deal(token, addr_ = hoaxed(who), amount);
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
        string memory _pkEnv,
        address token,
        uint256 amount
    ) internal virtual returns (address payable) {
        return hoaxed(getAddr(_pkEnv), token, amount);
    }

    /// @notice Pranks with a new account derived from label with ether (and the label).
    function makeKeyedHoax(
        string memory _label
    ) internal returns (Account memory who) {
        hoaxed((who = makeAccount(_label)).addr);
    }
    function makeHoax(string memory _label) internal returns (address payable) {
        return hoaxed(makePayable(_label));
    }

    function makeHoax(
        string memory _label,
        address tAddr,
        uint256 amt
    ) internal returns (address payable) {
        return hoaxed(makePayable(_label), tAddr, amt);
    }

    function make(
        string memory _label,
        address tAddr,
        uint256 amt
    ) internal returns (address payable addr) {
        deal(tAddr, (addr = makePayable(_label)), amt);
    }

    function make(
        string memory _label,
        address tAddr,
        uint256 amt,
        address spender
    ) internal returns (address payable addr) {
        deal(tAddr, (addr = makePayable(_label)), amt, spender);
    }

    function deal(
        address tAddr,
        address to,
        uint256 amt,
        address spender
    ) internal virtual returns (IERC20) {
        deal(tAddr, to, amt);
        allowMax(tAddr, to, spender);
        return Tokens.I20(tAddr);
    }
}
