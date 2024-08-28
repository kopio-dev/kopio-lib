// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Wallet} from "./Wallet.s.sol";
import {getId} from "./MinVm.s.sol";
import {File, VmCaller, IMinVm} from "./VmLibs.s.sol";
import {Script} from "forge-std/Script.sol";
import {__revert} from "../utils/Funcs.sol";
import {IERC20} from "../token/IERC20.sol";
import {Tokens} from "../utils/Tokens.sol";

abstract contract Scripted is Script, Wallet {
    using VmCaller for IMinVm.CallerMode;

    modifier fork(string memory _uoa) virtual {
        vm.createSelectFork(_uoa);
        _;
    }

    modifier forkId(uint256 _id) {
        vm.selectFork(_id);
        _;
    }

    /// @dev clear any callers
    modifier noCallers() {
        VmCaller.clear();
        _;
    }

    modifier broadcastedById(uint32 _mIdx) {
        broadcastWith(_mIdx);
        _;
        VmCaller.clear();
    }

    modifier broadcasted(address _addr) {
        broadcastWith(_addr);
        _;
        VmCaller.clear();
    }

    modifier broadcastedByPk(string memory _pkEnv) {
        broadcastWith(_pkEnv);
        _;
        VmCaller.clear();
    }

    modifier pranked(address _sno) {
        prank(_sno);
        _;
        VmCaller.clear();
    }

    /// @dev clear call modes, broadcast function body and restore callers after
    modifier rebroadcasted(address _addr) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        vm.startBroadcast(_addr);
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
    }

    modifier rebroadcastById(uint32 _mIdx) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        vm.startBroadcast(getAddr(_mIdx));
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
    }

    modifier rebroadcastedByKey(string memory _pkEnv) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();

        vm.startBroadcast(getAddr(_pkEnv));
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
    }

    /// @dev func body with no call modes and restore callers after
    modifier restoreCallers() {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        _;
        _m.restore(_s, _o);
    }

    /// @dev clear call modes, prank function body and restore callers after
    modifier repranked(address _addr) {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        vm.startPrank(_addr, _addr);
        _;
        VmCaller.clear();
        _m.restore(_s, _o);
    }

    /// @dev clear callers and change to broadcasting
    function broadcastWith(uint32 _mIdx) internal virtual {
        VmCaller.clear();
        vm.startBroadcast(getAddr(_mIdx));
    }

    function broadcastWith(address _addr) internal virtual {
        VmCaller.clear();
        vm.startBroadcast(_addr);
    }

    function broadcastWith(string memory _pkEnv) internal virtual {
        VmCaller.clear();
        vm.startBroadcast(vm.envUint(_pkEnv));
    }

    /// @notice vm.prank, but clears callers first
    function prank(address _sno) internal {
        VmCaller.clear();
        vm.startPrank(_sno, _sno);
    }

    function prank(address _s, address _o) internal {
        VmCaller.clear();
        vm.startPrank(_s, _o);
    }

    function prank(uint32 _mIdx) internal {
        address who = getAddr(_mIdx);
        prank(who, who);
    }

    function prank(string memory _pkEnv) internal {
        address who = getAddr(_pkEnv);
        prank(who, who);
    }

    function clearCallers() internal {
        VmCaller.clear();
    }

    function vmSender() internal returns (address) {
        return VmCaller.msgSender();
    }

    function vmCallers() internal returns (VmCaller.Values memory) {
        return VmCaller.values();
    }

    function _revert(bytes memory _d) internal pure virtual {
        __revert(_d);
    }

    function getTime() internal virtual returns (uint256) {
        return vm.unixTime() / 1000;
    }

    function syncTime() internal {
        vm.warp(getTime());
    }

    function getRandomId() internal virtual returns (bytes4) {
        return getId();
    }

    function fileAt(string memory _loc) internal pure returns (File memory) {
        return File(_loc);
    }

    function write(
        string memory _loc,
        bytes memory data
    ) internal virtual returns (File memory) {
        return File(_loc).write(data);
    }

    function write(bytes memory data) internal virtual returns (File memory) {
        return File(vm.toString(getId())).write(data);
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
    ) internal virtual rebroadcasted(owner) returns (address) {
        return Tokens.allowMax(owner, tAddr, spender);
    }

    function sendBal(
        address from,
        address tAddr,
        address to
    ) internal virtual rebroadcasted(from) returns (uint256 amt) {
        return Tokens.sendBalance(from, tAddr, to);
    }
}
