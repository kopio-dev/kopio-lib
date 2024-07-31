// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Auth, Authorization} from "./Authorization.sol";

abstract contract AuthorizationFull is Authorization {
    using Auth for bytes32;
    using Auth for address;

    modifier authHeld(bytes32 role, uint256 age) {
        Auth.ensure(msg.sender, role, block.timestamp - age);
        _;
    }

    modifier authOr(bytes32 a, bytes32 b) {
        if (!Auth.hasRole(msg.sender, a)) Auth.ensure(msg.sender, b);
        _;
    }

    modifier authIf(bool val, bytes32 role) {
        if (val) Auth.ensure(msg.sender, role);
        _;
    }

    modifier authAdmin(bytes32 role) {
        Auth.ensureAdmin(msg.sender, role);
        _;
    }

    function hasRole(
        address user,
        bytes32 role
    ) public view virtual returns (bool) {
        return hasRole(user, role, block.timestamp);
    }

    function isRoleAdmin(
        address user,
        bytes32 role
    ) public view virtual returns (bool) {
        return Auth.isAdmin(user, role);
    }

    function hasRole(address user, address addr) public view returns (bool) {
        return hasRole(user, addr, block.timestamp);
    }

    function hasRole(
        address user,
        address addr,
        uint256 at
    ) public view returns (bool) {
        return Auth.hasRole(user, addr, at);
    }

    function roleValidFrom(
        address user,
        bytes32 role
    ) public view virtual returns (uint256) {
        return Auth.get(user, role);
    }

    function hasPendingRole(
        address user,
        bytes32 role
    ) public view virtual returns (bool) {
        return Auth.pendingRole(user, role).at != 0;
    }

    function pendingRole(
        address user,
        bytes32 role
    ) public view virtual returns (Auth.Transfer memory) {
        return Auth.pendingRole(user, role);
    }

    function grantRole(
        address user,
        bytes32 role
    ) public virtual returns (uint256) {
        return grantRole(user, role, block.timestamp);
    }

    function grantRole(
        address user,
        address addr
    ) public virtual returns (uint256) {
        return grantRole(user, addr, block.timestamp);
    }

    function grantRole(
        address user,
        address addr,
        uint256 at
    ) public virtual returns (uint256) {
        return Auth.grant(user, addr, at);
    }

    function transferRole(
        bytes32 role,
        address from,
        address to,
        uint256 at
    ) public virtual {
        Auth.transferRole(role, from, to, at);
    }

    function transferRole(
        address addr,
        address from,
        address to,
        uint256 at
    ) public virtual {
        Auth.transferAddr(addr, from, to, at);
    }

    function getRole(address addr) public view returns (Auth.Role memory) {
        return Auth.info(addr);
    }

    function getRole(bytes32 role) public view returns (Auth.Role memory) {
        return Auth.info(role);
    }

    function totalRoles() public view returns (uint256) {
        return Auth.totalRoles();
    }

    function setRoleAdmin(bytes32 role, bytes32 parent) public virtual {
        Auth.setParent(role, parent);
    }

    function setRoleValidFrom(bytes32 role, uint256 timestamp) public virtual {
        Auth.setRoleValidFrom(role, timestamp);
    }

    function setRoleLimit(bytes32 role, uint256 max) public virtual {
        Auth.setLimit(role, max);
    }

    function authorize(address user, address role) public view {
        authorize(user, role, block.timestamp);
    }

    function authorize(address user, address addr, uint256 at) public view {
        Auth.ensure(user, addr, at);
    }

    function owner() public virtual returns (address) {
        return Auth.owner();
    }

    function transferOwnership(address to) public virtual {
        (address prev, address next) = Auth.setOwner(to);
        emit Auth.OwnershipTransferred(prev, next);
    }
}
