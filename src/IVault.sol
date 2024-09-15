// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IERC20Permit, IERC20} from "./token/IERC20Permit.sol";
import {IAggregatorV3} from "./vendor/IAggregatorV3.sol";
import {IKopioCLV3} from "./IKopioCLV3.sol";

interface IVaultFlash {
    enum FlashKind {
        Shares,
        Assets
    }

    struct Flash {
        address asset;
        uint256 assets;
        uint256 shares;
        address receiver;
        FlashKind kind;
    }

    struct FlashData {
        uint256 balIn;
        uint256 tSupplyIn;
        uint256 tAssetsIn;
        uint256 depositsIn;
    }

    error FLASH_KIND_NOT_SUPPORTED(FlashKind);
}

interface IVaultFlashReceiver is IVaultFlash {
    function onVaultFlash(Flash calldata, bytes calldata) external;
}

interface VEvent {
    /**
     * @notice Emitted when a deposit/mint is made
     * @param caller Caller of the deposit/mint
     * @param receiver Receiver of the minted assets
     * @param asset Asset that was deposited/minted
     * @param assetsIn Amount of assets deposited
     * @param sharesOut Amount of shares minted
     */
    event Deposit(
        address indexed caller,
        address indexed receiver,
        address indexed asset,
        uint256 assetsIn,
        uint256 sharesOut
    );

    /**
     * @notice Emitted when a new oracle is set for an asset
     * @param asset Asset that was updated
     * @param feed Feed that was set
     * @param st Time in seconds for the feed to be considered stale
     */
    event OracleSet(address indexed asset, address indexed feed, uint256 st);

    /**
     * @notice Emitted when a new asset is added to the shares contract
     * @param asset Address of the asset
     * @param feed Price feed of the asset
     * @param st Time in seconds for the feed to be considered stale
     * @param depositLimit Deposit limit of the asset
     */
    event AssetAdded(
        address indexed asset,
        address indexed feed,
        uint256 st,
        uint256 depositLimit
    );

    /**
     * @notice Emitted when a previously existing asset is removed from the shares contract
     * @param asset Asset that was removed
     */
    event AssetRemoved(address indexed asset);

    /**
     * @notice Emitted when a withdraw/redeem is made
     * @param caller Caller of the withdraw/redeem
     * @param receiver Receiver of the withdrawn assets
     * @param asset Asset that was withdrawn/redeemed
     * @param owner Owner of the withdrawn assets
     * @param assetsOut Amount of assets withdrawn
     * @param sharesIn Amount of shares redeemed
     */
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed asset,
        address owner,
        uint256 assetsOut,
        uint256 sharesIn
    );
    event VaultFlash(
        address indexed caller,
        address indexed ownerOrReceiver,
        address indexed asset,
        uint256 assets,
        uint256 shares,
        IVaultFlash.FlashKind kind
    );
}

struct VaultAsset {
    IERC20 token;
    IAggregatorV3 feed;
    uint24 staleTime;
    uint8 decimals;
    uint32 depositFee;
    uint32 withdrawFee;
    uint248 maxDeposits;
    bool enabled;
}

struct VaultConfiguration {
    address sequencerUptimeFeed;
    uint96 sequencerGracePeriodTime;
    address governance;
    address pendingGovernance;
    address feeRecipient;
    uint8 oracleDecimals;
}

interface IVault is IERC20Permit, IVaultFlash, VEvent {
    /**
     * @notice This function deposits `assetsIn` of `asset`, regardless of the amount of vault shares minted.
     * @notice If depositFee > 0, `depositFee` of `assetsIn` is sent to the fee recipient.
     * @dev emits Deposit(caller, receiver, asset, assetsIn, sharesOut);
     * @param assetAddr Asset to deposit.
     * @param assetsIn Amount of `asset` to deposit.
     * @param receiver Address to receive `sharesOut` of vault shares.
     * @return sharesOut Amount of vault shares minted for `assetsIn`.
     * @return assetFee Amount of fees paid in `asset`.
     */
    function deposit(
        address assetAddr,
        uint256 assetsIn,
        address receiver
    ) external returns (uint256 sharesOut, uint256 assetFee);

