// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IERC20} from "./token/IERC20Permit.sol";
import {IAggregatorV3} from "./vendor/IAggregatorV3.sol";
import {IKopio} from "./IKopio.sol";
import {PythView} from "./vendor/Pyth.sol";

// solhint-disable

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 value => uint256) _positions;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(
        Set storage set,
        bytes32 value
    ) private view returns (bool) {
        return set._positions[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(
        Set storage set,
        uint256 index
    ) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    function add(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(
        Bytes32Set storage set,
        bytes32 value
    ) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(
        Bytes32Set storage set,
        uint256 index
    ) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(
        Bytes32Set storage set
    ) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(
        AddressSet storage set,
        address value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(
        AddressSet storage set,
        uint256 index
    ) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(
        AddressSet storage set
    ) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(
        UintSet storage set,
        uint256 value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(
        UintSet storage set,
        uint256 value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(
        UintSet storage set,
        uint256 index
    ) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(
        UintSet storage set
    ) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

struct FlashWithdrawArgs {
    address account;
    address asset;
    uint256 amount;
    bytes data;
}

struct LiquidationArgs {
    address account;
    address kopio;
    uint256 amount;
    address collateral;
    bytes[] prices;
}

struct SCDPLiquidationArgs {
    address kopio;
    uint256 amount;
    address collateral;
}

struct SCDPRepayArgs {
    address kopio;
    uint256 amount;
    address collateral;
    bytes[] prices;
}

struct SCDPWithdrawArgs {
    address account;
    address collateral;
    uint256 amount;
    address receiver;
}

struct SwapArgs {
    address receiver;
    address assetIn;
    address assetOut;
    uint256 amountIn;
    uint256 amountOutMin;
    bytes[] prices;
}

struct MintArgs {
    address account;
    address kopio;
    uint256 amount;
    address receiver;
}

struct BurnArgs {
    address account;
    address kopio;
    uint256 amount;
    address repayee;
}

struct WithdrawArgs {
    address account;
    address asset;
    uint256 amount;
    address receiver;
}

library Enums {
    enum ICDPFee {
        Open,
        Close
    }

    enum SwapFee {
        In,
        Out
    }

    enum OracleType {
        Empty,
        Redstone,
        Chainlink,
        API3,
        Vault,
        Pyth
    }

    enum Action {
        Deposit,
        Withdraw,
        Repay,
        Borrow,
        Liquidation,
        SCDPDeposit,
        SCDPSwap,
        SCDPWithdraw,
        SCDPRepay,
        SCDPLiquidation,
        SCDPFeeClaim,
        SCDPCover
    }
}

library Role {
    bytes32 internal constant DEFAULT_ADMIN = 0x00;
    bytes32 internal constant ADMIN = keccak256("kopio.role.admin");
    bytes32 internal constant OPERATOR = keccak256("kopio.role.operator");
    bytes32 internal constant MANAGER = keccak256("kopio.role.manager");
    bytes32 internal constant SAFETY_COUNCIL = keccak256("kopio.role.safety");
}

library Constants {
    uint8 internal constant NOT_ENTERED = 1;
    uint8 internal constant ENTERED = 2;
    uint8 internal constant NOT_INITIALIZING = 1;
    uint8 internal constant INITIALIZING = 2;

    uint256 internal constant MIN_ORACLE_DECIMALS = 8;
    uint256 internal constant MIN_COLLATERAL = 1e12;

    uint256 internal constant MAX_MIN_DEBT_VALUE = 1_000 * 1e8; // $1,000
}

library Percents {
    uint16 internal constant ONE = 0.01e4;
    uint16 internal constant HUNDRED = 1e4;
    uint16 internal constant TWENTY_FIVE = 0.25e4;
    uint16 internal constant FIFTY = 0.50e4;
    uint16 internal constant MAX_DEVIATION = TWENTY_FIVE;

    uint16 internal constant BASIS_POINT = 1;
    uint16 internal constant MAX_CLOSE_FEE = 0.25e4; // 25%

    uint16 internal constant MAX_OPEN_FEE = 0.25e4; // 25%

    uint16 internal constant MAX_SCDP_FEE = 0.5e4; // 50%

    uint16 internal constant MIN_LT = HUNDRED + ONE; // 101%
    uint16 internal constant MIN_MCR = HUNDRED + ONE + ONE; // 102%

    uint16 internal constant MIN_LIQ_INCENTIVE = HUNDRED;

    uint16 internal constant MAX_LIQ_INCENTIVE = 1.25e4; // 125%
}

function id(address t) view returns (err.ID memory r) {
    r.addr = t;
    if (t.code.length != 0) r.symbol = tkn(t).symbol();
}

interface tkn {
    function symbol() external view returns (string memory);
}

interface err {
    struct ID {
        string symbol;
        address addr;
    }

    error ADDRESS_HAS_NO_CODE(address);
    error NOT_INITIALIZING();
    error TO_WAD_AMOUNT_IS_NEGATIVE(int256);
    error COMMON_ALREADY_INITIALIZED();
    error ICDP_ALREADY_INITIALIZED();
    error SCDP_ALREADY_INITIALIZED();
    error STRING_HEX_LENGTH_INSUFFICIENT();
    error SAFETY_COUNCIL_NOT_ALLOWED();
    error SAFETY_COUNCIL_SETTER_IS_NOT_ITS_OWNER(address);
    error SAFETY_COUNCIL_ALREADY_EXISTS(address given, address existing);
    error MULTISIG_NOT_ENOUGH_OWNERS(address, uint256 owners, uint256 required);
    error ACCESS_CONTROL_NOT_SELF(address who, address self);
    error MARKET_CLOSED(ID, string);
    error SCDP_ASSET_ECONOMY(
        ID,
        uint256 seizeReductionPct,
        ID,
        uint256 repayIncreasePct
    );
    error ICDP_ASSET_ECONOMY(
        ID,
        uint256 seizeReductionPct,
        ID,
        uint256 repayIncreasePct
    );
    error INVALID_TICKER(ID, string ticker);
    error PYTH_EP_ZERO();
    error ASSET_SET_FEEDS_FAILED(ID);
    error ASSET_PAUSED_FOR_THIS_ACTION(ID, uint8 action);
    error NOT_COVER_ASSET(ID);
    error NOT_ENABLED(ID);
    error NOT_CUMULATED(ID);
    error NOT_DEPOSITABLE(ID);
    error NOT_MINTABLE(ID);
    error NOT_SWAPPABLE(ID);
    error NOT_COLLATERAL(ID);
    error INVALID_ASSET(address);
    error NO_GLOBAL_DEPOSITS(ID);
    error ASSET_CANNOT_BE_FEE_ASSET(ID);
    error ASSET_NOT_VALID_DEPOSIT_ASSET(ID);
    error ASSET_ALREADY_ENABLED(ID);
    error ASSET_ALREADY_DISABLED(ID);
    error NOT_INCOME_ASSET(address);
    error ASSET_EXISTS(ID);
    error VOID_ASSET();
    error CANNOT_REMOVE_COLLATERAL_THAT_HAS_USER_DEPOSITS(ID);
    error CANNOT_REMOVE_SWAPPABLE_ASSET_THAT_HAS_DEBT(ID);
    error INVALID_KOPIO(ID kopio);
    error INVALID_SHARE(ID share, ID kopio);
    error IDENTICAL_ASSETS(ID);
    error WITHDRAW_NOT_SUPPORTED();
    error MINT_NOT_SUPPORTED();
    error DEPOSIT_NOT_SUPPORTED();
    error REDEEM_NOT_SUPPORTED();
    error NATIVE_TOKEN_DISABLED(ID);
    error EXCEEDS_ASSET_DEPOSIT_LIMIT(ID, uint256 deposits, uint256 limit);
    error EXCEEDS_ASSET_MINTING_LIMIT(ID, uint256 deposits, uint256 limit);
    error UINT128_OVERFLOW(ID, uint256 deposits, uint256 limit);
    error INVALID_SENDER(address, address);
    error INVALID_MIN_DEBT(uint256 invalid, uint256 valid);
    error INVALID_SCDP_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_MCR(uint256 invalid, uint256 valid);
    error MLR_LESS_THAN_LT(uint256 mlt, uint256 lt);
    error INVALID_LIQ_THRESHOLD(uint256 lt, uint256 min, uint256 max);
    error INVALID_PROTOCOL_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_ASSET_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_ORACLE_DEVIATION(uint256 invalid, uint256 valid);
    error INVALID_ORACLE_TYPE(uint8 invalid);
    error INVALID_FEE_RECIPIENT(address invalid);
    error INVALID_LIQ_INCENTIVE(ID, uint256 invalid, uint256 min, uint256 max);
    error INVALID_DFACTOR(ID, uint256 invalid, uint256 valid);
    error INVALID_CFACTOR(ID, uint256 invalid, uint256 valid);
    error INVALID_ICDP_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_PRICE_PRECISION(uint256 decimals, uint256 valid);
    error INVALID_COVER_THRESHOLD(uint256 threshold, uint256 max);
    error INVALID_COVER_INCENTIVE(uint256 incentive, uint256 min, uint256 max);
    error INVALID_DECIMALS(ID, uint256 decimals);
    error INVALID_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_FEE_TYPE(uint8 invalid, uint8 valid);
    error INVALID_VAULT_PRICE(string ticker, address);
    error INVALID_API3_PRICE(string ticker, address);
    error INVALID_CL_PRICE(string ticker, address);
    error INVALID_PRICE(ID, address oracle, int256 price);
    error INVALID_KOPIO_OPERATOR(
        ID,
        address invalidOperator,
        address validOperator
    );
    error INVALID_DENOMINATOR(ID, uint256 denominator, uint256 valid);
    error INVALID_OPERATOR(ID, address who, address valid);
    error INVALID_SUPPLY_LIMIT(ID, uint256 invalid, uint256 valid);
    error NEGATIVE_PRICE(address asset, int256 price);
    error INVALID_PYTH_PRICE(bytes32 id, uint256 price);
    error STALE_PRICE(
        string ticker,
        uint256 price,
        uint256 timeFromUpdate,
        uint256 threshold
    );
    error STALE_PUSH_PRICE(
        ID asset,
        string ticker,
        int256 price,
        uint8 oracleType,
        address feed,
        uint256 timeFromUpdate,
        uint256 threshold
    );
    error PRICE_UNSTABLE(
        uint256 primaryPrice,
        uint256 referencePrice,
        uint256 deviationPct
    );
    error ZERO_OR_STALE_VAULT_PRICE(ID, address, uint256);
    error ZERO_OR_STALE_PRICE(string ticker, uint8[2] oracles);
    error STALE_ORACLE(
        uint8 oracleType,
        address feed,
        uint256 time,
        uint256 staleTime
    );
    error ZERO_OR_NEGATIVE_PUSH_PRICE(
        ID asset,
        string ticker,
        int256 price,
        uint8 oracleType,
        address feed
    );
    error UNSUPPORTED_ORACLE(string ticker, uint8 oracle);
    error NO_PUSH_ORACLE_SET(string ticker);
    error NO_VIEW_PRICE_AVAILABLE(string ticker);
    error NOT_SUPPORTED_YET();
    error WRAP_NOT_SUPPORTED();
    error BURN_AMOUNT_OVERFLOW(ID, uint256 burnAmount, uint256 debtAmount);
    error PAUSED(address who);
    error L2_SEQUENCER_DOWN();
    error FEED_ZERO_ADDRESS(string ticker);
    error INVALID_SEQUENCER_UPTIME_FEED(address);
    error NO_MINTED_ASSETS(address who);
    error NO_COLLATERALS_DEPOSITED(address who);
    error ONLY_WHITELISTED();
    error BLACKLISTED();
    error CANNOT_RE_ENTER();
    error PYTH_ID_ZERO(string ticker);
    error ARRAY_LENGTH_MISMATCH(string ticker, uint256 arr1, uint256 arr2);
    error COLLATERAL_VALUE_GREATER_THAN_REQUIRED(
        uint256 collateralValue,
        uint256 minCollateralValue,
        uint32 ratio
    );
    error COLLATERAL_VALUE_GREATER_THAN_COVER_THRESHOLD(
        uint256 collateralValue,
        uint256 minCollateralValue,
        uint48 ratio
    );
    error ACCOUNT_COLLATERAL_TOO_LOW(
        address who,
        uint256 collateralValue,
        uint256 minCollateralValue,
        uint32 ratio
    );
    error COLLATERAL_TOO_LOW(
        uint256 collateralValue,
        uint256 minCollateralValue,
        uint32 ratio
    );
    error NOT_LIQUIDATABLE(
        address who,
        uint256 collateralValue,
        uint256 minCollateralValue,
        uint32 ratio
    );
    error CANNOT_LIQUIDATE_SELF();
    error LIQUIDATION_AMOUNT_GREATER_THAN_DEBT(
        ID repayAsset,
        uint256 repayAmount,
        uint256 availableAmount
    );
    error LIQUIDATION_SEIZED_LESS_THAN_EXPECTED(ID, uint256, uint256);
    error ZERO_VALUE_LIQUIDATION(ID repayAsset, ID seizeAsset);
    error NO_DEPOSITS(address who, ID);
    error NOT_ENOUGH_DEPOSITS(
        address who,
        ID,
        uint256 requested,
        uint256 deposits
    );
    error NOT_MINTED(address account, ID, address[] accountCollaterals);
    error NOT_DEPOSITED(address account, ID, address[] accountCollaterals);
    error ARRAY_INDEX_OUT_OF_BOUNDS(
        ID element,
        uint256 index,
        address[] elements
    );
    error ELEMENT_DOES_NOT_MATCH_PROVIDED_INDEX(
        ID element,
        uint256 index,
        address[] elements
    );
    error NO_FEES_TO_CLAIM(ID asset, address claimer);
    error REPAY_OVERFLOW(
        ID repayAsset,
        ID seizeAsset,
        uint256 invalid,
        uint256 valid
    );
    error INCOME_AMOUNT_IS_ZERO(ID incomeAsset);
    error NO_LIQUIDITY_TO_GIVE_INCOME_FOR(
        ID incomeAsset,
        uint256 userDeposits,
        uint256 totalDeposits
    );
    error NOT_ENOUGH_SWAP_DEPOSITS_TO_SEIZE(
        ID repayAsset,
        ID seizeAsset,
        uint256 invalid,
        uint256 valid
    );
    error SWAP_ROUTE_NOT_ENABLED(ID assetIn, ID assetOut);
    error RECEIVED_LESS_THAN_DESIRED(ID, uint256 invalid, uint256 valid);
    error SWAP_ZERO_AMOUNT_IN(ID tokenIn);
    error INVALID_WITHDRAW(
        ID withdrawAsset,
        uint256 sharesIn,
        uint256 assetsOut
    );
    error ROUNDING_ERROR(ID asset, uint256 sharesIn, uint256 assetsOut);
    error MAX_DEPOSIT_EXCEEDED(ID asset, uint256 assetsIn, uint256 maxDeposit);
    error COLLATERAL_AMOUNT_LOW(
        ID kopioCollateral,
        uint256 amount,
        uint256 minAmount
    );
    error MINT_VALUE_LESS_THAN_MIN_DEBT_VALUE(
        ID,
        uint256 value,
        uint256 minRequiredValue
    );
    error NOT_A_CONTRACT(address who);
    error NO_ALLOWANCE(
        address spender,
        address owner,
        uint256 requested,
        uint256 allowed
    );
    error NOT_ENOUGH_BALANCE(address who, uint256 requested, uint256 available);
    error SENDER_NOT_OPERATOR(ID, address sender, address operator);
    error ZERO_SHARES_FROM_ASSETS(ID, uint256 assets, ID);
    error ZERO_SHARES_OUT(ID, uint256 assets);
    error ZERO_SHARES_IN(ID, uint256 assets);
    error ZERO_ASSETS_FROM_SHARES(ID, uint256 shares, ID);
    error ZERO_ASSETS_OUT(ID, uint256 shares);
    error ZERO_ASSETS_IN(ID, uint256 shares);
    error ZERO_ADDRESS();
    error ZERO_DEPOSIT(ID);
    error ZERO_AMOUNT(ID);
    error ZERO_WITHDRAW(ID);
    error ZERO_MINT(ID);
    error SDI_DEBT_REPAY_OVERFLOW(uint256 debt, uint256 repay);
    error ZERO_REPAY(ID, uint256 repayAmount, uint256 seizeAmount);
    error ZERO_BURN(ID);
    error ZERO_DEBT(ID);
    error UPDATE_FEE_OVERFLOW(uint256 sent, uint256 required);
    error BatchResult(uint256 timestamp, bytes[] results);
    error Panicked(uint256 code);
}

struct LiquidateExecution {
    address account;
    uint256 repayAmount;
    uint256 seizeAmount;
    address kopio;
    address collateral;
}

struct ICDPAccount {
    uint256 totalDebtValue;
    uint256 totalCollateralValue;
    uint256 collateralRatio;
}

struct ICDPInitializer {
    uint32 liquidationThreshold;
    uint32 minCollateralRatio;
    uint256 minDebtValue;
}

struct ICDPParams {
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint32 maxLiquidationRatio;
    uint256 minDebtValue;
}

interface SEvent {
    event SCDPDeposit(
        address indexed depositor,
        address indexed collateral,
        uint256 amount,
        uint256 feeIndex,
        uint256 timestamp
    );
    event SCDPWithdraw(
        address indexed account,
        address indexed receiver,
        address indexed collateral,
        address withdrawer,
        uint256 amount,
        uint256 feeIndex,
        uint256 timestamp
    );
    event SCDPFeeReceipt(
        address indexed account,
        address indexed collateral,
        uint256 accDeposits,
        uint256 assetFeeIndex,
        uint256 accFeeIndex,
        uint256 assetLiqIndex,
        uint256 accLiqIndex,
        uint256 blockNumber,
        uint256 timestamp
    );
    event SCDPFeeClaim(
        address indexed claimer,
        address indexed receiver,
        address indexed collateral,
        uint256 feeAmount,
        uint256 newIndex,
        uint256 prevIndex,
        uint256 timestamp
    );
    event SCDPRepay(
        address indexed repayer,
        address indexed repayKopio,
        uint256 repayAmount,
        address indexed receiveKopio,
        uint256 receiveAmount,
        uint256 timestamp
    );

    event SCDPLiquidationOccured(
        address indexed liquidator,
        address indexed repayKopio,
        uint256 repayAmount,
        address indexed seizeCollateral,
        uint256 seizeAmount,
        uint256 prevLiqIndex,
        uint256 newLiqIndex,
        uint256 timestamp
    );
    event SCDPCoverOccured(
        address indexed coverer,
        address indexed asset,
        uint256 amount,
        address indexed seizeCollateral,
        uint256 seizeAmount,
        uint256 prevLiqIndex,
        uint256 newLiqIndex,
        uint256 timestamp
    );

    event PairSet(
        address indexed assetIn,
        address indexed assetOut,
        bool enabled
    );

    event FeeSet(
        address indexed asset,
        uint256 openFee,
        uint256 closeFee,
        uint256 protocolFee
    );

    event CollateralGlobalUpdate(
        address indexed collateral,
        uint256 newThreshold
    );

    event KopioGlobalUpdate(
        address indexed kopio,
        uint256 feeIn,
        uint256 feeOut,
        uint256 protocolFee,
        uint256 debtLimit
    );

    event Swap(
        address indexed who,
        address indexed assetIn,
        address indexed assetOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 timestamp
    );

    event SwapFee(
        address indexed feeAsset,
        address indexed assetIn,
        uint256 feeAmount,
        uint256 protocolFeeAmount,
        uint256 timestamp
    );

    event Income(address asset, uint256 amount);

    event GlobalLiqIncentiveUpdated(
        string indexed symbol,
        address indexed asset,
        uint256 from,
        uint256 to
    );

    event GlobalMCRUpdated(uint256 from, uint256 to);

    event GlobalLTUpdated(uint256 from, uint256 to, uint256 mlr);

    event GlobalMLRUpdated(uint256 from, uint256 to);
}

struct SCDPInitializer {
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint48 coverThreshold;
    uint48 coverIncentive;
}

struct SCDPParameters {
    address feeAsset;
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint32 maxLiquidationRatio;
    uint128 coverThreshold;
    uint128 coverIncentive;
}

struct SwapRouteSetter {
    address assetIn;
    address assetOut;
    bool enabled;
}

struct SCDPAssetData {
    uint256 debt;
    uint128 totalDeposits;
    uint128 swapDeposits;
}

struct SCDPAssetIndexes {
    uint128 currFeeIndex;
    uint128 currLiqIndex;
}

struct SCDPSeizeData {
    uint256 prevLiqIndex;
    uint128 feeIndex;
    uint128 liqIndex;
}

struct SCDPAccountIndexes {
    uint128 lastFeeIndex;
    uint128 lastLiqIndex;
    uint256 timestamp;
}

interface VEvent {
    event Deposit(
        address indexed caller,
        address indexed receiver,
        address indexed asset,
        uint256 assetsIn,
        uint256 sharesOut
    );

    event OracleSet(
        address indexed asset,
        address indexed feed,
        uint256 staletime,
        uint256 price,
        uint256 timestamp
    );

    event AssetAdded(
        address indexed asset,
        address indexed feed,
        string indexed symbol,
        uint256 staletime,
        uint256 price,
        uint256 depositLimit,
        uint256 timestamp
    );

    event AssetRemoved(address indexed asset, uint256 timestamp);

    event AssetEnabledChange(
        address indexed asset,
        bool enabled,
        uint256 timestamp
    );

    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed asset,
        address owner,
        uint256 assetsOut,
        uint256 sharesIn
    );
}

struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}

struct FacetAddressAndPosition {
    address facetAddress;
    uint96 functionSelectorPosition;
}

struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    uint256 facetAddressPosition;
}

enum FacetCutAction {
    Add,
    Replace,
    Remove
}

struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
}

struct Initializer {
    address initContract;
    bytes initData;
}

interface DTypes {
    event DiamondCut(FacetCut[] diamondCut, address initializer, bytes data);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event PendingOwnershipTransfer(
        address indexed previousOwner,
        address indexed newOwner
    );

    event InitializerExecuted(
        uint256 indexed version,
        address sender,
        address diamondOwner,
        address initializer,
        bytes data,
        uint256 facetCount,
        uint256 block,
        uint256 timestamp
    );

    error DIAMOND_FUNCTION_DOES_NOT_EXIST(bytes4 selector);
    error DIAMOND_INIT_DATA_PROVIDED_BUT_INIT_ADDRESS_WAS_ZERO(bytes data);
    error DIAMOND_INIT_ADDRESS_PROVIDED_BUT_INIT_DATA_WAS_EMPTY(
        address initializer
    );
    error DIAMOND_FUNCTION_ALREADY_EXISTS(
        address newFacet,
        address oldFacet,
        bytes4 func
    );
    error DIAMOND_INIT_FAILED(address initializer, bytes data);
    error DIAMOND_NOT_INITIALIZING();
    error DIAMOND_ALREADY_INITIALIZED(
        uint256 initializerVersion,
        uint256 currentVersion
    );
    error DIAMOND_CUT_ACTION_WAS_NOT_ADD_REPLACE_REMOVE();
    error DIAMOND_FACET_ADDRESS_CANNOT_BE_ZERO_WHEN_ADDING_FUNCTIONS(
        bytes4[] selectors
    );
    error DIAMOND_FACET_ADDRESS_CANNOT_BE_ZERO_WHEN_REPLACING_FUNCTIONS(
        bytes4[] selectors
    );
    error DIAMOND_FACET_ADDRESS_MUST_BE_ZERO_WHEN_REMOVING_FUNCTIONS(
        address facet,
        bytes4[] selectors
    );
    error DIAMOND_NO_FACET_SELECTORS(address facet);
    error DIAMOND_FACET_ADDRESS_CANNOT_BE_ZERO_WHEN_REMOVING_ONE_FUNCTION(
        bytes4 selector
    );
    error DIAMOND_REPLACE_FUNCTION_NEW_FACET_IS_SAME_AS_OLD(
        address facet,
        bytes4 selector
    );
    error NEW_OWNER_CANNOT_BE_ZERO_ADDRESS();
    error NOT_DIAMOND_OWNER(address who, address owner);
    error NOT_PENDING_DIAMOND_OWNER(address who, address pendingOwner);
}

interface IAuthorizationFacet {
    function getRoleMember(
        bytes32 role,
        uint256 index
    ) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function grantRole(bytes32 role, address account) external;

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    function renounceRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;
}

interface IBatchFacet {
    function batchCall(
        bytes[] calldata _calls,
        bytes[] calldata _updateData
    ) external payable;

    function batchStaticCall(
        bytes[] calldata _staticCalls,
        bytes[] calldata _updateData
    ) external payable returns (uint256 timestamp, bytes[] memory results);

    function batchCallToError(
        bytes[] calldata _calls,
        bytes[] calldata _updateData
    ) external payable returns (uint256, bytes[] memory);

    function decodeErrorData(
        bytes calldata _errorData
    ) external pure returns (uint256 timestamp, bytes[] memory results);
}

interface IDiamondStateFacet {
    function initialized() external view returns (bool);

    function domainSeparator() external view returns (bytes32);

    function getStorageVersion() external view returns (uint256);

    function owner() external view returns (address owner_);

    function pendingOwner() external view returns (address pendingOwner_);

    function transferOwnership(address _newOwner) external;

    function acceptOwnership() external;
}

interface IKopioIssuer {
    function issue(
        uint256 assets,
        address to
    ) external returns (uint256 shares);

    function destroy(
        uint256 assets,
        address from
    ) external returns (uint256 shares);

    function convertToShares(
        uint256 assets
    ) external view returns (uint256 shares);

    function convertToAssets(
        uint256 shares
    ) external view returns (uint256 assets);

    function convertManyToAssets(
        uint256[] calldata shares
    ) external view returns (uint256[] memory assets);

    function convertManyToShares(
        uint256[] calldata assets
    ) external view returns (uint256[] memory shares);
}

interface Multi {
    enum Action {
        ICDPDeposit,
        ICDPWithdraw,
        ICDPRepay,
        ICDPBorrow,
        SCDPDeposit,
        SCDPTrade,
        SCDPWithdraw,
        SCDPClaim,
        Unwrap,
        Wrap,
        VaultDeposit,
        VaultRedeem,
        AMMExactInput,
        WrapNative,
        UnwrapNative
    }

    struct Op {
        Action action;
        Data data;
    }

    struct Data {
        address tokenIn;
        uint96 amountIn;
        ModeIn modeIn;
        address tokenOut;
        uint96 amountOut;
        ModeOut modeOut;
        uint128 minOut;
        bytes path;
    }

    enum ModeIn {
        None,
        Native,
        Pull,
        Balance,
        UseOpIn,
        BalanceUnwrapNative,
        BalanceWrapNative,
        BalanceNative
    }

    enum ModeOut {
        None,
        ReturnNative,
        Return,
        Leave
    }

    struct Result {
        address tokenIn;
        uint256 amountIn;
        address tokenOut;
        uint256 amountOut;
    }

    error NO_MULTI_ALLOWANCE(Action action, address token, string symbol);
    error ZERO_AMOUNT_IN(Action action, address token, string symbol);
    error ZERO_NATIVE_IN(Action action);
    error VALUE_NOT_ZERO(Action action, uint256 value);
    error INVALID_NATIVE_TOKEN_IN(Action action, address token, string symbol);
    error ZERO_OR_INVALID_AMOUNT_IN(
        Action action,
        address token,
        string symbol,
        uint256 balance,
        uint256 amountOut
    );
    error INVALID_ACTION(Action action);
    error NATIVE_SYNTH_WRAP_NOT_ALLOWED(
        Action action,
        address token,
        string symbol
    );

    error TOKENS_IN_MODE_WAS_NONE_BUT_ADDRESS_NOT_ZERO(
        Action action,
        address token
    );
    error TOKENS_OUT_MODE_WAS_NONE_BUT_ADDRESS_NOT_ZERO(
        Action action,
        address token
    );

    error INSUFFICIENT_UPDATE_FEE(uint256 updateFee, uint256 amountIn);
}

interface IKopioMulticall is Multi {
    function rescue(address token, uint256 amount, address receiver) external;

    function execute(
        Op[] calldata ops,
        bytes[] calldata prices
    ) external payable returns (Result[] memory);
}

interface IMarketStatus {
    function allowed(address) external view returns (bool);

    function exchanges(bytes32) external view returns (bytes32);

    function status(bytes32) external view returns (uint256);

    function setStatus(bytes32[] calldata, bool[] calldata) external;

    function setTickers(bytes32[] calldata, bytes32[] calldata) external;

    function setAllowed(address, bool) external;

    function getExchangeStatus(bytes32) external view returns (bool);

    function getExchangeStatuses(
        bytes32[] calldata
    ) external view returns (bool[] memory);

    function getExchange(bytes32) external view returns (bytes32);

    function getTickerStatus(bytes32) external view returns (bool);

    function getTickerExchange(bytes32) external view returns (bytes32);

    function getTickerStatuses(
        bytes32[] calldata
    ) external view returns (bool[] memory);

    function owner() external view returns (address);
}

interface ISDIFacet {
    function getTotalSDIDebt() external view returns (uint256);

    function getEffectiveSDIDebtUSD() external view returns (uint256);

    function getEffectiveSDIDebt() external view returns (uint256);

    function getSDICoverAmount() external view returns (uint256);

    function previewSCDPBurn(
        address asset,
        uint256 amount,
        bool noFactors
    ) external view returns (uint256 shares);

    function previewSCDPMint(
        address asset,
        uint256 _mintAmount,
        bool noFactors
    ) external view returns (uint256 shares);

    function totalSDI() external view returns (uint256);

    function getSDIPrice() external view returns (uint256);

    function coverSCDP(
        address asset,
        uint256 amount,
        bytes[] calldata prices
    ) external payable returns (uint256 value);

    function coverWithIncentiveSCDP(
        address asset,
        uint256 amount,
        address seizeAsset,
        bytes[] calldata prices
    ) external payable returns (uint256 value, uint256 seizedAmount);

    function enableCoverAssetSDI(address asset) external;

    function disableCoverAssetSDI(address asset) external;

    function setCoverRecipientSDI(address _coverRecipient) external;

    function getCoverAssetsSDI() external view returns (address[] memory);
}

interface IVaultExtender {
    event Deposit(address indexed _from, address indexed _to, uint256 _amount);
    event Withdraw(address indexed _from, address indexed _to, uint256 _amount);

    function vaultDeposit(
        address _assetAddr,
        uint256 _assets,
        address _receiver
    ) external returns (uint256 sharesOut, uint256 assetFee);

    function vaultMint(
        address _assetAddr,
        uint256 _shares,
        address _receiver
    ) external returns (uint256 assetsIn, uint256 assetFee);

    function vaultWithdraw(
        address _assetAddr,
        uint256 _assets,
        address _receiver,
        address _owner
    ) external returns (uint256 sharesIn, uint256 assetFee);

    function vaultRedeem(
        address _assetAddr,
        uint256 _shares,
        address _receiver,
        address _owner
    ) external returns (uint256 assetsOut, uint256 assetFee);

    function maxRedeem(
        address assetAddr,
        address owner
    ) external view returns (uint256 max, uint256 fee);

    function deposit(uint256 _shares, address _receiver) external;

    function withdraw(uint256 _amount, address _receiver) external;

    function withdrawFrom(address _from, address _to, uint256 _amount) external;
}

interface IVaultRateProvider {
    function exchangeRate() external view returns (uint256);
}

interface MEvent {
    event CollateralAdded(
        string indexed ticker,
        string indexed symbol,
        address indexed collateral,
        uint256 factor,
        address share,
        uint256 liqIncentive
    );

    event CollateralUpdated(
        string indexed ticker,
        string indexed symbol,
        address indexed collateral,
        uint256 factor,
        address share,
        uint256 liqIncentive
    );

    event CollateralDeposited(
        address indexed account,
        address indexed collateral,
        uint256 amount
    );

    event CollateralWithdrawn(
        address indexed account,
        address indexed collateral,
        uint256 amount
    );
    event CollateralFlashWithdrawn(
        address indexed account,
        address indexed collateral,
        uint256 amount
    );

    event KopioAdded(
        string indexed ticker,
        string indexed symbol,
        address indexed kopio,
        address share,
        uint256 dFactor,
        uint256 icdpLimit,
        uint256 closeFee,
        uint256 openFee
    );

    event KopioUpdated(
        string indexed ticker,
        string indexed symbol,
        address indexed kopio,
        address share,
        uint256 dFactor,
        uint256 icdpLimit,
        uint256 closeFee,
        uint256 openFee
    );

    event KopioMinted(
        address indexed account,
        address indexed kopio,
        uint256 amount,
        address receiver
    );

    event KopioBurned(
        address indexed account,
        address indexed kopio,
        uint256 amount
    );

    event CFactorUpdated(
        string indexed symbol,
        address indexed collateral,
        uint256 from,
        uint256 to
    );
    event DFactorUpdated(
        string indexed symbol,
        address indexed kopio,
        uint256 from,
        uint256 to
    );

    event DebtPositionClosed(
        address indexed account,
        address indexed kopio,
        uint256 amount
    );

    event FeePaid(
        address indexed account,
        address indexed collateral,
        uint256 indexed feeType,
        uint256 amount,
        uint256 value,
        uint256 valueRemaining
    );

    event LiquidationOccurred(
        address indexed account,
        address indexed liquidator,
        address indexed kopio,
        uint256 amount,
        address seizedCollateral,
        uint256 seizedAmount
    );

    event SafetyStateChange(
        Enums.Action indexed action,
        string indexed symbol,
        address indexed asset,
        string description
    );

    event FeeRecipientUpdated(address from, address to);

    event LiquidationIncentiveUpdated(
        string indexed symbol,
        address indexed collateral,
        uint256 from,
        uint256 to
    );

    event MinCollateralRatioUpdated(uint256 from, uint256 to);

    event MinimumDebtValueUpdated(uint256 from, uint256 to);

    event LiquidationThresholdUpdated(uint256 from, uint256 to, uint256 mlr);
    event MaxLiquidationRatioUpdated(uint256 from, uint256 to);
}

struct DiamondState {
    mapping(bytes4 selector => FacetAddressAndPosition) selectorToFacetAndPosition;
    mapping(address facet => FacetFunctionSelectors) facetFunctionSelectors;
    address[] facetAddresses;
    mapping(bytes4 => bool) supportedInterfaces;
    address self;
    bool initialized;
    uint8 initializing;
    bytes32 diamondDomainSeparator;
    address contractOwner;
    address pendingOwner;
    uint96 storageVersion;
}

// keccak256(abi.encode(uint256(keccak256("kopio.slot.diamond")) - 1)) & ~bytes32(uint256(0xff));
bytes32 constant DIAMOND_SLOT = 0xc8ecce9aacc3428c4044cc49a9f54752635242cfef8d73e0144ec29b0ac16a00;

function ds() pure returns (DiamondState storage state) {
    bytes32 position = DIAMOND_SLOT;
    assembly {
        state.slot := position
    }
}

interface IDiamondCutFacet {
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _initializer,
        bytes calldata _calldata
    ) external;
}

interface IExtendedDiamondCutFacet is IDiamondCutFacet {
    function executeInitializer(
        address _initializer,
        bytes calldata _calldata
    ) external;

    function executeInitializers(Initializer[] calldata _initializers) external;
}

interface IDiamondLoupeFacet {
    function facets() external view returns (Facet[] memory facets_);

    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory facetFunctionSelectors_);

    function facetAddresses()
        external
        view
        returns (address[] memory facetAddresses_);

    function facetAddress(
        bytes4 _functionSelector
    ) external view returns (address facetAddress_);
}

