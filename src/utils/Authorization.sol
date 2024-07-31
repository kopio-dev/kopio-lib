// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Auth} from "./Auth.sol";

abstract contract Authorization {
    using Auth for bytes32;
    using Auth for address;

    function initAuth(address admin) internal returns (Auth.State storage) {
        return Auth.initialize(admin);
    }

    modifier sudo() {
        Auth.ensure(msg.sender, Auth.SUDO);
        _;
    }

    modifier guard(address addr) {
        Auth.ensure(msg.sender, addr);
        _;
    }

    modifier auth(bytes32 role) {
        Auth.ensure(msg.sender, role);
        _;
    }

    function grantRole(
        address user,
        bytes32 role,
        uint256 at
    ) public virtual returns (uint256) {
        return Auth.grant(user, role, at);
    }

    function claimRole(
        bytes32 role
    ) public virtual returns (address from, address to) {
        return Auth.claimRole(role);
    }

    function revokeRole(
        address user,
        bytes32 role
    ) public virtual returns (uint256 count) {
        return Auth.revoke(user, role);
    }

    function hasRole(
        address user,
        bytes32 role,
        uint256 at
    ) public view virtual returns (bool) {
        return Auth.hasRole(user, role, at);
    }

    function authorize(address user, bytes32 role) public view virtual {
        authorize(user, role, block.timestamp);
    }

    function authorize(
        address user,
        bytes32 role,
        uint256 at
    ) public view virtual {
        Auth.ensure(user, role, at);
    }

    function toRole(address addr) public pure returns (bytes32) {
        return Auth.toRole(addr);
    }
}
