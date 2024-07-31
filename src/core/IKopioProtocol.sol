// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./types/Args.sol";
import "./types/Data.sol";
import {IErrorsEvents} from "./IErrorsEvents.sol";
import {IDiamond} from "./IDiamond.sol";
import {FeedConfiguration, ICDPParams, SwapRouteSetter, SCDPInitArgs} from "./types/Setup.sol";
import {IDiamondStateFacet} from "./IDiamondStateFacet.sol";
import {IAuthorizationFacet} from "./IAuthorizationFacet.sol";
import {IViewDataFacet} from "./IViewDataFacet.sol";
import {IBatchFacet} from "./IBatchFacet.sol";

interface ISCDPConfigFacet {
    /**
     * @notice Initialize SCDP.
     * Callable by diamond owner only.
     */
    function initializeSCDP(SCDPInitArgs memory) external;

    function getParametersSCDP() external view returns (SCDPParameters memory);

    /**
     * @notice Set the asset to cumulate swap fees into.
     * Only callable by admin.
     * @param kopio Asset that is validated to be a deposit asset.
     */
    function setFeeAssetSCDP(address kopio) external;

    /// @notice Set the minimum collateralization ratio for SCDP.
    function setMinCollateralRatioSCDP(uint32) external;

    /// @notice Set the liquidation threshold for SCDP while updating MLR to one percent above it.
    function setLiquidationThresholdSCDP(uint32) external;

    /// @notice Set the max liquidation ratio for SCDP.
    /// @notice MLR is also updated automatically when setLiquidationThresholdSCDP is used.
    function setMaxLiquidationRatioSCDP(uint32) external;

    /// @notice Set the new liquidation incentive for a swappable asset.
    /// @param kopio Asset address
    /// @param newIncentive New liquidation incentive. Bounded to 1e4 <-> 1.25e4.
    function setLiqIncentiveSCDP(address kopio, uint16 newIncentive) external;

    /**
     * @notice Update the deposit asset limit configuration.
     * Only callable by admin.
     * emits PoolCollateralUpdated
     * @param kopio The Collateral asset to update
     * @param newLimit The new deposit limit for the collateral
     */
    function setDepositLimitSCDP(address kopio, uint256 newLimit) external;

    /**
     * @notice Disable or enable a deposit asset. Reverts if invalid asset.
     * Only callable by admin.
     * @param kopio Asset to set.
     * @param enabled Whether to enable or disable the asset.
     */
    function setAssetIsSharedCollateralSCDP(
        address kopio,
        bool enabled
    ) external;

    /**
     * @notice Disable or enable asset from shared collateral value calculations.
     * Reverts if invalid asset and if disabling asset that has user deposits.
     * Only callable by admin.
     * @param kopio Asset to set.
     * @param enabled Whether to enable or disable the asset.
     */
    function setAssetIsSharedOrSwappedCollateralSCDP(
        address kopio,
        bool enabled
    ) external;

    /**
     * @notice Disable or enable a kopio asset to be used in swaps.
     * Reverts if invalid asset. Enabling will also add it to collateral value calculations.
     * Only callable by admin.
     * @param kopio Asset to set.
     * @param enabled Whether to enable or disable the asset.
     */
    function setAssetIsSwapMintableSCDP(address kopio, bool enabled) external;

    /**
     * @notice Sets the fees for a kopio asset
     * @dev Only callable by admin.
     * @param kopio The kopio asset to set fees for.
     * @param openFee The new open fee.
     * @param closeFee The new close fee.
     * @param protocolFee The protocol fee share.
     */
    function setAssetSwapFeesSCDP(
        address kopio,
        uint16 openFee,
        uint16 closeFee,
        uint16 protocolFee
    ) external;

    /**
     * @notice Set whether swap routes for pairs are enabled or not. Both ways.
     * Only callable by admin.
     */
    function setSwapRoutesSCDP(SwapRouteSetter[] calldata) external;

    /**
     * @notice Set whether a swap route for a pair is enabled or not.
     * Only callable by admin.
     */
    function setSingleSwapRouteSCDP(SwapRouteSetter calldata) external;
}

interface ISCDPStateFacet {
    /**
     * @notice Get the total collateral principal deposits for `account`
     * @param account The accountount.
     * @param asset The deposit asset
     */
    function getAccountDepositSCDP(
        address account,
        address asset
    ) external view returns (uint256);

