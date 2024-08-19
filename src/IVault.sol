// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IERC20Permit, IERC20} from "./token/IERC20Permit.sol";
import {IAggregatorV3} from "./vendor/IAggregatorV3.sol";

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
     * @param staletime Time in seconds for the feed to be considered stale
     * @param price Price at the time of setting the feed
     * @param timestamp Timestamp of the update
     */
    event OracleSet(
        address indexed asset,
        address indexed feed,
        uint256 staletime,
        uint256 price,
        uint256 timestamp
    );

    /**
     * @notice Emitted when a new asset is added to the shares contract
     * @param asset Address of the asset
     * @param feed Price feed of the asset
     * @param staletime Time in seconds for the feed to be considered stale
     * @param depositLimit Deposit limit of the asset
     */
    event AssetAdded(
        address indexed asset,
        address indexed feed,
        uint256 staletime,
        uint256 depositLimit
    );

    /**
     * @notice Emitted when a previously existing asset is removed from the shares contract
     * @param asset Asset that was removed
     * @param timestamp Timestamp of the removal
     */
    event AssetRemoved(address indexed asset, uint256 timestamp);
    /**
     * @notice Emitted when the enabled status for asset is changed
     * @param asset Asset that was removed
     * @param enabled Enabled status set
     * @param timestamp Timestamp of the removal
     */
    event AssetEnabledChange(
        address indexed asset,
        bool enabled,
        uint256 timestamp
    );

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
        address indexed owner,
        address indexed asset,
        address receiver,
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
    function deposit(
        address assetAddr,
        uint256 assetsIn,
        address receiver
    ) external returns (uint256 sharesOut, uint256 assetFee);

    function mint(
        address assetAddr,
        uint256 sharesOut,
        address receiver
    ) external returns (uint256 assetsIn, uint256 assetFee);

    function redeem(
        address assetAddr,
        uint256 sharesIn,
        address receiver,
        address owner
    ) external returns (uint256 assetsOut, uint256 assetFee);

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

    function getFees(address assetAddr) external view returns (uint256);

    function getConfig()
        external
        view
        returns (VaultConfiguration memory config);

    function totalAssets() external view returns (uint256 result);

    function allAssets() external view returns (VaultAsset[] memory assets);

    function assetList(uint256) external view returns (address assetAddr);

    function assets(address) external view returns (VaultAsset memory asset);

    function assetPrice(address assetAddr) external view returns (uint256);
    function previewDeposit(
        address assetAddr,
        uint256 assetsIn
    ) external view returns (uint256 sharesOut, uint256 assetFee);
    function previewMint(
        address assetAddr,
        uint256 sharesOut
    ) external view returns (uint256 assetsIn, uint256 assetFee);
    function previewRedeem(
        address assetAddr,
        uint256 sharesIn
    ) external view returns (uint256 assetsOut, uint256 assetFee);
    function previewWithdraw(
        address assetAddr,
        uint256 assetsOut
    ) external view returns (uint256 sharesIn, uint256 assetFee);
    function maxDeposit(
        address assetAddr
    ) external view returns (uint256 assetsIn);
    function maxDeposit(address, address) external view returns (uint256);
    function maxMint(
        address assetAddr
    ) external view returns (uint256 sharesOut);
    function maxMint(address, address) external view returns (uint256);
    function maxRedeem(
        address assetAddr
    ) external view returns (uint256 sharesIn);
    function maxRedeem(address, address) external view returns (uint256);
    function maxWithdraw(
        address assetAddr
    ) external view returns (uint256 amountOut);
    function maxWithdraw(address, address) external view returns (uint256);
    function exchangeRate() external view returns (uint256 rate);
    function setBaseRate(uint256 newBaseRate) external;
    function addAsset(VaultAsset memory) external returns (VaultAsset memory);
    function removeAsset(address assetAddr) external;
    function setGovernance(address newGovernance) external;
    function acceptGovernance() external;
    function setFeeRecipient(address newFeeRecipient) external;
    function setAssetFeed(
        address assetAddr,
        address feedAddr,
        uint24 newStaleTime
    ) external;
    function setFeedPricePrecision(uint8 newDecimals) external;
    function setMaxDeposits(address assetAddr, uint248 newMaxDeposits) external;
    function setAssetEnabled(address assetAddr, bool isEnabled) external;
    function setDepositFee(address assetAddr, uint16 newDepositFee) external;
    function setWithdrawFee(address assetAddr, uint16 newWithdrawFee) external;
}
