// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Role {
    bytes32 internal constant DEFAULT_ADMIN = 0x00;
    /// @dev keccak256("kopio.roles.minter.admin")
    bytes32 internal constant ADMIN =
        0x7314fc63cf0618993ea17d6696ada3b0a6ed3cecfadf7bcbba9b9244f265aa5c;
    /// @dev keccak256("kopio.roles.minter.operator")
    bytes32 internal constant OPERATOR =
        0x55cf0d5360d3a2ed790f5bda11a45eacf720dd454a96e5b3f246e1dde72225d4;
    /// @dev keccak256("kopio.roles.minter.manager")
    bytes32 internal constant MANAGER =
        0x5db7c5e02ff07d137c88e895bed5f6f06623c3759919b10ee90966bb61032a8b;
    /// @dev keccak256("kopio.roles.minter.safety.council")
    bytes32 internal constant COUNCIL =
        0xb6f2e29bc47d2a5c05e7fa4b3e6f8a663c0e000c933bbc6a759528a6ed9b185f;
}

library NFTRole {
    bytes32 public constant MINTER = keccak256("kopio.roles.minter");
    bytes32 public constant OPERATOR = keccak256("kopio.roles.operator");
}