    /**
     * @notice This function mints `sharesOut` of vault shares, regardless of the amount of `asset` received.
     * @notice If depositFee > 0, `depositFee` of `assetsIn` is sent to the fee recipient.
     * @param assetAddr Asset to deposit.
     * @param sharesOut Amount of vault shares desired to mint.
     * @param receiver Address to receive `sharesOut` of shares.
     * @return assetsIn Assets used to mint `sharesOut` of vault shares.
     * @return assetFee Amount of fees paid in `asset`.
     * @dev emits Deposit(caller, receiver, asset, assetsIn, sharesOut);
     */
    function mint(
        address assetAddr,
        uint256 sharesOut,
        address receiver
    ) external returns (uint256 assetsIn, uint256 assetFee);

    /**
     * @notice This function burns `sharesIn` of shares from `owner`, regardless of the amount of `asset` received.
     * @notice If withdrawFee > 0, `withdrawFee` of `assetsOut` is sent to the fee recipient.
     * @param assetAddr Asset to redeem.
     * @param sharesIn Amount of vault shares to redeem.
     * @param receiver Address to receive the redeemed assets.
     * @param owner Owner of vault shares.
     * @return assetsOut Amount of `asset` used for redeem `assetsOut`.
     * @return assetFee Amount of fees paid in `asset`.
     * @dev emits Withdraw(caller, receiver, asset, owner, assetsOut, sharesIn);
     */
    function redeem(
        address assetAddr,
        uint256 sharesIn,
        address receiver,
        address owner
    ) external returns (uint256 assetsOut, uint256 assetFee);

    /**
     * @notice This function withdraws `assetsOut` of assets, regardless of the amount of vault shares required.
     * @notice If withdrawFee > 0, `withdrawFee` of `assetsOut` is sent to the fee recipient.
     * @param assetAddr Asset to withdraw.
     * @param assetsOut Amount of `asset` desired to withdraw.
     * @param receiver Address to receive the withdrawn assets.
     * @param owner Owner of vault shares.
     * @return sharesIn Amount of vault shares used to withdraw `assetsOut` of `asset`.
     * @return assetFee Amount of fees paid in `asset`.
     * @dev emits Withdraw(caller, receiver, asset, owner, assetsOut, sharesIn);
     */
    function withdraw(
        address assetAddr,
        uint256 assetsOut,
        address receiver,
        address owner
    ) external returns (uint256 sharesIn, uint256 assetFee);

    function flash(
        address assetAddr,
        uint256 assetsOut,
        address receiver,
        address owner,
        bytes calldata args
    ) external returns (uint256 sharesIn, uint256 assetFee);

    function flash(
        address assetAddr,
        uint256 sharesOut,
        address receiver,
        bytes calldata args
    ) external returns (uint256 assetsIn, uint256 assetFee);

    /* -------------------------------------------------------------------------- */
    /*                                    Views                                   */
    /* -------------------------------------------------------------------------- */
    function getFees(address assetAddr) external view returns (uint256);

    /**
     * @notice Returns the current vault configuration
     * @return Vault configuration struct
     */
    function getConfig() external view returns (VaultConfiguration memory);

    /**
     * @notice Returns the total value of all assets in the shares contract in USD WAD precision.
     */
    function totalAssets() external view returns (uint256 result);

    function allAssets() external view returns (VaultAsset[] memory);

    function assetList(uint256) external view returns (address);

    function assets(address) external view returns (VaultAsset memory);

    function assetPrice(address assetAddr) external view returns (uint256);

    function kopioCLV3() external view returns (IKopioCLV3);

    /**
     * @notice This function is used for previewing the amount of shares minted for `assetsIn` of `asset`.
     * @param assetAddr Supported asset address
     * @param assetsIn Amount of `asset` in.
     * @return sharesOut Amount of vault shares minted.
     * @return assetFee Amount of fees paid in `asset`.
     */
    function previewDeposit(
        address assetAddr,
        uint256 assetsIn
    ) external view returns (uint256 sharesOut, uint256 assetFee);

    /**
     * @notice This function is used for previewing `assetsIn` of `asset` required to mint `sharesOut` of vault shares.
     * @param assetAddr Supported asset address
     * @param sharesOut Desired amount of vault shares to mint.
     * @return assetsIn Amount of `asset` required.
     * @return assetFee Amount of fees paid in `asset`.
     */
    function previewMint(
        address assetAddr,
        uint256 sharesOut
    ) external view returns (uint256 assetsIn, uint256 assetFee);

