// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC4626Upgradeable {
    event Issue(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Deposit(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Destroy(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @notice Deposit kopio for fixed shares
     * @param assets amount to deposit
     * @param receiver receives the shares
     * @return shares amount of fixed shares minted
     */
    function deposit(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares);

    /**
     * @notice Withdraw assets for fixed shares.
     * @param assets amount to withdraw
     * @param receiver receives the withdrawal.
     * @param owner account to burn shares from
     * @return shares burned shares
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256 assets);

    function maxRedeem(address owner) external view returns (uint256 assets);

    function maxWithdraw(address owner) external view returns (uint256 assets);

    /**
     * @notice Mint fixed shares of an asset.
     * @param shares amount to mint
     * @param receiver receiver of the mint
     * @return assets required assets
     */
    function mint(
        uint256 shares,
        address receiver
    ) external returns (uint256 assets);

    function previewDeposit(
        uint256 assets
    ) external view returns (uint256 shares);

    function previewMint(uint256 shares) external view returns (uint256 assets);

    function previewRedeem(
        uint256 shares
    ) external view returns (uint256 assets);

    function previewWithdraw(
        uint256 assets
    ) external view returns (uint256 shares);

    /**
     * @notice Track the underlying amount
     * @return Total supply for the underlying
     */
    function totalAssets() external view returns (uint256);

    /**
     * @notice Redeem fixed shares for kopio
     * @param shares amount to redeem
     * @param receiver receives the redemption.
     * @param owner address to burn shares from.
     * @return assets redeemed kopio
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
}