interface IICDPBurnFacet {
    function burnKopio(
        BurnArgs memory args,
        bytes[] calldata prices
    ) external payable;
}

interface IICDPCollateralFacet {
    function depositCollateral(
        address account,
        address collateral,
        uint256 amount
    ) external payable;

    function withdrawCollateral(
        WithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;

    function flashWithdrawCollateral(
        FlashWithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;
}

interface IICDPConfigFacet {
    function initializeICDP(ICDPInitializer calldata args) external;

    function setMinDebtValue(uint256 newValue) external;

    function setLiqIncentive(address collateral, uint16 newIncentive) external;

    function setMCR(uint32 newMCR) external;

    function setLT(uint32 newLT) external;

    function setMLR(uint32 newMLR) external;
}

interface IICDPMintFacet {
    function mintKopio(
        MintArgs memory args,
        bytes[] calldata prices
    ) external payable;
}

interface IICDPStateFacet {
    function getLT() external view returns (uint32);

    function getMLR() external view returns (uint32);

    function getMinDebtValue() external view returns (uint256);

    function getMCR() external view returns (uint32);

    function getKopioExists(address addr) external view returns (bool);

    function getCollateralExists(address addr) external view returns (bool);

    function getICDPParams() external view returns (ICDPParams memory);

    function getMintedSupply(address) external view returns (uint256);

    function getCollateralValueWithPrice(
        address collateral,
        uint256 amount
    )
        external
        view
        returns (uint256 value, uint256 adjustedValue, uint256 price);

    function getDebtValueWithPrice(
        address asset,
        uint256 amount
    )
        external
        view
        returns (uint256 value, uint256 adjustedValue, uint256 price);
}

interface ISCDPConfigFacet {
    function initializeSCDP(SCDPInitializer memory _init) external;

    function getGlobalParameters()
        external
        view
        returns (SCDPParameters memory);

    function setGlobalIncome(address collateral) external;

    function setGlobalMCR(uint32 newMCR) external;

    function setGlobalLT(uint32 newLT) external;

    function setGlobalMLR(uint32 newMLR) external;

    function setGlobalLiqIncentive(address kopio, uint16 newIncentive) external;

    function setGlobalDepositLimit(
        address collateral,
        uint256 newLimit
    ) external;

    function setGlobalDepositEnabled(address collateral, bool enabled) external;

    function setGlobalCollateralEnabled(address asset, bool enabled) external;

    function setSwapEnabled(address kopio, bool enabled) external;

    function setSwapFees(
        address kopio,
        uint16 feeIn,
        uint16 feeOut,
        uint16 protocolShare
    ) external;

    function setSwapRoutes(SwapRouteSetter[] calldata routes) external;

    function setSwapRoute(SwapRouteSetter calldata route) external;
}

interface ISCDPStateFacet {
    function getAccountDepositSCDP(
        address account,
        address collateral
    ) external view returns (uint256);

    function getAccountFeesSCDP(
        address account,
        address collateral
    ) external view returns (uint256);

    function getAccountTotalFeesValueSCDP(
        address account
    ) external view returns (uint256);

    function getAccountDepositValueSCDP(
        address account,
        address collateral
    ) external view returns (uint256);

    function getAssetIndexesSCDP(
        address collateral
    ) external view returns (SCDPAssetIndexes memory);

    function getAccountTotalDepositsValueSCDP(
        address account
    ) external view returns (uint256);

    function getDepositsSCDP(
        address collateral
    ) external view returns (uint256);

    function getSwapDepositsSCDP(
        address collateral
    ) external view returns (uint256);

    function getCollateralValueSCDP(
        address collateral,
        bool noFactors
    ) external view returns (uint256);

    function getTotalCollateralValueSCDP(
        bool noFactors
    ) external view returns (uint256);

    function getCollateralsSCDP() external view returns (address[] memory);

    function getKopiosSCDP() external view returns (address[] memory);

    function getDebtSCDP(address asset) external view returns (uint256);

    function getDebtValueSCDP(
        address asset,
        bool noFactors
    ) external view returns (uint256);

    function getTotalDebtValueSCDP(
        bool noFactors
    ) external view returns (uint256);

    function getGlobalDepositEnabled(
        address asset
    ) external view returns (bool);

    function getRouteEnabled(
        address assetIn,
        address assetOut
    ) external view returns (bool);

    function getSwapEnabled(address addr) external view returns (bool);

    function getGlobalCollateralRatio() external view returns (uint256);
}

interface ISwapFacet {
    function previewSwapSCDP(
        address assetIn,
        address assetOut,
        uint256 amountIn
    )
        external
        view
        returns (uint256 amountOut, uint256 feeAmount, uint256 protocolFee);

    function swapSCDP(SwapArgs calldata args) external payable;

    function addGlobalIncome(
        address collateral,
        uint256 amount
    ) external payable returns (uint256 nextLiquidityIndex);
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

interface IICDPAccountStateFacet {
    // ExpectedFeeRuntimeInfo is used for stack size optimization
    struct ExpectedFeeRuntimeInfo {
        address[] assets;
        uint256[] amounts;
        uint256 collateralTypeCount;
    }

    function getAccountLiquidatable(
        address account
    ) external view returns (bool);

    function getAccountState(
        address account
    ) external view returns (ICDPAccount memory);

    function getAccountMintedAssets(
        address account
    ) external view returns (address[] memory);

    function getAccountMintIndex(
        address account,
        address asset
    ) external view returns (uint256);

    function getAccountTotalDebtValues(
        address account
    ) external view returns (uint256 value, uint256 valueAdjusted);

    function getAccountTotalDebtValue(
        address account
    ) external view returns (uint256);

    function getAccountDebtAmount(
        address account,
        address asset
    ) external view returns (uint256);

    function getAccountCollateralValues(
        address account,
        address asset
    )
        external
        view
        returns (uint256 value, uint256 valueAdjusted, uint256 price);

    function getAccountTotalCollateralValue(
        address account
    ) external view returns (uint256 valueAdjusted);

    function getAccountTotalCollateralValues(
        address account
    ) external view returns (uint256 value, uint256 valueAdjusted);

    function getAccountMinCollateralAtRatio(
        address account,
        uint32 ratio
    ) external view returns (uint256);

    function getAccountCollateralRatio(
        address account
    ) external view returns (uint256 ratio);

    function getAccountCollateralRatios(
        address[] memory accounts
    ) external view returns (uint256[] memory);

    function getAccountDepositIndex(
        address account,
        address collateral
    ) external view returns (uint256 i);

    function getAccountCollateralAssets(
        address account
    ) external view returns (address[] memory);

    function getAccountCollateralAmount(
        address account,
        address asset
    ) external view returns (uint256);

    function previewFee(
        address account,
        address kopio,
        uint256 amount,
        Enums.ICDPFee feeType
    ) external view returns (address[] memory assets, uint256[] memory amounts);
}

interface IERC4626 {
    function asset() external view returns (IKopio);

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

    function convertToShares(
        uint256 assets
    ) external view returns (uint256 shares);

    function convertToAssets(
        uint256 shares
    ) external view returns (uint256 assets);

    function deposit(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares);

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256 assets);

    function maxRedeem(address owner) external view returns (uint256 assets);

    function maxWithdraw(address owner) external view returns (uint256 assets);

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

    function totalAssets() external view returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
}

interface IEmitted is err, DTypes, MEvent, SEvent, VEvent, Multi {
    error DeploymentFailed();

    error InitializationFailed();

    error BatchRevertSilentOrCustomError(bytes innerError);
    error CreateProxyPreview(address proxy);
    error CreateProxyAndLogicPreview(address proxy, address implementation);
    error ArrayLengthMismatch(
        uint256 proxies,
        uint256 implementations,
        uint256 datas
    );
    error DeployerAlreadySet(address, bool);
}

interface IGnosisSafeL2 {
    function isOwner(address owner) external view returns (bool);

    function getOwners() external view returns (address[] memory);
}

struct CommonState {
    mapping(address asset => Asset) assets;
    mapping(bytes32 ticker => mapping(Enums.OracleType provider => Oracle)) oracles;
    mapping(address asset => mapping(Enums.Action action => SafetyState)) safetyState;
    address feeRecipient;
    address pythEp;
    address sequencerUptimeFeed;
    uint32 sequencerGracePeriodTime;
    uint16 maxPriceDeviationPct;
    uint8 oracleDecimals;
    bool safetyStateSet;
    uint256 entered;
    mapping(bytes32 role => RoleData data) _roles;
    mapping(bytes32 role => EnumerableSet.AddressSet member) _roleMembers;
    address marketStatusProvider;
}

// keccak256(abi.encode(uint256(keccak256("kopio.slot.common")) - 1)) & ~bytes32(uint256(0xff));
bytes32 constant COMMON_SLOT = 0xfc1d014d58da005150440e1217b5f770417f3480965a1e2032e843d013624600;

function cs() pure returns (CommonState storage state) {
    bytes32 position = bytes32(COMMON_SLOT);
    assembly {
        state.slot := position
    }
}

struct Oracle {
    address feed;
    bytes32 pythId;
    uint256 staleTime;
    bool invertPyth;
    bool isClosable;
}

struct FeedConfiguration {
    Enums.OracleType[2] oracleIds;
    address[2] feeds;
    uint256[2] staleTimes;
    bytes32 pythId;
    bool invertPyth;
    bool isClosable;
}

struct Asset {
    bytes32 ticker;
    address share;
    Enums.OracleType[2] oracles;
    uint16 factor;
    uint16 dFactor;
    uint16 openFee;
    uint16 closeFee;
    uint16 liqIncentive;
    uint256 mintLimit;
    uint256 mintLimitSCDP;
    uint256 depositLimitSCDP;
    uint16 swapInFee;
    uint16 swapOutFee;
    uint16 protocolFeeShareSCDP;
    uint16 liqIncentiveSCDP;
    uint8 decimals;
    bool isCollateral;
    bool isKopio;
    bool isGlobalDepositable;
    bool isSwapMintable;
    bool isGlobalCollateral;
    bool isCoverAsset;
}

struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
}

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

struct RawPrice {
    int256 answer;
    uint256 timestamp;
    uint256 staleTime;
    bool isStale;
    bool isZero;
    Enums.OracleType oracle;
    address feed;
}

struct Pause {
    bool enabled;
    uint256 timestamp0;
    uint256 timestamp1;
}

struct SafetyState {
    Pause pause;
}

struct CommonInitializer {
    address admin;
    address council;
    address treasury;
    uint16 maxPriceDeviationPct;
    uint8 oracleDecimals;
    uint32 sequencerGracePeriodTime;
    address sequencerUptimeFeed;
    address pythEp;
    address marketStatusProvider;
}

struct ICDPState {
    mapping(address account => address[]) collateralsOf;
    mapping(address account => mapping(address collateral => uint256)) deposits;
    mapping(address account => mapping(address kopio => uint256)) debt;
    mapping(address account => address[]) mints;
    address[] kopios;
    address[] collaterals;
    address feeRecipient;
    uint32 maxLiquidationRatio;
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint256 minDebtValue;
}

// keccak256(abi.encode(uint256(keccak256("kopio.slot.icdp")) - 1)) & ~bytes32(uint256(0xff));
bytes32 constant ICDP_SLOT = 0xa8f8248bd2623d2ac4f9086213698319675a053d994914e3b428d54e1b894d00;

function ms() pure returns (ICDPState storage state) {
    bytes32 position = ICDP_SLOT;
    assembly {
        state.slot := position
    }
}

struct SCDPState {
    address[] collaterals;
    address[] kopios;
    mapping(address assetIn => mapping(address assetOut => bool)) isRoute;
    mapping(address asset => bool enabled) isEnabled;
    mapping(address asset => SCDPAssetData) assetData;
    mapping(address account => mapping(address collateral => uint256 amount)) deposits;
    mapping(address account => mapping(address collateral => uint256 amount)) depositsPrincipal;
    mapping(address collateral => SCDPAssetIndexes) assetIndexes;
    mapping(address account => mapping(address collateral => SCDPAccountIndexes)) accountIndexes;
    mapping(address account => mapping(uint256 liqIndex => SCDPSeizeData)) seizeEvents;
    address feeAsset;
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint32 maxLiquidationRatio;
}

struct SDIState {
    uint256 totalDebt;
    uint256 totalCover;
    address coverRecipient;
    uint48 coverThreshold;
    uint48 coverIncentive;
    address[] coverAssets;
}

// keccak256(abi.encode(uint256(keccak256("kopio.slot.scdp")) - 1)) & ~bytes32(uint256(0xff));
bytes32 constant SCDP_SLOT = 0xd405b07e7e3f6f53febc8186644ff1e0824332653a01e9279bde7f3bfc6b7600;
// keccak256(abi.encode(uint256(keccak256("kopio.slot.sdi")) - 1)) & ~bytes32(uint256(0xff));
bytes32 constant SDI_SLOT = 0x815abab76eb0df79b12d9cc625bb13a185c396fdf9ccb04c9f8a7a4e9d419600;

function scdp() pure returns (SCDPState storage state) {
    bytes32 position = SCDP_SLOT;
    assembly {
        state.slot := position
    }
}

function sdi() pure returns (SDIState storage state) {
    bytes32 position = SDI_SLOT;
    assembly {
        state.slot := position
    }
}

interface IAssetConfigFacet {
    function addAsset(
        address addr,
        Asset memory cfg,
        FeedConfiguration memory feeds
    ) external returns (Asset memory);

