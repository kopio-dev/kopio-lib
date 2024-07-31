// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {Enums} from "./Const.sol";

struct ICDPAccount {
    uint256 totalDebtValue;
    uint256 totalCollateralValue;
    uint256 collateralRatio;
}

/// @notice Oracle configuration mapped to `Asset.ticker`.
struct Oracle {
    address feed;
    bytes32 pythId;
    uint256 staleTime;
    bool invertPyth;
    bool isClosing;
}

/**
 * @title configuration for a kopio
 * @author the kopio project
 * @notice all assets use this same config.
 * @notice ticker is shared, eg. kopio ETH and WETH both would use bytes32('ETH')
 * @dev precentages use 2 decimals: 1e4 (10000) == 100.00%. See {PercentageMath.sol}.
 * @dev the percentage value for uint16 caps at 655.36%.
 */
struct Asset {
    /// @notice underlying ticker (eg. bytes32('ETH')).
    bytes32 ticker;
    /// @notice the fixed share address.
    address share;
    /// @notice Oracle types and order for this asset.
    /// @notice 0 is the primary source.
    /// @notice 1 is the reference for deviation checks
    Enums.OracleType[2] oracles;
    /// @notice decreases collateral valuation (if < 100%) of the asset.
    /// @notice always <= 100% or 1e4.
    uint16 factor;
    /// @notice used to increase debt valuation (if > 100%) of the asset.
    /// @notice always >= 100% or 1e4.
    uint16 dFactor;
    /// @notice fee percent on borrows, taken from collateral.
    uint16 openFee;
    /// @notice fee percent on repayments, taken from collateral,
    uint16 closeFee;
    /// @notice increases seized collateral to incentivize ICDP liquidations.
    uint16 liqIncentive;
    /// @notice supply limit for ICDP.
    uint256 maxDebtMinter;
    /// @notice supply limit for SCDP.
    uint256 maxDebtSCDP;
    /// @notice SCDP deposit limit.
    uint256 depositLimitSCDP;
    /// @notice fee percent when swapped as "asset in".
    uint16 swapInFeeSCDP;
    /// @notice fee percent when swapped as "asset out".
    uint16 swapOutFeeSCDP;
    /// @notice protocol cut of the swap fees. Cap 50% == a.feeShare + b.feeShare <= 100%.
    uint16 protocolFeeShareSCDP;
    /// @notice liquidation incentive when enabled as a global debt asset.
    /// @notice increases seized collateral when asset is repaid in a global liquidation.
    uint16 liqIncentiveSCDP;
    /// @notice token decimal set once when asset is added.
    /// @notice 18 for kopios.
    uint8 decimals;
    /// @notice allow as ICDP collateral.
    bool isMinterCollateral;
    /// @notice allow as ICDP debt
    bool isMinterMintable;
    /// @notice allow as direct SCDP collateral.
    bool isSharedCollateral;
    /// @notice allow as SCDP debt from swaps.
    bool isSwapMintable;
    /// @notice included in the total collateral value calculation of the SCDP.
    /// @notice kopios are true by default as they are indirectly deposited in swaps.
    bool isSharedOrSwappedCollateral;
    /// @notice allow covering SCDP debt with the asset.
    bool isCoverAsset;
}

/// @notice data for an access control role.
struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
}

/// @notice variables for calculating the max liquidation value.
struct MaxLiqVars {
    Asset collateral;
    uint256 accountCollateralValue;
    uint256 minCollateralValue;
    uint256 seizeCollateralAccountValue;
    uint192 minDebtValue;
    uint32 gainFactor;
    uint32 maxLiquidationRatio;
    uint32 debtFactor;
}

struct MaxLiqInfo {
    address account;
    address seizeAssetAddr;
    address repayAssetAddr;
    uint256 repayValue;
    uint256 repayAmount;
    uint256 seizeAmount;
    uint256 seizeValue;
    uint256 repayAssetPrice;
    uint256 repayAssetIndex;
    uint256 seizeAssetPrice;
    uint256 seizeAssetIndex;
}

/// @notice utility struct for price data
struct RawPrice {
    int256 answer;
    uint256 timestamp;
    uint256 staleTime;
    bool isStale;
    bool isZero;
    Enums.OracleType oracle;
    address feed;
}

/// @notice pause config for any `Action`
struct Pause {
    bool enabled;
    uint256 timestamp0;
    uint256 timestamp1;
}

/// @notice safety measures taken for assets
struct SafetyState {
    Pause pause;
}

struct SCDPAssetData {
    uint256 debt;
    uint128 totalDeposits;
    uint128 swapDeposits;
}

/**
 * @notice SCDP initializer configuration.
 * @param feeAsset Asset that all fees from swaps are collected in.
 * @param minCollateralRatio The minimum collateralization ratio.
 * @param liquidationThreshold The liquidation threshold.
 * @param maxLiquidationRatio The maximum CR resulting from liquidations.
 * @param coverThreshold Threshold after which cover can be performed.
 * @param coverIncentive Incentive for covering debt instead of performing a liquidation.
 */
struct SCDPParameters {
    address feeAsset;
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint32 maxLiquidationRatio;
    uint128 coverThreshold;
    uint128 coverIncentive;
}

/**
 * @notice SCDP asset fee and liquidation index data
 * @param currFeeIndex The ever increasing fee index, used to calculate fees.
 * @param currLiqIndex The ever increasing liquidation index, used to calculate liquidated amounts from principal.
 */
struct SCDPAssetIndexes {
    uint128 currFeeIndex;
    uint128 currLiqIndex;
}

/**
 * @notice SCDP seize data
 * @param prevLiqIndex Link to previous value in the liquidation index history.
 * @param feeIndex The fee index at the time of the seize.
 * @param liqIndex The liquidation index after the seize.
 */
struct SCDPSeizeData {
    uint256 prevLiqIndex;
    uint128 feeIndex;
    uint128 liqIndex;
}

/**
 * @notice SCDP account indexes
 * @param lastFeeIndex Fee index at the time of the action.
 * @param lastLiqIndex Liquidation index at the time of the action.
 * @param timestamp Timestamp of the last update.
 */
struct SCDPAccountIndexes {
    uint128 lastFeeIndex;
    uint128 lastLiqIndex;
    uint256 timestamp;
}