    /**
     * @notice Get the fees of `depositAsset` for `account`
     * @param account The accountount.
     * @param asset The deposit asset
     */
    function getAccountFeesSCDP(
        address account,
        address asset
    ) external view returns (uint256);

    /**
     * @notice Get the value of fees for `account`
     * @param account The accountount.
     */
    function getAccountTotalFeesValueSCDP(
        address account
    ) external view returns (uint256);

    /**
     * @notice Get the (principal) deposit value for `account`
     * @param account The accountount.
     * @param asset The deposit asset
     */
    function getAccountDepositValueSCDP(
        address account,
        address asset
    ) external view returns (uint256);

    function getAssetIndexesSCDP(
        address kopio
    ) external view returns (SCDPAssetIndexes memory);

    /**
     * @notice Get the total collateral deposit value for `account`
     * @param account The accountount.
     */
    function getAccountTotalDepositsValueSCDP(
        address account
    ) external view returns (uint256);

    /**
     * @notice Get the total collateral deposits for `asset`
     * @param asset The collateral asset
     */
    function getDepositsSCDP(address asset) external view returns (uint256);

    /**
     * @notice Get the total collateral swap deposits for `asset`
     * @param asset The collateral asset
     */
    function getSwapDepositsSCDP(address asset) external view returns (uint256);