    function updateAsset(
        address addr,
        Asset memory cfg
    ) external returns (Asset memory);

    function setCFactor(address asset, uint16 newFactor) external;

    function setDFactor(address asset, uint16 newDFactor) external;

    function validateAssetConfig(
        address addr,
        Asset memory cfg
    ) external view returns (bool);

    function setOracleTypes(
        address addr,
        Enums.OracleType[2] memory types
    ) external;
}

interface IAssetStateFacet {
    function getAssetAddresses(uint8) external view returns (address[] memory);

    function getAsset(address addr) external view returns (Asset memory);

    function getPrice(address addr) external view returns (uint256);
    function getPriceUnchecked(address addr) external view returns (uint256);

    function getPushPrice(address addr) external view returns (RawPrice memory);

    function getValue(
        address addr,
        uint256 amount
    ) external view returns (uint256);

    function getFeedForAddress(
        address addr,
        Enums.OracleType oracle
    ) external view returns (address feedAddr);

    function getMarketStatus(address addr) external view returns (bool);
}

interface ICommonConfigFacet {
    struct PythConfig {
        bytes32[] pythIds;
        uint256[] staleTimes;
        bool[] invertPyth;
        bool[] isClosables;
    }

    function setFeeRecipient(address recipient) external;

    function setPythEndpoint(address addr) external;

