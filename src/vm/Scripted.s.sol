// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Wallet} from "./Wallet.s.sol";
import {VmCaller, IMinVm} from "./VmLibs.s.sol";
import {Script} from "forge-std/Script.sol";
import {__revert} from "../utils/Funcs.sol";

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
    modifier reclearCallers() {
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
    function broadcastWith(uint32 _mIdx) internal {
        VmCaller.clear();
        vm.startBroadcast(getAddr(_mIdx));
    }

    function broadcastWith(address _addr) internal {
        VmCaller.clear();
        vm.startBroadcast(_addr);
    }

    function broadcastWith(string memory _pkEnv) internal {
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

    function _revert(bytes memory _d) internal pure {
        __revert(_d);
    }

    function getTime() internal returns (uint256) {
        return vm.unixTime() / 1000;
    }
}
