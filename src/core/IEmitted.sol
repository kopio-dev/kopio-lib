// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// src/contracts/core/common/Constants.sol

/* -------------------------------------------------------------------------- */
/*                                    Enums                                   */
/* -------------------------------------------------------------------------- */
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
    /// @dev Set the initial value to 1, (not hindering possible gas refunds by setting it to 0 on exit).
    uint8 internal constant NOT_ENTERED = 1;
    uint8 internal constant ENTERED = 2;
    uint8 internal constant NOT_INITIALIZING = 1;
    uint8 internal constant INITIALIZING = 2;

    /// @dev The min oracle decimal precision
    uint256 internal constant MIN_ORACLE_DECIMALS = 8;
    /// @dev The minimum collateral amount for a asset.
    uint256 internal constant MIN_COLLATERAL = 1e12;

    /// @dev The maximum configurable minimum debt USD value. 8 decimals.
    uint256 internal constant MAX_MIN_DEBT_VALUE = 1_000 * 1e8; // $1,000
}

library Percents {
    uint16 internal constant ONE = 0.01e4;
    uint16 internal constant HUNDRED = 1e4;
    uint16 internal constant TWENTY_FIVE = 0.25e4;
    uint16 internal constant FIFTY = 0.50e4;
    uint16 internal constant MAX_DEVIATION = TWENTY_FIVE;

    uint16 internal constant BASIS_POINT = 1;
    /// @dev The maximum configurable close fee.
    uint16 internal constant MAX_CLOSE_FEE = 0.25e4; // 25%

    /// @dev The maximum configurable open fee.
    uint16 internal constant MAX_OPEN_FEE = 0.25e4; // 25%

    /// @dev The maximum configurable protocol fee per asset for collateral pool swaps.
    uint16 internal constant MAX_SCDP_FEE = 0.5e4; // 50%

    /// @dev The minimum configurable minimum collateralization ratio.
    uint16 internal constant MIN_LT = HUNDRED + ONE; // 101%
    uint16 internal constant MIN_MCR = HUNDRED + ONE + ONE; // 102%

    /// @dev The minimum configurable liquidation incentive multiplier.
    /// This means liquidator only receives equal amount of collateral to debt repaid.
    uint16 internal constant MIN_LIQ_INCENTIVE = HUNDRED;

    /// @dev The maximum configurable liquidation incentive multiplier.
    /// This means liquidator receives 25% bonus collateral compared to the debt repaid.
    uint16 internal constant MAX_LIQ_INCENTIVE = 1.25e4; // 125%
}

// src/contracts/core/common/Errors.sol

// solhint-disable

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
    error ASSET_DOESNT_EXIST(address);
    error NOT_INCOME_ASSET(address);
    error ASSET_ALREADY_EXISTS(ID);
    error VOID_ASSET();
    error CANNOT_REMOVE_COLLATERAL_THAT_HAS_USER_DEPOSITS(ID);
    error CANNOT_REMOVE_SWAPPABLE_ASSET_THAT_HAS_DEBT(ID);
    error INVALID_CONTRACT_KOPIO(ID kopio);
    error INVALID_CONTRACT_KOPIO_SHARE(ID share, ID kopio);
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
    error MLR_CANNOT_BE_LESS_THAN_LIQ_THRESHOLD(uint256 mlt, uint256 lt);
    error INVALID_LIQ_THRESHOLD(uint256 lt, uint256 min, uint256 max);
    error INVALID_PROTOCOL_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_ASSET_FEE(ID, uint256 invalid, uint256 valid);
    error INVALID_ORACLE_DEVIATION(uint256 invalid, uint256 valid);
    error INVALID_ORACLE_TYPE(uint8 invalid);
    error INVALID_FEE_RECIPIENT(address invalid);
    error INVALID_LIQ_INCENTIVE(ID, uint256 invalid, uint256 min, uint256 max);
    error INVALID_KFACTOR(ID, uint256 invalid, uint256 valid);
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
    error ACCOUNT_COLLATERAL_VALUE_LESS_THAN_REQUIRED(
        address who,
        uint256 collateralValue,
        uint256 minCollateralValue,
        uint32 ratio
    );
    error COLLATERAL_VALUE_LESS_THAN_REQUIRED(
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
    error LIQUIDATION_VALUE_IS_ZERO(ID repayAsset, ID seizeAsset);
    error ACCOUNT_HAS_NO_DEPOSITS(address who, ID);
    error WITHDRAW_AMOUNT_GREATER_THAN_DEPOSITS(
        address who,
        ID,
        uint256 requested,
        uint256 deposits
    );
    error ACCOUNT_KOPIO_NOT_FOUND(
        address account,
        ID,
        address[] accountCollaterals
    );
    error ACCOUNT_COLLATERAL_NOT_FOUND(
        address account,
        ID,
        address[] accountCollaterals
    );
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
    /**
     * @notice Cannot directly rethrow or redeclare panic errors in try/catch - so using a similar error instead.
     * @param code The panic code received.
     */
    error Panicked(uint256 code);
}