    function setOracleDecimals(uint8 dec) external;

    function setOracleDeviation(uint16 newDeviation) external;

    function setSequencerUptimeFeed(address newFeed) external;

    function setSequencerGracePeriod(uint32 newGracePeriod) external;

    function setFeedsForTicker(
        bytes32 ticker,
        FeedConfiguration memory feedCfg
    ) external;

    function setChainlinkFeeds(
        bytes32[] calldata tickers,
        address[] calldata feeds,
        uint256[] memory staleTimes,
        bool[] calldata isClosings
    ) external;

    function setAPI3Feeds(
        bytes32[] calldata tickers,
        address[] calldata feeds,
        uint256[] memory staleTimes,
        bool[] calldata isClosings
    ) external;

    function setVaultFeed(bytes32 ticker, address vault) external;

    function setPythFeeds(
        bytes32[] calldata tickers,
        PythConfig calldata pythCfg
    ) external;

    function setPythFeed(
        bytes32 ticker,
        bytes32 pythId,
        bool invert,
        uint256 staleTime,
        bool isClosable
    ) external;

    function setChainLinkFeed(
        bytes32 ticker,
        address feed,
        uint256 staleTime,
        bool isClosable
    ) external;

    function setAPI3Feed(
        bytes32 ticker,
        address feed,
        uint256 _staleTime,
        bool _isClosable
    ) external;

