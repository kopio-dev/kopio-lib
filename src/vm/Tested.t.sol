// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {IMinVm} from "./MinVm.s.sol";
import {Scripted, VmCaller} from "./Scripted.s.sol";
import {IERC20} from "../token/IERC20.sol";

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
        address tokenAddr,
        uint256 amount
    ) internal returns (address addr) {
        deal(tokenAddr, (addr = makeAddr(user)), amount);
    }

    function dealMake(
        string memory user,
        address tokenAddr,
        uint256 amount,
        address spender
    ) internal returns (address addr) {
        approve20(
            tokenAddr,
            (addr = dealMake(user, tokenAddr, amount)),
            spender
        );
    }

    function deal(
        address to,
        address tokenAddr,
        uint256 amount,
        address spender
    ) internal returns (IERC20) {
        deal(tokenAddr, to, amount);
        return approve20(tokenAddr, to, spender);
    }

    function bal20(
        address account,
        address tokenAddr
    ) internal view returns (uint256) {
        return TUtils.bal20(account, tokenAddr);
    }

    function to20(address tokenAddr) internal pure returns (IERC20) {
        return TUtils.to20(tokenAddr);
    }

    function approve20(
        address tokenAddr,
        address owner,
        address spender
    ) internal returns (IERC20) {
        return TUtils.approve20(tokenAddr, owner, spender);
    }

    function send20(
        address _tokenAddr,
        address _from,
        address _to
    ) internal returns (uint256 toBal) {
        return TUtils.send20(_from, _tokenAddr, _to);
    }
}

library TUtils {
    using TUtils for *;

    modifier repranked(address _addr) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.prank(
            _addr,
            _addr
        );
        _;
        VmCaller.clear();
        VmCaller.restore(_m, _s, _o);
    }

    function approve20(
        address tokenAddr,
        address owner,
        address spender
    ) internal repranked(owner) returns (IERC20 token) {
        (token = tokenAddr.to20()).approve(spender, type(uint256).max);
    }

    function to20(address addr) internal pure returns (IERC20) {
        return IERC20(addr);
    }

    function bal20(
        address account,
        address tokenAddr
    ) internal view returns (uint256) {
        return IERC20(tokenAddr).balanceOf(account);
    }

    function send20(
        address from,
        address tokenAddr,
        address to
    ) internal returns (uint256 toBal) {
        return from.send20(tokenAddr, bal20(from, tokenAddr), to);
    }

    function send20(
        address from,
        address token,
        uint256 amount,
        address to
    ) internal repranked(from) returns (uint256 toBal) {
        token.to20().transfer(to, amount);
        return to.bal20(token);
    }
}
