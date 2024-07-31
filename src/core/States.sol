// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {Asset, Enums, Oracle, RoleData, SafetyState, SCDPAccountIndexes, SCDPAssetData, SCDPAssetIndexes, SCDPSeizeData} from "./types/Data.sol";
import {EnumerableSet} from "../../lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import {IERC1155} from "../token/IERC1155.sol";

struct CommonState {
    /* -------------------------------------------------------------------------- */
    /*                                    Core                                    */
    /* -------------------------------------------------------------------------- */
    /// @notice asset address -> asset data
    mapping(address => Asset) assets;
    /// @notice asset -> oracle type -> oracle
    mapping(bytes32 => mapping(Enums.OracleType => Oracle)) oracles;
    /// @notice asset -> action -> state
    mapping(address => mapping(Enums.Action => SafetyState)) safetyState;
    /// @notice The recipient of protocol fees.
    address feeRecipient;
    /* -------------------------------------------------------------------------- */
    /*                             Oracle & Sequencer                             */
    /* -------------------------------------------------------------------------- */
    /// @notice Pyth endpoint
    address pythEp;
    /// @notice L2 sequencer feed address
    address sequencerUptimeFeed;
    /// @notice grace period of sequencer in seconds
    uint32 sequencerGracePeriodTime;
    /// @notice The max deviation percentage between primary and secondary price.
    uint16 maxPriceDeviationPct;
    /// @notice Offchain oracle decimals
    uint8 oracleDecimals;
    /// @notice Flag tells if there is a need to perform safety checks on user actions
    bool safetyStateSet;
    /* -------------------------------------------------------------------------- */
    /*                                 Reentrancy                                 */
    /* -------------------------------------------------------------------------- */
    uint256 entered;
    /* -------------------------------------------------------------------------- */
    /*                               Access Control                               */
    /* -------------------------------------------------------------------------- */
    mapping(bytes32 role => RoleData data) _roles;
    mapping(bytes32 role => EnumerableSet.AddressSet member) _roleMembers;
}

/* -------------------------------------------------------------------------- */
/*                                   Getter                                   */
/* -------------------------------------------------------------------------- */

// Storage position
bytes32 constant COMMON_STORAGE_POSITION = keccak256("kopio.common.storage");

function cs() pure returns (CommonState storage state) {
    bytes32 position = bytes32(COMMON_STORAGE_POSITION);
    assembly {
        state.slot := position
    }
}

/**
 * @title storage for the icdp.
 * @author the kopio project
 */
struct ICDPState {
    /* -------------------------------------------------------------------------- */
    /*                                  Deposits                                  */
    /* -------------------------------------------------------------------------- */
    /// @notice Mapping of account -> collateral asset addresses deposited
    mapping(address => address[]) depositedCollateralAssets;
    /// @notice Mapping of account -> asset -> deposit amount
    mapping(address => mapping(address => uint256)) collateralDeposits;
    /* -------------------------------------------------------------------------- */
    /*                                   Borrows                                  */
    /* -------------------------------------------------------------------------- */
    /// @notice Mapping of account -> kopio -> debt amount owed to the protocol
    mapping(address => mapping(address => uint256)) debt;
    /// @notice Mapping of account -> addresses of borrowed kopios
    mapping(address => address[]) mintedKopios;
    /* --------------------------------- Assets --------------------------------- */
    address[] kopios;
    address[] collaterals;
    /* -------------------------------------------------------------------------- */
    /*                           Configurable Parameters                          */
    /* -------------------------------------------------------------------------- */

    /// @notice The recipient of protocol fees.
    address feeRecipient;
    /// @notice Max liquidation ratio, this is the max collateral ratio liquidations can liquidate to.
    uint32 maxLiquidationRatio;
    /// @notice The minimum ratio of collateral to debt that can be taken by direct action.
    uint32 minCollateralRatio;
    /// @notice The collateralization ratio at which positions may be liquidated.
    uint32 liquidationThreshold;
    /// @notice The minimum USD value of an individual synthetic asset debt position.
    uint256 minDebtValue;
}

/* -------------------------------------------------------------------------- */
/*                                   Getter                                   */
/* -------------------------------------------------------------------------- */

bytes32 constant ICDP_STORAGE_POSITION = keccak256("kopio.icdp.storage");

function ms() pure returns (ICDPState storage state) {
    bytes32 position = ICDP_STORAGE_POSITION;
    assembly {
        state.slot := position
    }
}

/* -------------------------------------------------------------------------- */
/*                                    State                                   */
/* -------------------------------------------------------------------------- */

/**
 * @title storage of the shared cdp.
 * @author the kopio project
 */
struct SCDPState {
    /// @notice Array of assets that are deposit assets and can be swapped
    address[] collaterals;
    /// @notice Array of kopioss that can be minted and swapped.
    address[] kopios;
    /// @notice Mapping of asset -> asset -> swap enabled
    mapping(address => mapping(address => bool)) isRoute;
    /// @notice Mapping of asset -> enabled
    mapping(address => bool) isEnabled;
    /// @notice Mapping of asset -> deposit/debt data
    mapping(address => SCDPAssetData) assetData;
    /// @notice Mapping of account -> collateral -> deposit amount.
    mapping(address => mapping(address => uint256)) deposits;
    /// @notice Mapping of account -> collateral -> principal deposit amount.
    mapping(address => mapping(address => uint256)) depositsPrincipal;
    /// @notice Mapping of collateral -> indexes.
    mapping(address => SCDPAssetIndexes) assetIndexes;
    /// @notice Mapping of account -> collateral -> indices.
    mapping(address => mapping(address => SCDPAccountIndexes)) accountIndexes;
    /// @notice Mapping of account -> liquidationIndex -> Seize data.
    mapping(address => mapping(uint256 => SCDPSeizeData)) seizeEvents;
    /// @notice The asset to convert fees into
    address feeAsset;
    /// @notice The minimum ratio of collateral to debt that can be taken by direct action.
    uint32 minCollateralRatio;
    /// @notice The collateralization ratio at which positions may be liquidated.
    uint32 liquidationThreshold;
    /// @notice Liquidation Overflow Multiplier, multiplies max liquidatable value.
    uint32 maxLiquidationRatio;
}

struct SDIState {
    uint256 totalDebt;
    uint256 totalCover;
    address coverRecipient;
    /// @notice Threshold after cover can be performed.
    uint48 coverThreshold;
    /// @notice Incentive for covering debt
    uint48 coverIncentive;
    address[] coverAssets;
}

/* -------------------------------------------------------------------------- */
/*                                   Getters                                  */
/* -------------------------------------------------------------------------- */

// Storage position
bytes32 constant SCDP_STORAGE_POSITION = keccak256("kopio.scdp.storage");
bytes32 constant SDI_STORAGE_POSITION = keccak256("kopio.scdp.sdi.storage");

// solhint-disable func-visibility
function scdp() pure returns (SCDPState storage state) {
    bytes32 position = SCDP_STORAGE_POSITION;
    assembly {
        state.slot := position
    }
}

function sdi() pure returns (SDIState storage state) {
    bytes32 position = SDI_STORAGE_POSITION;
    assembly {
        state.slot := position
    }
}