    function setMarketStatusProvider(address newProvider) external;
}

interface ICommonStateFacet {
    function getFeeRecipient() external view returns (address);

    function getPythEndpoint() external view returns (address);

    function getOracleDecimals() external view returns (uint8);

    function getOracleDeviationPct() external view returns (uint16);

    function getMarketStatusProvider() external view returns (address);

    function getSequencerUptimeFeed() external view returns (address);

    function getSequencerGracePeriod() external view returns (uint32);

    function getOracleOfTicker(
        bytes32 _ticker,
        Enums.OracleType _oracleType
    ) external view returns (Oracle memory);

    function getChainlinkPrice(bytes32 _ticker) external view returns (uint256);

    function getVaultPrice(bytes32 _ticker) external view returns (uint256);

    function getAPI3Price(bytes32 _ticker) external view returns (uint256);

    function getPythPrice(bytes32 _ticker) external view returns (uint256);
}

interface ISafetyCouncilFacet {
    function toggleAssetsPaused(
        address[] memory _assets,
        Enums.Action _action,
        bool _withDuration,
        uint256 _duration
    ) external;

    function setSafetyStateSet(bool val) external;

    function safetyStateSet() external view returns (bool);

    function safetyStateFor(
        address _assetAddr,
        Enums.Action _action
    ) external view returns (SafetyState memory);