// src/contracts/core/diamond/Types.sol

struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}

struct FacetAddressAndPosition {
    address facetAddress;
    // position in facetFunctionSelectors.functionSelectors array
    uint96 functionSelectorPosition;
}

struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    // position of facetAddress in facetAddresses array
    uint256 facetAddressPosition;
}

/// @dev  Add=0, Replace=1, Remove=2
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

    /**
     * @notice Emitted when `execute` is called with some initializer.
     * @dev Overlaps DiamondCut but thats fine as its used by some indexers.
     * @param version Resulting new diamond storage version.
     * @param sender Caller of this execution.
     * @param initializer Contract containing the execution logic.
     * @param data Bytes passed to the initializer contract.
     * @param diamondOwner Diamond owner at the time of execution.
     * @param facetCount Facet count at the time of execution.
     * @param block Block number of the call.
     * @param timestamp Timestamp of the call.
     */
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

// src/contracts/core/periphery/IKopioMulticall.sol

interface Multi {
    /**
     * @notice The action for an operation.
     */
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

    /**
     * @notice An operation to execute.
     * @param action The operation to execute.
     * @param data The data for the operation.
     */
    struct Op {
        Action action;
        Data data;
    }

    /**
     * @notice Data for an operation.
     * @param tokenIn The tokenIn to use, or address(0) if none.
     * @param amountIn The amount of tokenIn to use, or 0 if none.
     * @param modeIn The mode for tokensIn.
     * @param tokenOut The tokenOut to use, or address(0) if none.
     * @param amountOut The amount of tokenOut to use, or 0 if none.
     * @param modeOut The mode for tokensOut.
     * @param minOut The minimum amount of tokenOut to receive, or 0 if none.
     * @param idx internal index for protocol actions, eg. burn
     * @param path The path for the Uniswap V3 swap, or empty if none.
     */
    struct Data {
        address tokenIn;
        uint96 amountIn;
        ModeIn modeIn;
        address tokenOut;
        uint96 amountOut;
        ModeOut modeOut;
        uint128 minOut;
        uint128 idx;
        bytes path;
    }

    /**
     * @notice The token in mode for an operation.
     * @param None Operation requires no tokens in.
     * @param Pull Operation pulls tokens in from sender.
     * @param Balance Operation uses the existing contract balance for tokens in.
     * @param UseOpIn Operation uses the existing contract balance for tokens in, but only the amountIn specified.
     */
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

    /**
     * @notice The token out mode for an operation.
     * @param None Operation requires no tokens out.
     * @param ReturnToSenderNative Operation will unwrap and transfer native to sender.
     * @param ReturnToSender Operation returns tokens received to sender.
     * @param LeaveInContract Operation leaves tokens received in the contract for later use.
     */
    enum ModeOut {
        None,
        ReturnNative,
        Return,
        Leave
    }

    /**
     * @notice The result of an operation.
     * @param tokenIn The tokenIn to use.
     * @param amountIn The amount of tokenIn used.
     * @param tokenOut The tokenOut to receive from the operation.
     * @param amountOut The amount of tokenOut received.
     */
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

// src/contracts/core/scdp/Event.sol

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

    // Emitted when a swap pair is disabled / enabled.
    event PairSet(
        address indexed assetIn,
        address indexed assetOut,
        bool enabled
    );
    // Emitted when a asset fee is updated.
    event FeeSet(
        address indexed asset,
        uint256 openFee,
        uint256 closeFee,
        uint256 protocolFee
    );

    // Emitted on global configuration updates.
    event CollateralGlobalUpdate(
        address indexed collateral,
        uint256 newThreshold
    );

