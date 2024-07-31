// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Enums} from "./Const.sol";

struct ICDPParams {
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint32 maxLiquidationRatio;
    uint256 minDebtValue;
}

/**
 * @notice Feed configuration.
 * @param oracleIds List of two supported oracle providers.
 * @param feeds List of two feed addresses matching to the providers supplied. Redstone will be address(0).
 * @param staleTimes List of two stale times for the feeds.
 * @param pythId Pyth asset ID.
 * @param invertPyth Invert the Pyth price.
 * @param isClosable Is the market for the ticker closable.
 */
struct FeedConfiguration {
    Enums.OracleType[2] oracleIds;
    address[2] feeds;
    uint256[2] staleTimes;
    bytes32 pythId;
    bool invertPyth;
    bool isClosable;
}

/**
 * @notice Initialization arguments for common values
 */
struct CommonInitArgs {
    address admin;
    address council;
    address treasury;
    uint16 maxPriceDeviationPct;
    uint8 oracleDecimals;
    uint32 sequencerGracePeriodTime;
    address sequencerUptimeFeed;
    address gatingManager;
    address pythEp;
}

/**
 * @notice SCDP initializer configuration.
 * @param minCollateralRatio The minimum collateralization ratio.
 * @param liquidationThreshold The liquidation threshold.
 * @param coverThreshold Threshold after which cover can be performed.
 * @param coverIncentive Incentive for covering debt instead of performing a liquidation.
 */
struct SCDPInitArgs {
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint48 coverThreshold;
    uint48 coverIncentive;
}

// Used for setting swap pairs enabled or disabled in the pool.
struct SwapRouteSetter {
    address assetIn;
    address assetOut;
    bool enabled;
}