    function assetActionPaused(
        Enums.Action _action,
        address _assetAddr
    ) external view returns (bool);
}

interface TData {
    struct TPosAll {
        uint256 amountColl;
        address addr;
        string symbol;
        uint256 amountCollFees;
        uint256 valColl;
        uint256 valCollAdj;
        uint256 valCollFees;
        uint256 amountDebt;
        uint256 valDebt;
        uint256 valDebtAdj;
        uint256 amountSwapDeposit;
        uint256 price;
    }

    struct STotals {
        uint256 valColl;
        uint256 valCollAdj;
        uint256 valFees;
        uint256 valDebt;
        uint256 valDebtAdj;
        uint256 sdiPrice;
        uint256 cr;
    }

    struct Protocol {
        SCDP scdp;
        ICDP icdp;
        TAsset[] assets;
        uint32 seqGracePeriod;
        address pythEp;
        uint32 maxDeviation;
        uint8 oracleDecimals;
        uint32 seqStartAt;
        bool safety;
        bool seqUp;
        uint32 time;
        uint256 blockNr;
        uint256 tvl;
    }

    struct Account {
        address addr;
        Balance[] bals;
        IAccount icdp;
        SAccount scdp;
    }

    struct Balance {
        address addr;
        string name;
        address token;
        string symbol;
        uint256 amount;
        uint256 val;
        uint8 decimals;
    }

