// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Wallet} from "./Wallet.s.sol";
import {getId} from "./MinVm.s.sol";
import {File, VmCaller, IMinVm} from "./VmLibs.s.sol";
import {Script} from "forge-std/Script.sol";
import {Revert} from "../utils/Funcs.sol";
import {IERC20} from "../token/IERC20.sol";
import {Tokens} from "../utils/Tokens.sol";

abstract contract Scripted is Script, Wallet {
    using VmCaller for IMinVm.CallerMode;

    modifier fork(string memory idOrAlias) virtual {
        vm.createSelectFork(idOrAlias);
        _;
    }

    modifier forkId(uint256 _id) {
        vm.selectFork(_id);
        _;
    }

    modifier noCallers() {
        VmCaller.clear();
        _;
    }

    modifier broadcastedById(uint32 mIdx) {
        broadcastWith(mIdx);
        _;
        VmCaller.clear();
    }

    modifier broadcasted(address addr) {
        broadcastWith(addr);
        _;
        VmCaller.clear();
    }

    modifier broadcastedByPk(string memory pkEnv) {
        broadcastWith(pkEnv);
        _;
        VmCaller.clear();
    }

    modifier reuse(
        function(address) returns (IMinVm.CallerMode, address, address) f,
        address addr
    ) virtual {
        (IMinVm.CallerMode _m, address _s, address _o) = f(addr);
        _;
        _m.restore(_s, _o);
    }

    modifier use(
        function(address) returns (IMinVm.CallerMode, address, address) f,
        address addr
    ) virtual {
        f(addr);
        _;
        VmCaller.clear();
    }

    /// @dev clear call modes, broadcast function body and restore callers after
    modifier rebroadcasted(address addr) {
        (IMinVm.CallerMode _m, address _s, address _o) = broadcastWith(addr);
        _;
        _m.restore(_s, _o);
    }

    modifier rebroadcastById(uint32 mIdx) {
        (IMinVm.CallerMode _m, address _s, address _o) = broadcastWith(
            getAddr(mIdx)
        );
        _;
        _m.restore(_s, _o);
    }

    modifier rebroadcastedByKey(string memory pkEnv) {
        (IMinVm.CallerMode _m, address _s, address _o) = broadcastWith(
            getAddr(pkEnv)
        );
        _;
        _m.restore(_s, _o);
    }

    /// @dev func body with no call modes and restore callers after
    modifier restoreCallers() {
        (IMinVm.CallerMode _m, address _s, address _o) = VmCaller.clear();
        _;
        _m.restore(_s, _o);
    }

    function broadcastWith(uint32 mIdx) internal virtual {
        broadcastWith(getAddr(mIdx));
    }

    function broadcastWith(
        address addr
    )
        internal
        virtual
        returns (
            IMinVm.CallerMode prevMode,
            address prevSender,
            address prevOrigin
        )
    {
        (prevMode, prevSender, prevOrigin) = VmCaller.clear();
        vm.startBroadcast(addr);
    }

    function broadcastWith(string memory pkEnv) internal virtual {
        VmCaller.clear();
        vm.startBroadcast(vm.envUint(pkEnv));
    }

    function clearCallers() internal {
        VmCaller.clear();
    }

    function msgSender() internal returns (address payable) {
        return payable(VmCaller.msgSender());
    }

    function vmCallers() internal returns (VmCaller.Values memory) {
        return VmCaller.values();
    }

    function _revert(bytes memory _d) internal pure virtual {
        Revert(_d);
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
    ) internal virtual rebroadcasted(owner) returns (address payable) {
        return payable(Tokens.allowMax(owner, tAddr, spender));
    }

    function sendBal(
        address from,
        address tAddr,
        address to
    ) internal virtual rebroadcasted(from) returns (uint256 amt) {
        return Tokens.sendBalance(from, tAddr, to);
    }

    function getPermit(
        address token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        return Tokens.getPermit(token, owner, spender, amount, deadline);
    }

    function makePayable(
        string memory user
    ) internal returns (address payable) {
        return payable(makeAddr(user));
    }

    function makeKeyed(
        string memory user
    ) internal returns (address payable, uint256) {
        (address a, uint256 k) = makeAddrAndKey(user);
        return (payable(a), k);
    }

    function getNextAddr(address deployer) internal view returns (address) {
        return vm.computeCreateAddress(deployer, vm.getNonce(deployer));
    }
}
