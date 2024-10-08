// solhint-disable

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {IERC20Permit} from "./IERC20Permit.sol";

interface IWETHBase {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256 amount) external;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}

interface IWETH9 is IERC20, IWETHBase {}

interface IWETH9Arb is IERC20Permit, IWETHBase {
    function bridgeMint(address account, uint256 amount) external;

    function bridgeBurn(address account, uint256 amount) external;

    function withdrawTo(address account, uint256 amount) external;

    function depositTo(address account) external payable;

    function l1Address() external view returns (address);

    function transferAndCall(
        address to,
        uint256 amount,
        bytes memory data
    ) external returns (bool);
}