    struct ICDP {
        uint32 MCR;
        uint32 LT;
        uint32 MLR;
        uint256 minDebtValue;
    }

    struct SCDP {
        uint32 MCR;
        uint32 LT;
        uint32 MLR;
        SDeposit[] deposits;
        TPos[] debts;
        STotals totals;
        uint32 coverIncentive;
        uint32 coverThreshold;
    }

    struct Synthwrap {
        address token;
        uint256 openFee;
        uint256 closeFee;
    }

    struct IAccount {
        ITotals totals;
        TPos[] deposits;
        TPos[] debts;
    }

    struct ITotals {
        uint256 valColl;
        uint256 valDebt;
        uint256 cr;
    }

    struct SAccountTotals {
        uint256 valColl;
        uint256 valFees;
    }

    struct SAccount {
        address addr;
        SAccountTotals totals;
        SDepositUser[] deposits;
    }

    struct SDeposit {
        uint256 amount;
        address addr;
        string symbol;
        uint256 amountSwapDeposit;
        uint256 amountFees;
        uint256 val;
        uint256 valAdj;
        uint256 valFees;
        uint256 feeIndex;
        uint256 liqIndex;
        uint256 price;
    }

    struct SDepositUser {
        uint256 amount;
        address addr;
        string symbol;
        uint256 amountFees;
        uint256 val;
        uint256 feeIndexAccount;
        uint256 feeIndexCurrent;
        uint256 liqIndexAccount;
        uint256 liqIndexCurrent;
        uint256 accIndexTime;
        uint256 valFees;
        uint256 price;
    }