    // Emitted on global configuration updates.
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

    /**
     * @notice Emitted when liquidation incentive multiplier is updated for a kopio.
     * @param symbol token symbol
     * @param asset address of the kopio
     * @param from previous multiplier
     * @param to the new multiplier
     */
    event GlobalLiqIncentiveUpdated(
        string indexed symbol,
        address indexed asset,
        uint256 from,
        uint256 to
    );

    /**
     * @notice Emitted when the MCR of SCDP is updated.
     * @param from previous ratio
     * @param to new ratio
     */
    event GlobalMCRUpdated(uint256 from, uint256 to);

    /**
     * @notice Emitted when the liquidation threshold is updated
     * @param from previous threshold
     * @param to new threshold
     * @param mlr new max liquidation ratio
     */
    event GlobalLTUpdated(uint256 from, uint256 to, uint256 mlr);

    /**
     * @notice Emitted when the max liquidation ratio is updated
     * @param from previous ratio
     * @param to new ratio
     */
    event GlobalMLRUpdated(uint256 from, uint256 to);
}

// src/contracts/core/vault/Events.sol

interface VEvent {
    /* -------------------------------------------------------------------------- */
    /*                                   Events                                   */
    /* -------------------------------------------------------------------------- */

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
     * @param symbol Asset symbol
     * @param staletime Time in seconds for the feed to be considered stale
     * @param price Price of the asset
     * @param depositLimit Deposit limit of the asset
     * @param timestamp Timestamp of the addition
     */
    event AssetAdded(
        address indexed asset,
        address indexed feed,
        string indexed symbol,
        uint256 staletime,
        uint256 price,
        uint256 depositLimit,
        uint256 timestamp
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
}

// src/contracts/core/icdp/Event.sol

interface MEvent {
    /**
     * @notice Emitted when a collateral is added.
     * @dev only emitted once per asset.
     * @param ticker underlying ticker.
     * @param symbol token symbol
     * @param collateral address of the asset
     * @param factor the collateral factor
     * @param share possible fixed share address
     * @param liqIncentive the liquidation incentive
     */
    event CollateralAdded(
        string indexed ticker,
        string indexed symbol,
        address indexed collateral,
        uint256 factor,
        address share,
        uint256 liqIncentive
    );

    /**
     * @notice Emitted when collateral is updated.
     * @param ticker underlying ticker.
     * @param symbol token symbol
     * @param collateral address of the collateral.
     * @param factor the collateral factor.
     * @param share possible fixed share address
     * @param liqIncentive the liquidation incentive
     */
    event CollateralUpdated(
        string indexed ticker,
        string indexed symbol,
        address indexed collateral,
        uint256 factor,
        address share,
        uint256 liqIncentive
    );

    /**
     * @notice Emitted when an account deposits collateral.
     * @param account The address of the account depositing collateral.
     * @param collateral The address of the collateral asset.
     * @param amount The amount of the collateral asset that was deposited.
     */
    event CollateralDeposited(
        address indexed account,
        address indexed collateral,
        uint256 amount
    );

    /**
     * @notice Emitted on collateral withdraws.
     * @param account account withdrawing collateral.
     * @param collateral the withdrawn collateral.
     * @param amount the amount withdrawn.
     */
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

    /* -------------------------------------------------------------------------- */
    /*                                   Kopios                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Emitted when a new kopio is added.
     * @dev emitted once per asset.
     * @param ticker underlying ticker.
     * @param symbol token symbol
     * @param kopio address of the asset.
     * @param share fixed share address
     * @param dFactor debt factor.
     * @param icdpLimit icdp supply cap.
     * @param closeFee close fee percentage.
     * @param openFee open fee percentage.
     */
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

    /**
     * @notice Emitted when a kopio is updated.
     * @param ticker underlying ticker.
     * @param symbol token symbol
     * @param kopio address of the asset.
     * @param share fixed share address
     * @param dFactor debt factor.
     * @param icdpLimit icdp supply cap.
     * @param closeFee The close fee percentage.
     * @param openFee The open fee percentage.
     */
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

    /**
     * @notice Emitted when a kopio is minted.
     * @param account account minting the kopio.
     * @param kopio address of the kopio
     * @param amount amount minted.
     * @param receiver receiver of the minted kopio.
     */
    event KopioMinted(
        address indexed account,
        address indexed kopio,
        uint256 amount,
        address receiver
    );