    /**
     * @notice This function is used for previewing `assetsOut` of `asset` received for `sharesIn` of vault shares.
     * @param assetAddr Supported asset address
     * @param sharesIn Desired amount of vault shares to burn.
     * @return assetsOut Amount of `asset` received.
     * @return assetFee Amount of fees paid in `asset`.
     */
    function previewRedeem(
        address assetAddr,
        uint256 sharesIn
    ) external view returns (uint256 assetsOut, uint256 assetFee);

    /**
     * @notice This function is used for previewing `sharesIn` of vault shares required to burn for `assetsOut` of `asset`.
     * @param assetAddr Supported asset address
     * @param assetsOut Desired amount of `asset` out.
     * @return sharesIn Amount of vault shares required.
     * @return assetFee Amount of fees paid in `asset`.
     */
    function previewWithdraw(
        address assetAddr,
        uint256 assetsOut
    ) external view returns (uint256 sharesIn, uint256 assetFee);

    /**
     * @notice Calculates the maximum depositable amount of asset.
     * @param assetAddr Asset to deposit.
     * @return assetsIn Maximum depositable amount of assets.
     */
    function maxDeposit(
        address assetAddr
    ) external view returns (uint256 assetsIn);
    function maxDeposit(address, address) external view returns (uint256);

    /**
     * @notice Calculates the maximum mintable amount of shares for asset.
     * @param assetAddr Asset to deposit for the shares.
     * @return sharesOut Maximum mint amount.
     */
    function maxMint(
        address assetAddr
    ) external view returns (uint256 sharesOut);
    function maxMint(address, address) external view returns (uint256);

    /**
     * @notice Calculates the maximum redeemable amount of shares.
     * @param assetAddr Asset to receive.
     * @return sharesIn Maximum redeemable amount.
     */
    function maxRedeem(
        address assetAddr
    ) external view returns (uint256 sharesIn);
    function maxRedeem(address, address) external view returns (uint256);

    /**
     * @notice Calculates the maximum withdrawable amount of asset.
     * @param assetAddr Asset to withdraw..
     * @return amountOut Maximum withdrawable amount.
     */
    function maxWithdraw(
        address assetAddr
    ) external view returns (uint256 amountOut);
    function maxWithdraw(address, address) external view returns (uint256);

    /**
     * @notice Returns the exchange rate of one vault share to USD.
     * @return rate Exchange rate of one vault share to USD in wad precision.
     */
    function exchangeRate() external view returns (uint256 rate);

    /* ------------------------------- Restricted ------------------------------- */

    function feeWithdraw(address assetAddr) external;

    function setBaseRate(uint256 newBaseRate) external;

    /**
     * @notice Adds a new asset to the vault
     * @param assetConfig Asset to add
     */
    function addAsset(
        VaultAsset memory assetConfig
    ) external returns (VaultAsset memory);

    /**
     * @notice Removes an asset from the vault
     * @param assetAddr Asset address to remove
     * emits assetRemoved(asset, block.timestamp);
     */
    function removeAsset(address assetAddr) external;

    /**
     * @notice Current governance sets a new governance address
     * @param newGovernance The new governance address
     */
    function setGovernance(address newGovernance) external;

    function acceptGovernance() external;

    function setConfiguration(
        address kclv3,
        address feeRecipient,
        address seqFeed,
        uint96 gracePeriod,
        uint8 oracleDec
    ) external;

    /**
     * @notice Sets a new oracle for a asset
     * @param assetAddr Asset to set the oracle for
     * @param feedAddr Feed to set
     * @param st Time in seconds for the feed to be considered stale
     */
    function setAssetFeed(
        address assetAddr,
        address feedAddr,
        uint24 st
    ) external;

    /**
     * @notice Sets the limiting factors for an asset
     * @param assetAddr Address of the asset
     * @param maxDeposits New max deposits to set
     * @param isEnabled New enabled status to set
     */
    function setAssetLimits(
        address assetAddr,
        uint248 maxDeposits,
        bool isEnabled
    ) external;

    /**
     * @notice Sets the deposit and withdraw fee for an asset
     * @param assetAddr Asset to set the deposit fee for
     * @param newDepositFee Fee to set
     * @param newWithdrawFee Fee to set
     */
    function setAssetFees(
        address assetAddr,
        uint16 newDepositFee,
        uint16 newWithdrawFee
    ) external;
}