    /**
     * @notice Get the total collateral deposit value for `asset`
     * @param asset The collateral asset
     * @param noFactors Ignore factors when calculating collateral and debt value.
     */
    function getCollateralValueSCDP(
        address asset,
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice Get the total collateral value, oracle precision
     * @param noFactors Ignore factors when calculating collateral value.
     */
    function getTotalCollateralValueSCDP(
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice Get all pool kopioAssets
     */
    function getGlobalKopios() external view returns (address[] memory);

    /**
     * @notice Get the collateral debt amount for `kopio`
     * @param kopio The kopioAsset
     */
    function getDebtSCDP(address kopio) external view returns (uint256);

    /**
     * @notice Get the debt value for `kopio`
     * @param kopio The kopioAsset
     * @param noFactors result ignores factors.
     */
    function getDebtValueSCDP(
        address kopio,
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice total debt value of kopios - in oracle precision.
     * @param noFactors result ignores factors.
     */
    function getTotalDebtValueSCDP(
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice checks if the asset is enabled as global collateral.
     */
    function getAssetEnabledSCDP(address) external view returns (bool);

    /**
     * @notice check if `assetIn` can be swapped to `assetOut`
     * @param assetIn asset to give
     * @param assetOut asset to receive
     */
    function getSwapEnabledSCDP(
        address assetIn,
        address assetOut
    ) external view returns (bool);

    function getCollateralRatioSCDP() external view returns (uint256);
}

/* -------------------------------------------------------------------------- */
/*                               Access Control                                    */
/* -------------------------------------------------------------------------- */

interface IDepositWithdrawFacet {
    /**
     * @notice Deposits collateral into the protocol.
     * @param account The user to deposit collateral for.
     * @param asset The address of the collateral asset.
     * @param amount The amount of the collateral asset to deposit.
     */
    function depositCollateral(
        address account,
        address asset,
        uint256 amount
    ) external payable;

    /**
     * @notice Withdraws sender's collateral from the protocol.
     * @dev Requires that the post-withdrawal collateral value does not violate minimum collateral requirement.
     * assets array. Only needed if withdrawing the entire deposit of a particular collateral asset.
     */
    function withdrawCollateral(
        WithdrawArgs memory,
        bytes[] calldata
    ) external payable;

    /**
     * @notice withdraws any amount and calls onFlashWithdraw.
     * @dev calls onFlashWithdraw on the sender.
     * @dev MCR check must pass after the callback.
     */
    function flashWithdraw(
        FlashWithdrawArgs memory,
        bytes[] calldata
    ) external payable;
}

interface IBurnFacet {
    /**
     * @notice Burns existing kopio assets.
     * @notice Manager role is required if the caller is not the accountount being repaid to or the accountount repaying.
     */
    function burnKopio(BurnArgs memory args, bytes[] calldata) external payable;
}

interface IMintFacet {
    /**
     * @notice Mints new kopio assets.
     */
    function mintKopio(MintArgs memory, bytes[] calldata) external payable;
}

interface ISwapFacet {
    /**
     * @notice Preview the amount out received.
     * @param assetIn The asset to pay with.
     * @param assetOut The asset to receive.
     * @param amountIn The amount of assetIn to pay
     * @return amountOut The amount of `assetOut` to receive accountording to `amountIn`.
     */
    function previewSwap(
        address assetIn,
        address assetOut,
        uint256 amountIn
    )
        external
        view
        returns (uint256 amountOut, uint256 feeAmount, uint256 protocolFee);

    /**
     * @notice swap kopio to kopio
     * Uses oracle pricing of amountIn to determine how much assetOut to send.
     */
    function swap(SwapArgs calldata) external payable;

    /**
     * @notice Accumulates fees to deposits as a fixed, instantaneous income.
     * @param asset Deposit asset to give income for
     * @param amount Amount to accountumulate
     * @return nextLiquidityIndex Next liquidity index for the asset.
     */
    function cumulateIncome(
        address asset,
        uint256 amount
    ) external payable returns (uint256 nextLiquidityIndex);
}

interface ISCDPFacet {
    /**
     * @notice Deposit global collateral for account.
     * @param account account to deposit for.
     * @param asset collateral to deposit.
     * @param amount amount to deposit.
     */
    function depositSCDP(
        address account,
        address asset,
        uint256 amount
    ) external payable;

    /**
     * @notice Withdraw global collateral.
     */
    function withdrawSCDP(
        SCDPWithdrawArgs memory,
        bytes[] calldata
    ) external payable;

    /**
     * @notice Withdraw global collateral without caring about fees.
     */
    function emergencyWithdrawSCDP(
        SCDPWithdrawArgs memory,
        bytes[] calldata
    ) external payable;

    /**
     * @notice claim pending fees.
     * @param account account claiming.
     * @param collateral collateral with claimable fees.
     * @param receiver receives the fees, fallback to account.
     * @return claimed claimed fees.
     */
    function claimFeesSCDP(
        address account,
        address collateral,
        address receiver
    ) external payable returns (uint256 claimed);

    /**
     * @notice Repay debt for no fees or slippage.
     * @notice Only uses swap deposits, if none available, reverts.
     */
    function repaySCDP(SCDPRepayArgs calldata) external payable;

    /**
     * @notice Liquidate the collateral pool.
     * @notice Adjusts everyones deposits if swap deposits do not cover the seized amount.
     */
    function liquidateSCDP(
        SCDPLiquidationArgs memory,
        bytes[] calldata
    ) external payable;

    /**
     * @dev Calculates the total value that is allowed to be liquidated from SCDP (if it is liquidatable)
     * @param repayKopio Address of kopio to repay
     * @param seizeAsset Address of Collateral to seize
     * @return MaxLiqInfo Calculated information about the maximum liquidation.
     */
    function getMaxLiqValueSCDP(
        address repayKopio,
        address seizeAsset
    ) external view returns (MaxLiqInfo memory);

    function getLiquidatableSCDP() external view returns (bool);
}

interface ISDIFacet {
    /// @notice Get the total debt of the SCDP.
    function getTotalSDIDebt() external view returns (uint256);

    /// @notice Get the effective debt value of the SCDP.
    function getEffectiveSDIDebtUSD() external view returns (uint256);

    /// @notice Get the effective debt amount of the SCDP.
    function getEffectiveSDIDebt() external view returns (uint256);

    /// @notice Get the total normalized amount of cover.
    function getSDICoverAmount() external view returns (uint256);

    function previewSCDPBurn(
        address kopio,
        uint256 amount,
        bool noFactors
    ) external view returns (uint256 shares);

    function previewSCDPMint(
        address kopio,
        uint256 mint,
        bool noFactors
    ) external view returns (uint256 shares);

    /// @notice Simply returns the total supply of SDI.
    function totalSDI() external view returns (uint256);

    /// @notice Get the price of SDI in USD, oracle precision.
    function getSDIPrice() external view returns (uint256);

    /// @notice Cover debt by providing collateral without getting anything in return.
    function coverSCDP(
        address kopio,
        uint256 amount,
        bytes[] calldata
    ) external payable returns (uint256 value);

    /// @notice Cover debt by providing collateral, receiving small incentive in return.
    function coverWithIncentiveSCDP(
        address kopio,
        uint256 amount,
        address seizeAsset,
        bytes[] calldata
    ) external payable returns (uint256 value, uint256 seizedAmount);

    /// @notice Enable a cover asset to be used.
    function enableCoverAssetSDI(address asset) external;

    /// @notice Disable a cover asset to be used.
    function disableCoverAssetSDI(address asset) external;

    /// @notice Set the contract holding cover assets.
    function setCoverRecipientSDI(address) external;

    /// @notice Get all accountepted cover assets.
    function getCoverAssetsSDI() external view returns (address[] memory);
}

interface IICDPConfigFacet {
    /**
     * @dev Updates the contract's minimum debt value.
     */
    function setMinDebtValue(uint256) external;

    /**
     * @notice Updates the liquidation incentive multiplier.
     */
    function setCollateralLiquidationIncentive(address, uint16) external;

    /**
     * @dev Updates the contract's collateralization ratio.
     */
    function setMinCollateralRatio(uint32) external;

    /**
     * @dev Updates the contract's liquidation threshold value
     */
    function setLiquidationThreshold(uint32) external;

    /**
     * @notice Updates the max liquidation ratior value.
     * @notice This is the maximum collateral ratio that liquidations can liquidate to.
     */
    function setMaxLiquidationRatio(uint32) external;
}

interface IStateFacet {
    /// @notice The collateralization ratio at which positions may be liquidated.
    function getLiquidationThreshold() external view returns (uint32);

    /// @notice Multiplies max liquidation multiplier, if a full liquidation happens this is the resulting CR.
    function getMaxLiquidationRatio() external view returns (uint32);

    /// @notice The minimum USD value of an individual synthetic asset debt position.
    function getMinDebtValue() external view returns (uint256);

    /// @notice The minimum ratio of collateral to debt that can be taken by direct action.
    function getMinCollateralRatio() external view returns (uint32);

    /// @notice simple check if kopio asset exists
    function getExists(address) external view returns (bool);

    /// @notice simple check if collateral asset exists
    function getCollateralExists(address) external view returns (bool);

    /// @notice get all meaningful protocol parameters
    function getParameters() external view returns (ICDPParams memory);

    /**
     * @notice Gets the USD value for a single collateral asset and amount.
     * @param _collateral The address of the collateral asset.
     * @param amount The amount of the collateral asset to calculate the value for.
     * @return value The unadjusted value for the provided amount of the collateral asset.
     * @return adjustedValue The (cFactor) adjusted value for the provided amount of the collateral asset.
     * @return price The price of the collateral asset.
     */
    function getCollateralValueWithPrice(
        address _collateral,
        uint256 amount
    )
        external
        view
        returns (uint256 value, uint256 adjustedValue, uint256 price);

    /**
     * @notice Gets the USD value for a single kopio asset and amount.
     * @param kopio The address of the kopio asset.
     * @param amount The amount of the kopio asset to calculate the value for.
     * @return value The unadjusted value for the provided amount of the debt asset.
     * @return adjustedValue The (dFactor) adjusted value for the provided amount of the debt asset.
     * @return price The price of the debt asset.
     */
    function getDebtValueWithPrice(
        address kopio,
        uint256 amount
    )
        external
        view
        returns (uint256 value, uint256 adjustedValue, uint256 price);
}

interface ILiquidationFacet {
    /**
     * @notice Attempts to liquidate an accountount by repaying the portion of the accountount's kopio asset
     * debt, receiving in return a portion of the accountount's collateral at a discounted rate.
     * @param args LiquidationArgs struct containing the arguments necessary to perform a liquidation.
     */
    function liquidate(LiquidationArgs calldata args) external payable;

    /**
     * @dev Calculates the total value that is allowed to be liquidated from an accountount (if it is liquidatable)
     * @param account Address of the accountount to liquidate
     * @param repayKopio Address of kopio Asset to repay
     * @param seizeAsset Address of Collateral to seize
     * @return MaxLiqInfo Calculated information about the maximum liquidation.
     */
    function getMaxLiqValue(
        address account,
        address repayKopio,
        address seizeAsset
    ) external view returns (MaxLiqInfo memory);
}

interface IAccountStateFacet {
    // ExpectedFeeRuntimeInfo is used for stack size optimization
    struct ExpectedFeeRuntimeInfo {
        address[] assets;
        uint256[] amounts;
        uint256 collateralTypeCount;
    }

    /**
     * @notice Calculates if an accountount's current collateral value is under its minimum collateral value
     * @param account The accountount to check.
     * @return bool Indicates if the accountount can be liquidated.
     */
    function getAccountLiquidatable(
        address account
    ) external view returns (bool);

    /**
     * @notice Get accounts icdp state.
     * @param account Account address to get the state for.
     * @return ICDPAccount Total debt value, total collateral value and collateral ratio.
     */
    function getAccountState(
        address account
    ) external view returns (ICDPAccount memory);

    /**
     * @notice Gets an array of kopio assets the accountount has minted.
     * @param account The accountount to get the minted kopio assets for.
     * @return address[] Array of kopio Asset addresses the accountount has minted.
     */
    function getAccountMintedAssets(
        address account
    ) external view returns (address[] memory);

    /**
     * @notice Gets an index for the kopio asset the accountount has minted.
     * @param account The accountount to get the minted kopio assets for.
     * @param kopio The asset lookup address.
     * @return index The index of asset in the minted assets array.
     */
    function getAccountMintIndex(
        address account,
        address kopio
    ) external view returns (uint256);

    /**
     * @notice Gets the total debt value in USD for the account.
     * @notice Adjusted value is multiplied by dFactor.
     * @param account account to get value for.
     * @return value unadjusted value of debt.
     * @return valueAdjusted dFactor multiplied value of debt.
     */
    function getAccountTotalDebtValues(
        address account
    ) external view returns (uint256 value, uint256 valueAdjusted);

    /**
     * @notice Gets the total debt value in USD for the account.
     * @param account account to get value for.
     * @return uint256 the total debt value of `account`.
     */
    function getAccountTotalDebtValue(
        address account
    ) external view returns (uint256);

    /**
     * @notice Get `account` debt amount for `kopio`
     * @param kopio kopio address
     * @param account account to get debt for
     * @return uint256 the amount of debt
     */
    function getAccountDebtAmount(
        address account,
        address kopio
    ) external view returns (uint256);

    /**
     * @notice Get the unadjusted and the adjusted value of collateral deposits of `kopio` for `account`.
     * @notice Adjusted value means it is multiplied by cFactor.
     * @param account Account to get the collateral values for.
     * @param kopio Asset to get the collateral values for.
     * @return value Unadjusted value of the collateral deposits.
     * @return valueAdjusted cFactor adjusted value of the collateral deposits.
     * @return price Price for the collateral asset
     */
    function getAccountCollateralValues(
        address account,
        address kopio
    )
        external
        view
        returns (uint256 value, uint256 valueAdjusted, uint256 price);

    /**
     * @notice Gets the adjusted collateral value of a particular accountount.
     * @param account Account to calculate the collateral value for.
     * @return valueAdjusted Collateral value of a particular accountount.
     */
    function getAccountTotalCollateralValue(
        address account
    ) external view returns (uint256 valueAdjusted);

    /**
     * @notice Gets the adjusted and unadjusted collateral value of `account`.
     * @notice Adjusted value means it is multiplied by cFactor.
     * @param account Account to get the values for
     * @return value Unadjusted total value of the collateral deposits.
     * @return valueAdjusted cFactor adjusted total value of the collateral deposits.
     */
    function getAccountTotalCollateralValues(
        address account
    ) external view returns (uint256 value, uint256 valueAdjusted);

    /**
     * @notice Get an accountount's minimum collateral value required
     * to back a kopio asset amount at a given collateralization ratio.
     * @dev Accounts that have their collateral value under the minimum collateral value are considered unhealthy,
     *      accountounts with their collateral value under the liquidation threshold are considered liquidatable.
     * @param account Account to calculate the minimum collateral value for.
     * @param _ratio Collateralization ratio required: higher ratio = more collateral required
     * @return uint256 Minimum collateral value of a particular accountount.
     */
    function getAccountMinCollateralAtRatio(
        address account,
        uint32 _ratio
    ) external view returns (uint256);

    /**
     * @notice Get a list of accountounts and their collateral ratios
     * @return ratio The collateral ratio of `account`
     */
    function getAccountCollateralRatio(
        address account
    ) external view returns (uint256 ratio);

    /**
     * @notice Get a list of accountount collateral ratios
     * @return ratios Collateral ratios of the `accounts`
     */
    function getAccountCollateralRatios(
        address[] memory accounts
    ) external view returns (uint256[] memory);

    /**
     * @notice Gets an index for the collateral asset the accountount has deposited.
     * @param account Account to get the index for.
     * @param asset Asset address.
     * @return i Index of the minted collateral asset.
     */
    function getAccountDepositIndex(
        address account,
        address asset
    ) external view returns (uint256 i);

    /**
     * @notice Gets an array of collateral assets the accountount has deposited.
     * @param account The accountount to get the deposited collateral assets for.
     * @return address[] Array of collateral asset addresses the accountount has deposited.
     */
    function getAccountCollateralAssets(
        address account
    ) external view returns (address[] memory);

    /**
     * @notice Get `account` collateral deposit amount for `kopio`
     * @param kopio The asset address
     * @param account The accountount to query amount for
     * @return uint256 Amount of collateral deposited for `kopio`
     */
    function getAccountCollateralAmount(
        address account,
        address kopio
    ) external view returns (uint256);

    /**
     * @notice Calculates the expected fee to be taken from a user's deposited collateral assets,
     *         by imitating calcFee without modifying state.
     * @param account Account to charge the open fee from.
     * @param kopio Address of the kopio asset being burned.
     * @param mint Amount of the kopio asset being minted.
     * @param _feeType Fee type (open or close).
     * @return assets Collateral types as an array of addresses.
     * @return amounts Collateral amounts as an array of uint256.
     */
    function previewFee(
        address account,
        address kopio,
        uint256 mint,
        Enums.MinterFee _feeType
    ) external view returns (address[] memory assets, uint256[] memory amounts);
}

interface ISafetyCouncilFacet {
    /**
     * @dev Toggle paused-state of assets in a per-action basis
     *
     * @notice These functions are only callable by a multisig quorum.
     * @param assets list of kopios and/or collateral assets
     * @param action One of possible user actions:
     *  Deposit = 0
     *  Withdraw = 1,
     *  Repay = 2,
     *  Borrow = 3,
     *  Liquidate = 4
     * @param timed Set a duration for this pause - @todo: implement it if required
     * @param duration Duration for the pause if `timed` is true
     */
    function toggleAssetsPaused(
        address[] memory assets,
        Enums.Action action,
        bool timed,
        uint256 duration
    ) external;

    /**
     * @notice set the safetyStateSet flag
     */
    function setSafetyStateSet(bool val) external;

    /**
     * @notice For external checks if a safety state has been set for any asset
     */
    function safetyStateSet() external view returns (bool);

    /**
     * @notice View the state of safety measures for an asset on a per-action basis
     * @param action One of possible user actions:
     *
     *  Deposit = 0
     *  Withdraw = 1,
     *  Repay = 2,
     *  Borrow = 3,
     *  Liquidate = 4
     */
    function safetyStateFor(
        address,
        Enums.Action action
    ) external view returns (SafetyState memory);

    /**
     * @notice Check if `kopio` has a pause enabled for `action`
     * @param action enum `Action`
     *  Deposit = 0
     *  Withdraw = 1,
     *  Repay = 2,
     *  Borrow = 3,
     *  Liquidate = 4
     * @return true if `action` is paused
     */
    function assetActionPaused(
        Enums.Action action,
        address
    ) external view returns (bool);
}

interface ICommonConfigFacet {
    struct PythConfig {
        bytes32[] pythIds;
        uint256[] staleTimes;
        bool[] invertPyth;
        bool[] isClosables;
    }

    /**
     * @notice Updates the fee recipient.
     * @param newRecipient The new fee recipient.
     */
    function setFeeRecipient(address newRecipient) external;

    function setPythEndpoint(address newPythEP) external;

    /**
     * @notice Sets the decimal precision of external oracle
     * @param newDecimals Amount of decimals
     */
    function setDefaultOraclePrecision(uint8 newDecimals) external;

    /**
     * @notice Sets the decimal precision of external oracle
     * @param newDeviationPct Amount of decimals
     */
    function setMaxPriceDeviationPct(uint16 newDeviationPct) external;

    /**
     * @notice Sets L2 sequencer uptime feed address
     * @param newUptimeFeed sequencer uptime feed address
     */
    function setSequencerUptimeFeed(address newUptimeFeed) external;

    /**
     * @notice Sets sequencer grace period time
     * @param newGracePeriod grace period time
     */
    function setSequencerGracePeriod(uint32 newGracePeriod) external;

    /**
     * @notice Set feeds for a ticker.
     * @param _ticker Ticker in bytes32 eg. bytes32("ETH")
     * @param feeds List oracle configuration containing oracle identifiers and feed addresses.
     */
    function setFeedsForTicker(
        bytes32 _ticker,
        FeedConfiguration memory feeds
    ) external;

    /**
     * @notice Set chainlink feeds for tickers.
     * @dev Has modifiers: onlyRole.
     * @param _tickers Bytes32 list of tickers
     * @param _feeds List of feed addresses.
     */
    function setChainlinkFeeds(
        bytes32[] calldata _tickers,
        address[] calldata _feeds,
        uint256[] memory _staleTimes,
        bool[] calldata _isClosables
    ) external;

    /**
     * @notice Set api3 feeds for tickers.
     * @dev Has modifiers: onlyRole.
     * @param _tickers Bytes32 list of tickers
     * @param _feeds List of feed addresses.
     */
    function setAPI3Feeds(
        bytes32[] calldata _tickers,
        address[] calldata _feeds,
        uint256[] memory _staleTimes,
        bool[] calldata _isClosables
    ) external;

    /**
     * @notice Set a vault feed for ticker.
     * @dev Has modifiers: onlyRole.
     * @param _ticker Ticker in bytes32 eg. bytes32("ETH")
     * @param _vaultAddr Vault address
     * @custom:signature setVaultFeed(bytes32,address)
     * @custom:selector 0xc3f9c901
     */
    function setVaultFeed(bytes32 _ticker, address _vaultAddr) external;

    /**
     * @notice Set a pyth feeds for tickers.
     * @dev Has modifiers: onlyRole.
     * @param _tickers Bytes32 list of tickers
     * @param pythConfig Pyth configuration
     */
    function setPythFeeds(
        bytes32[] calldata _tickers,
        PythConfig calldata pythConfig
    ) external;

    function setPythFeed(
        bytes32 _ticker,
        bytes32 _pythId,
        bool _invert,
        uint256 _staleTime,
        bool _isClosable
    ) external;

    /**
     * @notice Set ChainLink feed address for ticker.
     * @param _ticker Ticker in bytes32 eg. bytes32("ETH")
     * @param _feedAddr The feed address.
     * @custom:signature setChainLinkFeed(bytes32,address)
     * @custom:selector 0xe091f77a
     */
    function setChainLinkFeed(
        bytes32 _ticker,
        address _feedAddr,
        uint256 _staleTime,
        bool _isClosable
    ) external;

    /**
     * @notice Set API3 feed address for an asset.
     * @param _ticker Ticker in bytes32 eg. bytes32("ETH")
     * @param _feedAddr The feed address.
     * @custom:signature setApi3Feed(bytes32,address)
     * @custom:selector 0x7e9f9837
     */
    function setAPI3Feed(
        bytes32 _ticker,
        address _feedAddr,
        uint256 _staleTime,
        bool _isClosable
    ) external;

    /**
     * @notice Sets gating manager
     * @param _newManager _newManager address
     */
    function setGatingManager(address _newManager) external;

    /**
     * @notice Sets market status provider
     * @param _provider market status provider address
     */
    function setMarketStatusProvider(address _provider) external;
}

interface ICommonStateFacet {
    /// @notice The recipient of protocol fees.
    function getFeeRecipient() external view returns (address);

    /// @notice The pyth endpoint.
    function getPythEndpoint() external view returns (address);

    /// @notice Offchain oracle decimals
    function getDefaultOraclePrecision() external view returns (uint8);

    /// @notice max deviation between main oracle and fallback oracle
    function getOracleDeviationPct() external view returns (uint16);

    /// @notice gating manager contract address
    function getGatingManager() external view returns (address);

    /// @notice Get the L2 sequencer uptime feed address.
    function getSequencerUptimeFeed() external view returns (address);

    /// @notice Get the L2 sequencer uptime feed grace period
    function getSequencerGracePeriod() external view returns (uint32);

    /**
     * @notice Get configured feed of the ticker
     * @param _ticker Ticker in bytes32, eg. bytes32("ETH").
     * @param oracleType The oracle type.
     * @return feedAddr Feed address matching the oracle type given.
     */
    function getOracleOfTicker(
        bytes32 _ticker,
        Enums.OracleType oracleType
    ) external view returns (Oracle memory);

    function getChainlinkPrice(bytes32) external view returns (uint256);

    function getVaultPrice(bytes32) external view returns (uint256);

    function getRedstonePrice(bytes32) external view returns (uint256);

    function getAPI3Price(bytes32) external view returns (uint256);

    function getPythPrice(bytes32) external view returns (uint256);
}

interface IAssetStateFacet {
    /**
     * @notice Get the state of a specific asset
     * @param kopio kopio address.
     * @return asset kopio configuration
     * @custom:signature getAsset(address)
     * @custom:selector 0x30b8b2c6
     */

    function getAsset(address kopio) external view returns (Asset memory);

    /**
     * @notice Get price for an asset from address.
     * @param kopio kopio address.
     * @return uint256 Current price for the asset.
     * @custom:signature getPrice(address)
     * @custom:selector 0x41976e09
     */
    function getPrice(address kopio) external view returns (uint256);

    /**
     * @notice Get push price for an asset from address.
     * @param kopio kopio address.
     * @return RawPrice Current raw price for the asset.
     * @custom:signature getPushPrice(address)
     * @custom:selector 0xc72f3dd7
     */
    function getPushPrice(
        address kopio
    ) external view returns (RawPrice memory);

    /**
     * @notice Get value for an asset amount using the current price.
     * @param kopio kopio address.
     * @param amount The amount (uint256).
     * @return uint256 Current value for `amount` of `kopio`.
     * @custom:signature getValue(address,uint256)
     * @custom:selector 0xc7bf8cf5
     */
    function getValue(
        address kopio,
        uint256 amount
    ) external view returns (uint256);

    /**
     * @notice get active price feed for an assets oracle type.
     * @param kopio kopio address.
     * @param oracleType oracle type.
     * @return feedAddr the active price feed
     */
    function getFeedForAddress(
        address kopio,
        Enums.OracleType oracleType
    ) external view returns (address feedAddr);

    /**
     * @notice market status of the underlying.
     * @param kopio kopio address.
     * @return bool true if open, otherwise false.
     * @custom:signature getMarketStatus(address)
     * @custom:selector 0x3b3b3b3b
     */
    function getMarketStatus(address kopio) external view returns (bool);
}

interface IAssetConfigFacet {
    /**
     * @notice Adds a new asset to the common state.
     * @notice Performs validations accountording to the `cfg` provided.
     * @dev Use validate / static call this for validation.
     * @param kopio Asset address.
     * @param cfg Configuration struct to save for the asset.
     * @param feeds Configuration struct for the asset's oracles
     * @return Asset Result of addAsset.
     */
    function addAsset(
        address kopio,
        Asset memory cfg,
        FeedConfiguration memory feeds
    ) external returns (Asset memory);

    /**
     * @notice Update asset config.
     * @notice Performs validations accountording to the `cfg` set.
     * @dev Use validate / static call this for validation.
     * @param kopio The asset address.
     * @param cfg Configuration struct to apply for the asset.
     */
    function updateAsset(
        address kopio,
        Asset memory cfg
    ) external returns (Asset memory);

    /**
     * @notice Updates the cFactor of a kopioAsset. Convenience.
     */
    function setCFactor(address, uint16) external;

    /**
     * @notice Updates the dFactor of a kopioAsset.
     */
    function setBFactor(address, uint16) external;

    /**
     * @notice Validate supplied asset config. Reverts with information if invalid.
     * @return bool True for convenience.
     */
    function validate(address, Asset memory) external view returns (bool);

    /**
     * @notice Update oracle type order for an asset.
     * @param kopio The asset address.
     * @param newOrder List of 2 OracleTypes. 0 is primary and 1 is the reference.
     */
    function setOracleOrder(
        address kopio,
        Enums.OracleType[2] memory newOrder
    ) external;
}

// solhint-disable-next-line no-empty-blocks
interface IKopioProtocol is
    IErrorsEvents,
    IDiamondStateFacet,
    IDiamond,
    IAuthorizationFacet,
    ICommonConfigFacet,
    ICommonStateFacet,
    IAssetConfigFacet,
    IAssetStateFacet,
    ISwapFacet,
    ISCDPFacet,
    ISCDPConfigFacet,
    ISCDPStateFacet,
    ISDIFacet,
    IBurnFacet,
    ISafetyCouncilFacet,
    IICDPConfigFacet,
    IMintFacet,
    IStateFacet,
    IDepositWithdrawFacet,
    IAccountStateFacet,
    ILiquidationFacet,
    IViewDataFacet,
    IBatchFacet
{}