    /**
     * @notice Emitted when kopio is burned.
     * @param account account burning the assets
     * @param kopio address of the kopio
     * @param amount amount burned
     */
    event KopioBurned(
        address indexed account,
        address indexed kopio,
        uint256 amount
    );

    /**
     * @notice Emitted when collateral factor is updated.
     * @param symbol token symbol
     * @param collateral address of the collateral.
     * @param from previous factor.
     * @param to new factor.
     */
    event CFactorUpdated(
        string indexed symbol,
        address indexed collateral,
        uint256 from,
        uint256 to
    );
    /**
     * @notice Emitted when dFactor is updated.
     * @param symbol token symbol
     * @param kopio address of the asset.
     * @param from previous debt factor
     * @param to new debt factor
     */
    event DFactorUpdated(
        string indexed symbol,
        address indexed kopio,
        uint256 from,
        uint256 to
    );

    /**
     * @notice Emitted when account closes a full debt position.
     * @param account address of the account
     * @param kopio asset address
     * @param amount amount burned to close the position.
     */
    event DebtPositionClosed(
        address indexed account,
        address indexed kopio,
        uint256 amount
    );

    /**
     * @notice Emitted when an account pays the open/close fee.
     * @dev can be emitted multiple times for a single asset.
     * @param account address that paid the fee.
     * @param collateral collateral used to pay the fee.
     * @param feeType type of the fee.
     * @param amount amount paid
     * @param value value paid
     * @param valueRemaining remaining fee value after.
     */
    event FeePaid(
        address indexed account,
        address indexed collateral,
        uint256 indexed feeType,
        uint256 amount,
        uint256 value,
        uint256 valueRemaining
    );

    /**
     * @notice Emitted when a liquidation occurs.
     * @param account account liquidated.
     * @param liquidator account that liquidated it.
     * @param kopio asset repaid.
     * @param amount amount repaid.
     * @param seizedCollateral collateral the liquidator seized.
     * @param seizedAmount amount of collateral seized
     */
    event LiquidationOccurred(
        address indexed account,
        address indexed liquidator,
        address indexed kopio,
        uint256 amount,
        address seizedCollateral,
        uint256 seizedAmount
    );

    /* -------------------------------------------------------------------------- */
    /*                                Parameters                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Emitted when a safety state is triggered for an asset
     * @param action target action
     * @param symbol token symbol
     * @param asset address of the target asset
     * @param description description for this event
     */
    event SafetyStateChange(
        Enums.Action indexed action,
        string indexed symbol,
        address indexed asset,
        string description
    );

    /**
     * @notice Emitted when the fee recipient is updated.
     * @param from previous recipient
     * @param to new recipient
     */
    event FeeRecipientUpdated(address from, address to);

    /**
     * @notice Emitted the asset's liquidation incentive is updated.
     * @param symbol token symbol
     * @param collateral asset address
     * @param from previous incentive
     * @param to new incentive
     */
    event LiquidationIncentiveUpdated(
        string indexed symbol,
        address indexed collateral,
        uint256 from,
        uint256 to
    );

    /**
     * @notice Emitted when the MCR is updated.
     * @param from previous MCR.
     * @param to new MCR.
     */
    event MinCollateralRatioUpdated(uint256 from, uint256 to);

    /**
     * @notice Emitted when the minimum debt value is updated.
     * @param from previous value
     * @param to new value
     */
    event MinimumDebtValueUpdated(uint256 from, uint256 to);

    /**
     * @notice Emitted when the liquidation threshold is updated
     * @param from previous threshold
     * @param to new threshold
     * @param mlr new max liquidation ratio.
     */
    event LiquidationThresholdUpdated(uint256 from, uint256 to, uint256 mlr);
    /**
     * @notice Emitted when the max liquidation ratio is updated
     * @param from previous ratio
     * @param to new ratio
     */
    event MaxLiquidationRatioUpdated(uint256 from, uint256 to);
}

// src/contracts/core/periphery/Types.sol

interface IEmitted is err, DTypes, MEvent, SEvent, VEvent, Multi {
    /// @dev Unable to deploy the contract.
    error DeploymentFailed();

    /// @dev Unable to initialize the contract.
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