    struct TAsset {
        IKopio.Wraps wrap;
        RawPrice priceRaw;
        string name;
        string symbol;
        address addr;
        bool isMarketOpen;
        uint256 tSupply;
        uint256 mSupply;
        uint256 price;
        Asset config;
    }

    struct TPos {
        uint256 amount;
        address addr;
        string symbol;
        uint256 amountAdj;
        uint256 val;
        uint256 valAdj;
        int256 index;
        uint256 price;
    }
}

interface IDataViewFacet is TData {
    function aDataProtocol(
        PythView calldata prices
    ) external view returns (Protocol memory);

    function aDataAccount(
        PythView calldata prices,
        address account
    ) external view returns (Account memory);

    function iDataAccounts(
        PythView calldata prices,
        address[] memory accounts
    ) external view returns (IAccount[] memory);

    function sDataAccount(
        PythView calldata prices,
        address account
    ) external view returns (SAccount memory);

    function sDataAccounts(
        PythView calldata prices,
        address[] memory accounts,
        address[] memory assets
    ) external view returns (SAccount[] memory);

    function sDataAssets(
        PythView calldata prices,
        address[] memory assets
    ) external view returns (TPosAll[] memory);
}

interface IICDPLiquidationFacet {
    function liquidate(LiquidationArgs calldata args) external payable;

    function getMaxLiqValue(
        address account,
        address kopio,
        address collateral
    ) external view returns (MaxLiqInfo memory);
}

interface ISCDPFacet {
    function depositSCDP(
        address account,
        address collateral,
        uint256 amount
    ) external payable;

    function withdrawSCDP(
        SCDPWithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;

    function emergencyWithdrawSCDP(
        SCDPWithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;

    function claimFeesSCDP(
        address account,
        address collateral,
        address receiver
    ) external payable returns (uint256 fees);

    function repaySCDP(SCDPRepayArgs calldata args) external payable;

    function liquidateSCDP(
        SCDPLiquidationArgs memory args,
        bytes[] calldata prices
    ) external payable;

    function getMaxLiqValueSCDP(
        address kopio,
        address collateral
    ) external view returns (MaxLiqInfo memory);

    function getLiquidatableSCDP() external view returns (bool);
}

interface IKopioCore is
    IEmitted,
    IDiamondCutFacet,
    IDiamondLoupeFacet,
    IDiamondStateFacet,
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
    IICDPBurnFacet,
    ISafetyCouncilFacet,
    IICDPConfigFacet,
    IICDPMintFacet,
    IICDPStateFacet,
    IICDPCollateralFacet,
    IICDPAccountStateFacet,
    IICDPLiquidationFacet,
    IDataViewFacet,
    IBatchFacet
{}
