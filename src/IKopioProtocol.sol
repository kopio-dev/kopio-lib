// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IKopio} from "./IKopio.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

library EnumerableSet {
    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

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

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(
        Set storage set,
        bytes32 value
    ) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(
        Set storage set,
        uint256 index
    ) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        Bytes32Set storage set,
        bytes32 value
    ) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        Bytes32Set storage set,
        bytes32 value
    ) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        Bytes32Set storage set,
        uint256 index
    ) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        Bytes32Set storage set
    ) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        AddressSet storage set,
        address value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        AddressSet storage set,
        address value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        AddressSet storage set,
        uint256 index
    ) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        AddressSet storage set
    ) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(
        UintSet storage set,
        uint256 value
    ) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(
        UintSet storage set,
        uint256 value
    ) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(
        UintSet storage set,
        uint256 index
    ) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(
        UintSet storage set
    ) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    function allowance(address, address) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/// @dev See DapiProxy.sol for comments about usage
interface IAPI3 {
    function read() external view returns (int224 value, uint32 timestamp);

    function api3ServerV1() external view returns (address);
}

// lib/kopio-lib/src/vendor/Pyth.sol

/// @dev https://github.com/pyth-network/pyth-sdk-solidity/blob/main/PythStructs.sol
/// @dev Extra ticker is included in the struct
struct PriceFeed {
    // The price ID.
    bytes32 id;
    // Latest available price
    Price price;
    // Latest available exponentially-weighted moving average price
    Price emaPrice;
}

/// @dev  https://github.com/pyth-network/pyth-sdk-solidity/blob/main/PythStructs.sol
struct Price {
    // Price
    int64 price;
    // Confidence interval around the price
    uint64 conf;
    // Price exponent
    int32 expo;
    // Unix timestamp describing when the price was published
    uint256 publishTime;
}

struct PythEPs {
    mapping(uint256 chainId => IPyth pythEp) get;
    IPyth avax;
    IPyth bsc;
    IPyth blast;
    IPyth mainnet;
    IPyth arbitrum;
    IPyth optimism;
    IPyth polygon;
    IPyth polygonzkevm;
    bytes[] update;
    uint256 cost;
    PythView viewData;
    string tickers;
}

struct PythView {
    bytes32[] ids;
    Price[] prices;
}

interface IPyth {
    function getPriceNoOlderThan(
        bytes32 _id,
        uint256 _maxAge
    ) external view returns (Price memory);

    function getPriceUnsafe(bytes32 _id) external view returns (Price memory);

    function getUpdateFee(
        bytes[] memory _updateData
    ) external view returns (uint256);

    function updatePriceFeeds(bytes[] memory _updateData) external payable;

    function updatePriceFeedsIfNecessary(
        bytes[] memory _updateData,
        bytes32[] memory _ids,
        uint64[] memory _publishTimes
    ) external payable;

    // Function arguments are invalid (e.g., the arguments lengths mismatch)
    // Signature: 0xa9cb9e0d
    error InvalidArgument();
    // Update data is coming from an invalid data source.
    // Signature: 0xe60dce71
    error InvalidUpdateDataSource();
    // Update data is invalid (e.g., deserialization error)
    // Signature: 0xe69ffece
    error InvalidUpdateData();
    // Insufficient fee is paid to the method.
    // Signature: 0x025dbdd4
    error InsufficientFee();
    // There is no fresh update, whereas expected fresh updates.
    // Signature: 0xde2c57fa
    error NoFreshUpdate();
    // There is no price feed found within the given range or it does not exists.
    // Signature: 0x45805f5d
    error PriceFeedNotFoundWithinRange();
    // Price feed not found or it is not pushed on-chain yet.
    // Signature: 0x14aebe68
    error PriceFeedNotFound();
    // Requested price is stale.
    // Signature: 0x19abf40e
    error StalePrice();
    // Given message is not a valid Wormhole VAA.
    // Signature: 0x2acbe915
    error InvalidWormholeVaa();
    // Governance message is invalid (e.g., deserialization error).
    // Signature: 0x97363b35
    error InvalidGovernanceMessage();
    // Governance message is not for this contract.
    // Signature: 0x63daeb77
    error InvalidGovernanceTarget();
    // Governance message is coming from an invalid data source.
    // Signature: 0x360f2d87
    error InvalidGovernanceDataSource();
    // Governance message is old.
    // Signature: 0x88d1b847
    error OldGovernanceMessage();
    // The wormhole address to set in SetWormholeAddress governance is invalid.
    // Signature: 0x13d3ed82
    error InvalidWormholeAddressToSet();
}
interface IERC4626Upgradeable {
    /**
     * @notice The underlying kopio
     */
    function asset() external view returns (IKopio);

    /**
     * @notice Deposit assets for equivalent amount of shares
     * @param assets Amount of assets to deposit
     * @param receiver Address to send shares to
     * @return shares Amount of shares minted
     */
    function deposit(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares);

    /**
     * @notice Withdraw assets for equivalent amount of shares
     * @param assets Amount of assets to withdraw
     * @param receiver Address to send assets to
     * @param owner Address to burn shares from
     * @return shares Amount of shares burned
     * @dev shares are burned from owner, not msg.sender
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
     * @notice Mint shares for equivalent amount of assets
     * @param shares Amount of shares to mint
     * @param receiver Address to send shares to
     * @return assets Amount of assets redeemed
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
     * @return Total supply for the underlying kopio
     */
    function totalAssets() external view returns (uint256);

    /**
     * @notice Redeem shares for assets
     * @param shares Amount of shares to redeem
     * @param receiver Address to send assets to
     * @param owner Address to burn shares from
     * @return assets Amount of assets redeemed
     */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
}
// src/contracts/core/asset/IKopioIssuer.sol

/// @title An issuer for kopio
/// @author the kopio project
/// @notice contract that creates/destroys kopios.
/// @dev protocol enforces this implementation on kopios.
interface IKopioIssuer {
    /**
     * @notice Mints @param assets of kopio for @param to,
     * @notice Mints relative amount of fixed @return shares.
     */
    function issue(
        uint256 assets,
        address to
    ) external returns (uint256 shares);

    /**
     * @notice Burns @param assets of kopio from @param from,
     * @notice Burns relative amount of fixed @return shares.
     */
    function destroy(
        uint256 assets,
        address from
    ) external returns (uint256 shares);

    /**
     * @notice Preview conversion from kopio amount: @param assets to matching fixed amount: @return shares
     */
    function convertToShares(
        uint256 assets
    ) external view returns (uint256 shares);

    /**
     * @notice Preview conversion from fixed amount: @param shares to matching kopio amount: @return assets
     */
    function convertToAssets(
        uint256 shares
    ) external view returns (uint256 assets);

    /**
     * @notice Preview conversion from fixed amounts: @param shares to matching amounts of kopios: @return assets
     */
    function convertManyToAssets(
        uint256[] calldata shares
    ) external view returns (uint256[] memory assets);

    /**
     * @notice Preview conversion from kopio amounts: @param assets to matching fixed amount: @return shares
     */
    function convertManyToShares(
        uint256[] calldata assets
    ) external view returns (uint256[] memory shares);
}

// src/contracts/core/common/Args.sol

/**
 * @notice withdraws any amount and calls onFlashWithdraw.
 * @dev calls onFlashWithdraw on the sender.
 * @dev MCR check must pass after the callback.
 * @param account address to withdraw from.
 * @param asset address of collateral.
 * @param amount amount to withdraw.
 * @param depositIdx index in the deposits array.
 * @param data data forwarded to the callback
 */
struct FlashWithdrawArgs {
    address account;
    address asset;
    uint256 amount;
    uint256 depositIdx;
    bytes data;
}

/**
 * @notice External, used when caling liquidate.
 * @param account account to attempt to liquidate.
 * @param kopio kopio to repay.
 * @param amount amount to repay.
 * @param collateral collateral to seize.
 * @param mintIdx index in the minted kopios
 * @param depositIdx index in the deposited collaterals
 * @param prices price data for pyth.
 */
struct LiquidationArgs {
    address account;
    address kopio;
    uint256 amount;
    address collateral;
    uint256 mintIdx;
    uint256 depositIdx;
    bytes[] prices;
}

/**
 * @notice adjusts all deposits if global deposits wont cover the amount.
 * @param kopio kopio to repay
 * @param amount amount to repay.
 * @param collateral collateral to seize.
 */
struct SCDPLiquidationArgs {
    address kopio;
    uint256 amount;
    address collateral;
}

/**
 * @param kopio kopio repaid.
 * @param amount amount of kopio to repay
 * @param collateral collateral to seize.
 * @param prices price data for pyth.
 */
struct SCDPRepayArgs {
    address kopio;
    uint256 amount;
    address collateral;
    bytes[] prices;
}

/**
 * @param account account to withdraw from.
 * @param collateral collateral to withdraw.
 * @param amount amount to withdraw.
 * @param receiver receives the withdraw, address(0) fallbacks to account.
 */
struct SCDPWithdrawArgs {
    address account;
    address collateral;
    uint256 amount;
    address receiver;
}

/**
 * @param account receiver of amount out.
 * @param assetIn asset to sell.
 * @param assetOut asset to buy.
 * @param amountIn amount given.
 * @param minOut minimum amount to receive
 * @param prices price data for pyth.
 */
struct SwapArgs {
    address receiver;
    address assetIn;
    address assetOut;
    uint256 amountIn;
    uint256 amountOutMin;
    bytes[] prices;
}

/**
 * @param account address to mint from
 * @param kopio address of the kopio.
 * @param amount amount of kopio to mint.
 * @param receiver receives the kopios.
 */
struct MintArgs {
    address account;
    address kopio;
    uint256 amount;
    address receiver;
}

/**
 * @param account account to burn from
 * @param kopio kopio to burn.
 * @param amount amount to burn.
 * @param mintIdx index in the minted kopios
 * @param repayee address to burn from.
 */
struct BurnArgs {
    address account;
    address kopio;
    uint256 amount;
    uint256 mintIdx;
    address repayee;
}

/**
 * @param account address to withdraw assets for.
 * @param asset address of the collateral.
 * @param amount amount of the collateral to withdraw.
 * @param depositIdx index in the deposited collaterals
 * @param receiver receives the withdraw - address(0) fallbacks to account.
 */
struct WithdrawArgs {
    address account;
    address asset;
    uint256 amount;
    uint256 depositIdx;
    address receiver;
}

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

// src/contracts/core/common/interfaces/IAuthorizationFacet.sol

interface IAuthorizationFacet {
    /**
     * @dev OpenZeppelin
     * Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * @notice WARNING:
     * When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block.
     *
     * See the following forum post for more information:
     * - https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296
     *
     * @dev the kopio project
     *
     * TL;DR above:
     *
     * - If you iterate the EnumSet outside a single block scope you might get different results.
     * - Since when EnumSet member is deleted it is replaced with the highest index.
     * @return address with the `role`
     */
    function getRoleMember(
        bytes32 role,
        uint256 index
    ) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     * @notice See warning in {getRoleMember} if combining these two
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * @notice To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Returns true if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * @notice Requirements
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * @notice Requirements
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;
}

// src/contracts/core/common/interfaces/IBatchFacet.sol

interface IBatchFacet {
    /**
     * @notice Performs batched calls to the protocol with a single price update.
     * @param _calls Calls to perform.
     * @param _updateData Pyth price data to use for the calls.
     */
    function batchCall(
        bytes[] calldata _calls,
        bytes[] calldata _updateData
    ) external payable;

    /**
     * @notice Performs "static calls" with the update prices through `batchCallToError`, using a try-catch.
     * Refunds the msg.value sent for price update fee.
     * @param _staticCalls Calls to perform.
     * @param _updateData Pyth price update preview with the static calls.
     * @return timestamp Timestamp of the data.
     * @return results Static call results as bytes[]
     */
    function batchStaticCall(
        bytes[] calldata _staticCalls,
        bytes[] calldata _updateData
    ) external payable returns (uint256 timestamp, bytes[] memory results);

    /**
     * @notice Performs supplied calls and reverts a `Errors.BatchResult` containing returned results as bytes[].
     * @param _calls Calls to perform.
     * @param _updateData Pyth price update data to use for the static calls.
     * @return `Errors.BatchResult` which needs to be caught and decoded on-chain (according to the result signature).
     * Use `batchStaticCall` for a direct return.
     */
    function batchCallToError(
        bytes[] calldata _calls,
        bytes[] calldata _updateData
    ) external payable returns (uint256, bytes[] memory);

    /**
     * @notice Used to transform bytes memory -> calldata by external call, then calldata slices the error selector away.
     * @param _errorData Error data to decode.
     * @return timestamp Timestamp of the data.
     * @return results Static call results as bytes[]
     */
    function decodeErrorData(
        bytes calldata _errorData
    ) external pure returns (uint256 timestamp, bytes[] memory results);
}

// src/contracts/core/common/interfaces/IMarketStatus.sol

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

interface IDiamondStateFacet {
    /// @notice Whether the diamond is initialized.
    function initialized() external view returns (bool);

    /// @notice The EIP-712 typehash for the contract's domain.
    function domainSeparator() external view returns (bytes32);

    /// @notice Get the storage version (amount of times the storage has been upgraded)
    /// @return uint256 The storage version.
    function getStorageVersion() external view returns (uint256);

    /**
     * @notice Get the address of the owner
     * @return owner_ The address of the owner.
     */
    function owner() external view returns (address owner_);

    /**
     * @notice Get the address of pending owner
     * @return pendingOwner_ The address of the pending owner.
     **/
    function pendingOwner() external view returns (address pendingOwner_);

    /**
     * @notice Initiate ownership transfer to a new address
     * @notice caller must be the current contract owner
     * @notice the new owner cannot be address(0)
     * @notice emits a {PendingOwnershipTransfer} event
     * @param _newOwner address that is set as the pending new owner
     */
    function transferOwnership(address _newOwner) external;

    /**
     * @notice Transfer the ownership to the new pending owner
     * @notice caller must be the pending owner
     * @notice emits a {OwnershipTransferred} event
     */
    function acceptOwnership() external;
}

/**
 * @notice Internal for _liquidateAssets.
 * @param account The account being liquidated.
 * @param repayAmount amount being repaid.
 * @param seizeAmount amount being seized.
 * @param repayKopio kopio being repaid.
 * @param mintedIdx index in minted assets.
 * @param seizeAsset collateral asset to seize.
 * @param depositIdx index in deposited assets.
 */
struct LiquidateExecution {
    address account;
    uint256 repayAmount;
    uint256 seizeAmount;
    address kopio;
    uint256 mintedIdx;
    address collateral;
    uint256 depositIdx;
}

struct ICDPAccount {
    uint256 totalDebtValue;
    uint256 totalCollateralValue;
    uint256 collateralRatio;
}
/**
 * @notice Initializer values for the ICDP.
 */
struct ICDPInitializer {
    uint32 liquidationThreshold;
    uint32 minCollateralRatio;
    uint256 minDebtValue;
}

/**
 * @notice Configurable parameters in the ICDP.
 */
struct ICDPParams {
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint32 maxLiquidationRatio;
    uint256 minDebtValue;
}

// src/contracts/core/libs/PercentageMath.sol

/**
 * @title PercentageMath library
 * @author Aave
 * @notice Provides functions to perform percentage calculations
 * @dev PercentageMath are defined by default with 2 decimals of precision (100.00).
 * The precision is indicated by PERCENTAGE_FACTOR
 * @dev Operations are rounded. If a value is >=.5, will be rounded up, otherwise rounded down.
 **/
library PercentageMath {
    // Maximum percentage factor (100.00%)
    uint256 internal constant PERCENTAGE_FACTOR = 1e4;

    // Half percentage factor (50.00%)
    uint256 internal constant HALF_PERCENTAGE_FACTOR = 0.5e4;

    /**
     * @notice Executes a percentage multiplication
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param value The value of which the percentage needs to be calculated
     * @param percentage The percentage of the value to be calculated
     * @return result value percentmul percentage
     **/
    function percentMul(
        uint256 value,
        uint256 percentage
    ) internal pure returns (uint256 result) {
        // to avoid overflow, value <= (type(uint256).max - HALF_PERCENTAGE_FACTOR) / percentage
        assembly {
            if iszero(
                or(
                    iszero(percentage),
                    iszero(
                        gt(
                            value,
                            div(sub(not(0), HALF_PERCENTAGE_FACTOR), percentage)
                        )
                    )
                )
            ) {
                revert(0, 0)
            }

            result := div(
                add(mul(value, percentage), HALF_PERCENTAGE_FACTOR),
                PERCENTAGE_FACTOR
            )
        }
    }

    /**
     * @notice Executes a percentage division
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param value The value of which the percentage needs to be calculated
     * @param percentage The percentage of the value to be calculated
     * @return result value percentdiv percentage
     **/
    function percentDiv(
        uint256 value,
        uint256 percentage
    ) internal pure returns (uint256 result) {
        // to avoid overflow, value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR
        assembly {
            if or(
                iszero(percentage),
                iszero(
                    iszero(
                        gt(
                            value,
                            div(
                                sub(not(0), div(percentage, 2)),
                                PERCENTAGE_FACTOR
                            )
                        )
                    )
                )
            ) {
                revert(0, 0)
            }

            result := div(
                add(mul(value, PERCENTAGE_FACTOR), div(percentage, 2)),
                percentage
            )
        }
    }
}

library WadRay {
    // HALF_WAD and HALF_RAY expressed with extended notation
    // as constant with operations are not supported in Yul assembly
    uint256 internal constant WAD = 1e18;
    uint256 internal constant HALF_WAD = 0.5e18;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant HALF_RAY = 0.5e27;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

    uint128 internal constant RAY128 = 1e27;

    /**
     * @dev Multiplies two wad, rounding half up to the nearest wad
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param a Wad
     * @param b Wad
     * @return c = a*b, in wad
     **/
    function wadMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // to avoid overflow, a <= (type(uint256).max - HALF_WAD) / b
        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_WAD), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_WAD), WAD)
        }
    }

    /**
     * @dev Divides two wad, rounding half up to the nearest wad
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param a Wad
     * @param b Wad
     * @return c = a/b, in wad
     **/
    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // to avoid overflow, a <= (type(uint256).max - halfB) / WAD
        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, WAD), div(b, 2)), b)
        }
    }

    /**
     * @notice Multiplies two ray, rounding half up to the nearest ray
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param a Ray
     * @param b Ray
     * @return c = a raymul b
     **/
    function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // to avoid overflow, a <= (type(uint256).max - HALF_RAY) / b
        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_RAY), RAY)
        }
    }

    /**
     * @notice Divides two ray, rounding half up to the nearest ray
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param a Ray
     * @param b Ray
     * @return c = a raydiv b
     **/
    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // to avoid overflow, a <= (type(uint256).max - halfB) / RAY
        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), RAY))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, RAY), div(b, 2)), b)
        }
    }

    /**
     * @dev Casts ray down to wad
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param a Ray
     * @return b = a converted to wad, rounded half up to the nearest wad
     **/
    function rayToWad(uint256 a) internal pure returns (uint256 b) {
        assembly {
            b := div(a, WAD_RAY_RATIO)
            let remainder := mod(a, WAD_RAY_RATIO)
            if iszero(lt(remainder, div(WAD_RAY_RATIO, 2))) {
                b := add(b, 1)
            }
        }
    }

    /**
     * @dev Converts wad up to ray
     * @dev assembly optimized for improved gas savings: https://twitter.com/transmissions11/status/1451131036377571328
     * @param a Wad
     * @return b = a converted in ray
     **/
    function wadToRay(uint256 a) internal pure returns (uint256 b) {
        // to avoid overflow, b/WAD_RAY_RATIO == a
        assembly {
            b := mul(a, WAD_RAY_RATIO)

            if iszero(eq(div(b, WAD_RAY_RATIO), a)) {
                revert(0, 0)
            }
        }
    }
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

// src/contracts/core/scdp/Types.sol

/**
 * @notice SCDP initializer configuration.
 * @param minCollateralRatio The minimum collateralization ratio.
 * @param liquidationThreshold The liquidation threshold.
 * @param coverThreshold Threshold after which cover can be performed.
 * @param coverIncentive Incentive for covering debt instead of performing a liquidation.
 */
struct SCDPInitializer {
    uint32 minCollateralRatio;
    uint32 liquidationThreshold;
    uint48 coverThreshold;
    uint48 coverIncentive;
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

// Used for setting swap pairs enabled or disabled in the pool.
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

/**
 * @notice Indices for SCDP fees and liquidations.
 * @param currFeeIndex ever increasing fee index used for fee calculation.
 * @param currLiqIndex ever increasing liquidation index to calculate liquidated amounts from principal.
 */
struct SCDPAssetIndexes {
    uint128 currFeeIndex;
    uint128 currLiqIndex;
}

/**
 * @notice SCDP seize data
 * @param prevLiqIndex previous liquidation index.
 * @param feeIndex fee index at the time of the seize.
 * @param liqIndex liquidation index after the seize.
 */
struct SCDPSeizeData {
    uint256 prevLiqIndex;
    uint128 feeIndex;
    uint128 liqIndex;
}

/**
 * @notice SCDP account indexes
 * @param lastFeeIndex fee index at the time of the action.
 * @param lastLiqIndex liquidation index at the time of the action.
 * @param timestamp time of last update.
 */
struct SCDPAccountIndexes {
    uint128 lastFeeIndex;
    uint128 lastLiqIndex;
    uint256 timestamp;
}

// src/contracts/core/scdp/interfaces/ISDIFacet.sol

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
        address asset,
        uint256 amount,
        bool noFactors
    ) external view returns (uint256 shares);

    function previewSCDPMint(
        address asset,
        uint256 _mintAmount,
        bool noFactors
    ) external view returns (uint256 shares);

    /// @notice Total supply of SDI.
    function totalSDI() external view returns (uint256);

    /// @notice Price of SDI -> USD in oracle precision.
    function getSDIPrice() external view returns (uint256);

    /// @notice Cover debt by providing collateral without getting anything in return.
    function coverSCDP(
        address asset,
        uint256 amount,
        bytes[] calldata prices
    ) external payable returns (uint256 value);

    /// @notice Cover debt by providing collateral, receiving small incentive in return.
    function coverWithIncentiveSCDP(
        address asset,
        uint256 amount,
        address seizeAsset,
        bytes[] calldata prices
    ) external payable returns (uint256 value, uint256 seizedAmount);

    /// @notice Enable a cover asset to be used.
    function enableCoverAssetSDI(address asset) external;

    /// @notice Disable a cover asset to be used.
    function disableCoverAssetSDI(address asset) external;

    /// @notice Set the contract holding cover assets.
    function setCoverRecipientSDI(address _coverRecipient) external;

    /// @notice Get all accepted cover assets.
    function getCoverAssetsSDI() external view returns (address[] memory);
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

// src/contracts/core/vault/interfaces/IVaultExtender.sol

interface IVaultExtender {
    event Deposit(address indexed _from, address indexed _to, uint256 _amount);
    event Withdraw(address indexed _from, address indexed _to, uint256 _amount);

    /**
     * @notice Deposit tokens to vault for shares and convert them to equal amount of extender token.
     * @param _assetAddr Supported vault asset address
     * @param _assets amount of `_assetAddr` to deposit
     * @param _receiver Address receive extender tokens
     * @return sharesOut amount of shares/extender tokens minted
     * @return assetFee amount of `_assetAddr` vault took as fee
     */
    function vaultDeposit(
        address _assetAddr,
        uint256 _assets,
        address _receiver
    ) external returns (uint256 sharesOut, uint256 assetFee);

    /**
     * @notice Deposit supported vault assets to receive `_shares`, depositing the shares for equal amount of extender token.
     * @param _assetAddr Supported vault asset address
     * @param _receiver Address receive extender tokens
     * @param _shares Amount of shares to receive
     * @return assetsIn Amount of assets for `_shares`
     * @return assetFee Amount of `_assetAddr` vault took as fee
     */

    /**
     * @notice Vault mint, an external state-modifying function.
     * @param _assetAddr The asset addr address.
     * @param _shares The shares (uint256).
     * @param _receiver The receiver address.
     * @return assetsIn An uint256 value.
     * @return assetFee An uint256 value.
     * @custom:signature vaultMint(address,uint256,address)
     * @custom:selector 0x0c8daea9
     */
    function vaultMint(
        address _assetAddr,
        uint256 _shares,
        address _receiver
    ) external returns (uint256 assetsIn, uint256 assetFee);

    /**
     * @notice Withdraw supported vault asset, burning extender tokens and withdrawing shares from vault.
     * @param _assetAddr Supported vault asset address
     * @param _assets amount of `_assetAddr` to deposit
     * @param _receiver Address receive extender tokens
     * @param _owner Owner of extender tokens
     * @return sharesIn amount of shares/extender tokens burned
     * @return assetFee amount of `_assetAddr` vault took as fee
     */
    function vaultWithdraw(
        address _assetAddr,
        uint256 _assets,
        address _receiver,
        address _owner
    ) external returns (uint256 sharesIn, uint256 assetFee);

    /**
     * @notice  Withdraw supported vault asset for  `_shares` of extender tokens.
     * @param _assetAddr Token to deposit into vault for shares.
     * @param _shares amount of extender tokens to burn
     * @param _receiver Address to receive assets withdrawn
     * @param _owner Owner of extender tokens
     * @return assetsOut amount of assets out
     * @return assetFee amount of `_assetAddr` vault took as fee
     */
    function vaultRedeem(
        address _assetAddr,
        uint256 _shares,
        address _receiver,
        address _owner
    ) external returns (uint256 assetsOut, uint256 assetFee);

    /**
     * @notice Max redeem for underlying extender token.
     * @param assetAddr The withdraw asset address.
     * @param owner The extender token owner.
     * @return max Maximum amount withdrawable.
     * @return fee Fee paid if max is withdrawn.
     * @custom:signature maxRedeem(address,address)
     * @custom:selector 0x95b734fb
     */
    function maxRedeem(
        address assetAddr,
        address owner
    ) external view returns (uint256 max, uint256 fee);

    /**
     * @notice Deposit shares for equal amount of extender token.
     * @param _shares amount of vault shares to deposit
     * @param _receiver address to mint extender tokens to
     * @dev Does not return a value
     */
    function deposit(uint256 _shares, address _receiver) external;

    /**
     * @notice Withdraw shares for equal amount of extender token.
     * @param _amount amount of vault extender tokens to burn
     * @param _receiver address to send shares to
     * @dev Does not return a value
     */
    function withdraw(uint256 _amount, address _receiver) external;

    /**
     * @notice Withdraw shares for equal amount of extender token with allowance.
     * @param _from address to burn extender tokens from
     * @param _to address to send shares to
     * @param _amount amount to convert
     * @dev Does not return a value
     */
    function withdrawFrom(address _from, address _to, uint256 _amount) external;
}

// src/contracts/core/vault/interfaces/IVaultRateProvider.sol

/**
 * @title IVaultRateProvider
 * @author the kopio project
 * @notice Minimal exchange rate interface for vaults.
 */
interface IVaultRateProvider {
    /**
     * @notice Gets the exchange rate of one vault share to USD.
     * @return uint256 The current exchange rate of the vault share in 18 decimals precision.
     */
    function exchangeRate() external view returns (uint256);
}

// src/contracts/core/vendor/IERC165.sol

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// lib/kopio-lib/lib/openzeppelin-contracts/contracts/access/extensions/IAccessControlEnumerable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/extensions/IAccessControlEnumerable.sol)

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(
        bytes32 role,
        uint256 index
    ) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// lib/kopio-lib/src/token/IERC20Permit.sol

/* solhint-disable func-name-mixedcase */

interface IERC20Permit is IERC20 {
    error PERMIT_DEADLINE_EXPIRED(address, address, uint256, uint256);
    error INVALID_SIGNER(address, address);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function nonces(address) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// src/contracts/core/diamond/State.sol

struct DiamondState {
    mapping(bytes4 selector => FacetAddressAndPosition) selectorToFacetAndPosition;
    mapping(address facet => FacetFunctionSelectors) facetFunctionSelectors;
    address[] facetAddresses;
    mapping(bytes4 => bool) supportedInterfaces;
    /// @notice address(this) replacement for FF
    address self;
    bool initialized;
    uint8 initializing;
    bytes32 diamondDomainSeparator;
    address contractOwner;
    address pendingOwner;
    uint96 storageVersion;
}

bytes32 constant DIAMOND_SLOT = keccak256("kopio.diamond.storage");

function ds() pure returns (DiamondState storage state) {
    bytes32 position = DIAMOND_SLOT;
    assembly {
        state.slot := position
    }
}

// src/contracts/core/diamond/interfaces/IDiamondCutFacet.sol

interface IDiamondCutFacet {
    /**
     *@notice Add/replace/remove any number of functions, optionally execute a function with delegatecall
     * @param _diamondCut Contains the facet addresses and function selectors
     * @param _initializer The address of the contract or facet to execute _calldata
     * @param _calldata A function call, including function selector and arguments
     *                  _calldata is executed with delegatecall on _init
     */
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _initializer,
        bytes calldata _calldata
    ) external;
}

interface IExtendedDiamondCutFacet is IDiamondCutFacet {
    /**
     * @notice Use an initializer contract without cutting.
     * @param _initializer Address of contract or facet to execute _calldata
     * @param _calldata A function call, including function selector and arguments
     * - _calldata is executed with delegatecall on _init
     */
    function executeInitializer(
        address _initializer,
        bytes calldata _calldata
    ) external;

    /// @notice Execute multiple initializers without cutting.
    function executeInitializers(Initializer[] calldata _initializers) external;
}

interface IDiamondLoupeFacet {
    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses()
        external
        view
        returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(
        bytes4 _functionSelector
    ) external view returns (address facetAddress_);
}

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

// src/contracts/core/icdp/interfaces/IICDPBurnFacet.sol

interface IICDPBurnFacet {
    /**
     * @notice burns kopio to repay debt.
     * @notice restricted when caller differs from account or receiver.
     * @param args the burn arguments
     * @param prices price data
     */
    function burnKopio(
        BurnArgs memory args,
        bytes[] calldata prices
    ) external payable;
}

// src/contracts/core/icdp/interfaces/IICDPCollateralFacet.sol

interface IICDPCollateralFacet {
    /**
     * @notice Deposits collateral to the protocol.
     * @param account account to deposit for
     * @param collateral the collateral asset.
     * @param amount amount to deposit.
     */
    function depositCollateral(
        address account,
        address collateral,
        uint256 amount
    ) external payable;

    /**
     * @notice Withdraw collateral from the protocol.
     * @dev reverts if the resulting collateral value is below MCR.
     * @param args the withdraw arguments
     * @param prices price data
     */
    function withdrawCollateral(
        WithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;

    /**
     * @notice Withdraws sender's collateral from the protocol before checking minimum collateral ratio.
     * @dev calls onFlashWithdraw on the sender
     * @dev reverts if the resulting collateral value is below MCR
     * @param args the flash withdraw arguments
     * @param prices price data
     */
    function flashWithdraw(
        FlashWithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;
}

// src/contracts/core/icdp/interfaces/IICDPConfigFacet.sol

interface IICDPConfigFacet {
    function initializeICDP(ICDPInitializer calldata args) external;

    /**
     * @dev Updates the contract's minimum debt value.
     * @param newValue The new minimum debt value as a wad.
     */
    function setMinDebtValue(uint256 newValue) external;

    /**
     * @notice Updates the liquidation incentive multiplier.
     * @param collateral The collateral asset to update.
     * @param newIncentive The new liquidation incentive multiplier for the asset.
     */
    function setLiqIncentive(address collateral, uint16 newIncentive) external;

    /**
     * @dev Updates the contract's collateralization ratio.
     * @param newMCR The new minimum collateralization ratio as wad.
     */
    function setMCR(uint32 newMCR) external;

    /**
     * @dev Updates the contract's liquidation threshold value
     * @param newLT The new liquidation threshold value
     */
    function setLT(uint32 newLT) external;

    /**
     * @notice Updates the max liquidation ratior value.
     * @notice This is the maximum collateral ratio that liquidations can liquidate to.
     * @param newMLR Percent value in wad precision.
     */
    function setMLR(uint32 newMLR) external;
}

// src/contracts/core/icdp/interfaces/IICDPMintFacet.sol

interface IICDPMintFacet {
    /**
     * @notice Mints kopio as debt.
     * @param args MintArgs struct containing the arguments necessary to perform a mint.
     */
    function mintKopio(
        MintArgs memory args,
        bytes[] calldata prices
    ) external payable;
}

// src/contracts/core/icdp/interfaces/IICDPStateFacet.sol

interface IICDPStateFacet {
    /// @notice threshold before an account is considered liquidatable.
    function getLT() external view returns (uint32);

    /// @notice max liquidation multiplier -  cr after liquidation will be this.
    function getMLR() external view returns (uint32);

    /// @notice minimum value of debt.
    function getMinDebtValue() external view returns (uint256);

    /// @notice minimum ratio of collateral to debt.
    function getMCR() external view returns (uint32);

    /// @notice checks if asset exists
    function getKopioExists(address addr) external view returns (bool);

    /// @notice checks if collateral exists
    function getCollateralExists(address addr) external view returns (bool);

    /// @notice get active parameters in icdp.
    function getICDPParams() external view returns (ICDPParams memory);

    /// @notice minted icdp supply for a given asset.
    function getMintedSupply(address) external view returns (uint256);

    /**
     * @notice Gets the value from amount of collateral asset.
     * @param collateral address of collateral.
     * @param amount amount of the asset
     * @return value unfactored value of the collateral asset.
     * @return adjustedValue factored value of the collateral asset.
     * @return price price used to calculate the value.
     */
    function getCollateralValueWithPrice(
        address collateral,
        uint256 amount
    )
        external
        view
        returns (uint256 value, uint256 adjustedValue, uint256 price);

    /**
     * @notice Gets the value from asset amount.
     * @param asset address of the asset.
     * @param amount amount of the asset.
     * @return value unfactored value of the asset.
     * @return adjustedValue factored value of the asset.
     * @return price price used to calculate the value.
     */
    function getDebtValueWithPrice(
        address asset,
        uint256 amount
    )
        external
        view
        returns (uint256 value, uint256 adjustedValue, uint256 price);
}

library Meta {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            bytes(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            )
        );

    function domainSeparator(
        string memory name,
        string memory version
    ) internal view returns (bytes32 domainSeparator_) {
        domainSeparator_ = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                getChainID(),
                address(this)
            )
        );
    }

    function getChainID() internal view returns (uint256 id_) {
        assembly {
            id_ := chainid()
        }
    }

    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender_ = msg.sender;
        }
    }

    function enforceHasContractCode(address _contract) internal view {
        uint256 contractSize;
        /// @solidity memory-safe-assembly
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert err.ADDRESS_HAS_NO_CODE(_contract);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(bytes32 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        if (value != 0) revert err.STRING_HEX_LENGTH_INSUFFICIENT();
        return string(buffer);
    }
}

// src/contracts/core/scdp/interfaces/ISCDPConfigFacet.sol

interface ISCDPConfigFacet {
    function initializeSCDP(SCDPInitializer memory _init) external;

    /// @notice Gets the active parameters in SCDP.
    function getGlobalParameters()
        external
        view
        returns (SCDPParameters memory);

    /**
     * @notice Set the asset to cumulate swap fees into.
     * @param collateral Asset that is validated to be a deposit asset.
     */
    function setGlobalIncome(address collateral) external;

    /// @notice Set the MCR for SCDP.
    function setGlobalMCR(uint32 newMCR) external;

    /// @notice Set LT for SCDP. Updates MLR to LT + 1%.
    function setGlobalLT(uint32 newLT) external;

    /// @notice Set the max liquidation ratio for SCDP.
    /// @notice MLR is also updated automatically when setLiquidationThresholdSCDP is used.
    function setGlobalMLR(uint32 newMLR) external;

    /// @notice Set the liquidation incentive for a kopio in SCDP.
    /// @param kopio kopio asset to update.
    /// @param newIncentive new incentive multiplier, bound 1e4 <-> 1.25e4.
    function setGlobalLiqIncentive(address kopio, uint16 newIncentive) external;

    /**
     * @notice Update the asset deposit limit.
     * @param collateral collateral to update
     * @param newLimit the new deposit limit for the collateral
     */
    function setGlobalDepositLimit(
        address collateral,
        uint256 newLimit
    ) external;

    /**
     * @notice Enable/disable explicit global deposits for an asset.
     * @param collateral asset to update.
     * @param enabled enable or disable deposits
     */
    function setGlobalDepositEnabled(address collateral, bool enabled) external;

    /**
     * @notice Enable/disable asset from total global collateral value.
     * * Reverts if asset has user deposits.
     * @param asset asset to update.
     * @param enabled whether to enable or disable deposits.
     */
    function setGlobalCollateralEnabled(address asset, bool enabled) external;

    /**
     * @notice Enable/disable an asset in all swaps.
     * Enabling also adds it to total collateral value calculations.
     * @param kopio asset to update.
     * @param enabled whether to enable or disable swaps.
     */
    function setSwapEnabled(address kopio, bool enabled) external;

    /**
     * @notice Sets the swap fees of a kopio.
     * @param kopio kopio to set the fees for.
     * @param feeIn new fee when swapping in.
     * @param feeOut new fee when swapping out.
     * @param protocolShare percentage of fees the protocol takes.
     */
    function setSwapFees(
        address kopio,
        uint16 feeIn,
        uint16 feeOut,
        uint16 protocolShare
    ) external;

    /**
     * @notice Enable/disable swaps between assets.
     * @param routes routes to enable/disable.
     */
    function setSwapRoutes(SwapRouteSetter[] calldata routes) external;

    /**
     * @notice Enable/disable a swap direction between two assets.
     * @param route the route to enable/disable.
     */
    function setSwapRoute(SwapRouteSetter calldata route) external;
}

// src/contracts/core/scdp/interfaces/ISCDPStateFacet.sol

interface ISCDPStateFacet {
    /**
     * @notice Get the total principal deposits of `account`
     * @param account The account.
     * @param collateral The deposit asset
     */
    function getAccountDepositSCDP(
        address account,
        address collateral
    ) external view returns (uint256);

    /**
     * @notice Get the fees of `depositAsset` for `account`
     * @param account The account.
     * @param collateral The deposit asset
     */
    function getAccountFeesSCDP(
        address account,
        address collateral
    ) external view returns (uint256);

    /**
     * @notice Get the value of fees for `account`
     * @param account The account.
     */
    function getAccountTotalFeesValueSCDP(
        address account
    ) external view returns (uint256);

    /**
     * @notice Get the (principal) deposit value for `account`
     * @param account The account.
     * @param collateral The deposit asset
     */
    function getAccountDepositValueSCDP(
        address account,
        address collateral
    ) external view returns (uint256);

    function getAssetIndexesSCDP(
        address collateral
    ) external view returns (SCDPAssetIndexes memory);

    /**
     * @notice Get the total collateral deposit value for `account`
     * @param account The account.
     */
    function getAccountTotalDepositsValueSCDP(
        address account
    ) external view returns (uint256);

    /**
     * @notice Get the total collateral deposits for `collateral`
     */
    function getDepositsSCDP(
        address collateral
    ) external view returns (uint256);

    /**
     * @notice Get the total collateral swap deposits for `collateral`
     */
    function getSwapDepositsSCDP(
        address collateral
    ) external view returns (uint256);

    /**
     * @notice Get the total deposit value of `collateral`
     * @param collateral The collateral asset
     * @param noFactors ignore factors when calculating collateral and debt value.
     */
    function getCollateralValueSCDP(
        address collateral,
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice Get the total collateral value, oracle precision
     * @param noFactors ignore factors when calculating collateral value.
     */
    function getTotalCollateralValueSCDP(
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice Get all pool collateral assets
     */
    function getCollateralsSCDP() external view returns (address[] memory);

    /**
     * @notice Get available assets
     */
    function getKopiosSCDP() external view returns (address[] memory);

    /**
     * @notice Get the debt value of `kopio`
     * @param asset address of the asset
     */
    function getDebtSCDP(address asset) external view returns (uint256);

    /**
     * @notice Get the debt value of `kopio`
     * @param asset address of the asset
     * @param noFactors ignore factors when calculating collateral and debt value.
     */
    function getDebtValueSCDP(
        address asset,
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice Get the total debt value of kopio in oracle precision
     * @param noFactors ignore factors when calculating debt value.
     */
    function getTotalDebtValueSCDP(
        bool noFactors
    ) external view returns (uint256);

    /**
     * @notice Get enabled state of asset
     */
    function getGlobalDepositEnabled(
        address asset
    ) external view returns (bool);

    /**
     * @notice Check if `assetIn` can be swapped to `assetOut`
     * @param assetIn asset to give
     * @param assetOut asset to receive
     */
    function getRouteEnabled(
        address assetIn,
        address assetOut
    ) external view returns (bool);

    function getSwapEnabled(address addr) external view returns (bool);

    function getGlobalCollateralRatio() external view returns (uint256);
}

// src/contracts/core/scdp/interfaces/ISwapFacet.sol

interface ISwapFacet {
    /**
     * @notice Preview output and fees of a swap.
     * @param assetIn asset to provide.
     * @param assetOut asset to receive.
     * @param amountIn amount of assetIn.
     * @return amountOut the amount of `assetOut` for `amountIn`.
     */
    function previewSwapSCDP(
        address assetIn,
        address assetOut,
        uint256 amountIn
    )
        external
        view
        returns (uint256 amountOut, uint256 feeAmount, uint256 protocolFee);

    /**
     * @notice Swaps kopio to another kopio.
     * Uses the prices provided to determine amount out.
     * @param args selected assets, amounts and price data.
     */
    function swapSCDP(SwapArgs calldata args) external payable;

    /**
     * @notice accumulates fees for depositors as fixed, instantaneous income.
     * @param collateral collateral to cumulate income for
     * @param amount amount of income
     * @return nextLiquidityIndex the next liquidity index for the asset.
     */
    function addGlobalIncome(
        address collateral,
        uint256 amount
    ) external payable returns (uint256 nextLiquidityIndex);
}

// lib/kopio-lib/src/token/SafeTransfer.sol

// solhint-disable

error APPROVE_FAILED(address, address, address, uint256);
error ETH_TRANSFER_FAILED(address, uint256);
error TRANSFER_FAILED(address, address, address, uint256);
error PERMIT_DUP_NONCE(address, uint256, uint256);

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransfer {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        if (!success) revert ETH_TRANSFER_FAILED(to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(
                add(freeMemoryPointer, 4),
                and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Append and mask the "from" argument.
            mstore(
                add(freeMemoryPointer, 36),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success) revert TRANSFER_FAILED(address(token), from, to, amount);
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success)
            revert TRANSFER_FAILED(address(token), msg.sender, to, amount);
    }

    function safeApprove(IERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(
                add(freeMemoryPointer, 4),
                and(to, 0xffffffffffffffffffffffffffffffffffffffff)
            ) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        if (!success)
            revert APPROVE_FAILED(address(token), msg.sender, to, amount);
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        if (nonceAfter != nonceBefore + 1)
            revert PERMIT_DUP_NONCE(owner, nonceBefore, nonceAfter);
    }
}

// src/contracts/core/icdp/interfaces/IICDPAccountStateFacet.sol

interface IICDPAccountStateFacet {
    // ExpectedFeeRuntimeInfo is used for stack size optimization
    struct ExpectedFeeRuntimeInfo {
        address[] assets;
        uint256[] amounts;
        uint256 collateralTypeCount;
    }

    /**
     * @notice Calculates if an account's current collateral value is under its minimum collateral value
     * @param account The account to check.
     * @return bool whether the account is liquidatable.
     */
    function getAccountLiquidatable(
        address account
    ) external view returns (bool);

    /**
     * @notice Get account position in the ICDP.
     * @param account account to get state for.
     * @return ICDPAccount Total debt value, total collateral value and collateral ratio.
     */
    function getAccountState(
        address account
    ) external view returns (ICDPAccount memory);

    /**
     * @notice Gets an array of assets the account has minted.
     * @param account The account to get the minted assets for.
     * @return address[] Array of addresses the account has minted.
     */
    function getAccountMintedAssets(
        address account
    ) external view returns (address[] memory);

    /**
     * @notice Gets the accounts minted index for an asset.
     * @param account the account
     * @param asset the minted asset
     * @return index index for the asset
     */
    function getAccountMintIndex(
        address account,
        address asset
    ) external view returns (uint256);

    /**
     * @notice Gets the total debt value in USD for an account.
     * @notice Adjusted is multiplied by the dFactor.
     * @param account account to get the debt value for.
     * @return value unfactored value of debt.
     * @return valueAdjusted factored value of debt.
     */
    function getAccountTotalDebtValues(
        address account
    ) external view returns (uint256 value, uint256 valueAdjusted);

    /**
     * @notice Gets the total debt value in USD for the account.
     * @param account account to use
     * @return uint256 total debt value of `account`.
     */
    function getAccountTotalDebtValue(
        address account
    ) external view returns (uint256);

    /**
     * @notice Get `account` debt amount for `_asset`
     * @param account account to get the amount for
     * @param asset kopio address
     * @return uint256 debt amount for `asset`
     */
    function getAccountDebtAmount(
        address account,
        address asset
    ) external view returns (uint256);

    /**
     * @notice Gets the unfactored and factored collateral value of `asset` for `account`.
     * @param account account to get
     * @param asset collateral to check.
     * @return value unfactored collateral value
     * @return valueAdjusted factored collateral value
     * @return price asset price
     */
    function getAccountCollateralValues(
        address account,
        address asset
    )
        external
        view
        returns (uint256 value, uint256 valueAdjusted, uint256 price);

    /**
     * @notice Gets the factored collateral value of an account.
     * @param account Account to calculate the collateral value for.
     * @return valueAdjusted Collateral value of a particular account.
     */
    function getAccountTotalCollateralValue(
        address account
    ) external view returns (uint256 valueAdjusted);

    /**
     * @notice Gets the unfactored and factored collateral value of `account`.
     * @param account account to get
     * @return value unfactored total collateral value
     * @return valueAdjusted factored total collateral value
     */
    function getAccountTotalCollateralValues(
        address account
    ) external view returns (uint256 value, uint256 valueAdjusted);

    /**
     * @notice Get an account's minimum collateral value required
     * to back its debt at given collateralization ratio.
     * @notice Collateral value under minimum required are considered unhealthy,
     * @notice Collateral value under liquidation threshold will be liquidatable.
     * @param account account to get
     * @param ratio the collateralization ratio required
     * @return uint256 minimum collateral value for the account.
     */
    function getAccountMinCollateralAtRatio(
        address account,
        uint32 ratio
    ) external view returns (uint256);

    /**
     * @notice Gets the collateral ratio of an account
     * @return ratio the collateral ratio
     */
    function getAccountCollateralRatio(
        address account
    ) external view returns (uint256 ratio);

    /**
     * @notice Get a list of collateral ratios
     * @return ratios collateral ratios of `accounts`
     */
    function getAccountCollateralRatios(
        address[] memory accounts
    ) external view returns (uint256[] memory);

    /**
     * @notice Gets the deposit index for the collateral and account.
     * @param account account to use
     * @param collateral the collateral asset
     * @return i Index of the minted collateral asset.
     */
    function getAccountDepositIndex(
        address account,
        address collateral
    ) external view returns (uint256 i);

    /**
     * @notice Lists all deposited collaterals for account.
     * @param account account to use
     * @return address[] addresses of the collaterals
     */
    function getAccountCollateralAssets(
        address account
    ) external view returns (address[] memory);

    /**
     * @notice Get `account` collateral deposit amount for `asset`
     * @param asset The asset address
     * @param account The account to query amount for
     * @return uint256 Amount of collateral deposited for `asset`
     */
    function getAccountCollateralAmount(
        address account,
        address asset
    ) external view returns (uint256);

    /**
     * @notice Calculates the expected fee to be taken from a user's deposited collateral assets,
     *         by imitating calcFee without modifying state.
     * @param account account paying the fees
     * @param kopio kopio being burned.
     * @param amount Amount of the asset being minted.
     * @param feeType Type of the fees (open or close).
     * @return assets array with the collaterals used
     * @return amounts array with the fee amounts paid
     */
    function previewFee(
        address account,
        address kopio,
        uint256 amount,
        Enums.ICDPFee feeType
    ) external view returns (address[] memory assets, uint256[] memory amounts);
}

// src/contracts/core/libs/Arrays.sol

/**
 * @title Library for operations on arrays
 */
library Arrays {
    using Arrays for address[];
    using Arrays for bytes32[];
    using Arrays for string[];

    struct FindResult {
        uint256 index;
        bool exists;
    }

    function empty(address[2] memory _addresses) internal pure returns (bool) {
        return _addresses[0] == address(0) && _addresses[1] == address(0);
    }

    function empty(
        Enums.OracleType[2] memory _oracles
    ) internal pure returns (bool) {
        return
            _oracles[0] == Enums.OracleType.Empty &&
            _oracles[1] == Enums.OracleType.Empty;
    }

    function findIndex(
        address[] memory _elements,
        address _elementToFind
    ) internal pure returns (int256 idx) {
        for (uint256 i; i < _elements.length; ) {
            if (_elements[i] == _elementToFind) {
                return int256(i);
            }
            unchecked {
                ++i;
            }
        }

        return -1;
    }

    function find(
        address[] storage _elements,
        address _elementToFind
    ) internal pure returns (FindResult memory result) {
        address[] memory elements = _elements;
        for (uint256 i; i < elements.length; ) {
            if (elements[i] == _elementToFind) {
                return FindResult(i, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    function find(
        bytes32[] storage _elements,
        bytes32 _elementToFind
    ) internal pure returns (FindResult memory result) {
        bytes32[] memory elements = _elements;
        for (uint256 i; i < elements.length; ) {
            if (elements[i] == _elementToFind) {
                return FindResult(i, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    function find(
        string[] storage _elements,
        string memory _elementToFind
    ) internal pure returns (FindResult memory result) {
        string[] memory elements = _elements;
        for (uint256 i; i < elements.length; ) {
            if (
                keccak256(abi.encodePacked(elements[i])) ==
                keccak256(abi.encodePacked(_elementToFind))
            ) {
                return FindResult(i, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    function pushUnique(
        address[] storage _elements,
        address _elementToAdd
    ) internal {
        if (!_elements.find(_elementToAdd).exists) {
            _elements.push(_elementToAdd);
        }
    }

    function pushUnique(
        bytes32[] storage _elements,
        bytes32 _elementToAdd
    ) internal {
        if (!_elements.find(_elementToAdd).exists) {
            _elements.push(_elementToAdd);
        }
    }

    function pushUnique(
        string[] storage _elements,
        string memory _elementToAdd
    ) internal {
        if (!_elements.find(_elementToAdd).exists) {
            _elements.push(_elementToAdd);
        }
    }

    function removeExisting(
        address[] storage _addresses,
        address _elementToRemove
    ) internal {
        FindResult memory result = _addresses.find(_elementToRemove);
        if (result.exists) {
            _addresses.removeAddress(_elementToRemove, result.index);
        }
    }

    /**
     * @dev Removes an element by copying the last element to the element to remove's place and removing
     * the last element.
     * @param _addresses The address array containing the item to be removed.
     * @param _elementToRemove The element to be removed.
     * @param _elementIndex The index of the element to be removed.
     */
    function removeAddress(
        address[] storage _addresses,
        address _elementToRemove,
        uint256 _elementIndex
    ) internal {
        if (_addresses[_elementIndex] != _elementToRemove)
            revert err.ELEMENT_DOES_NOT_MATCH_PROVIDED_INDEX(
                id(_elementToRemove),
                _elementIndex,
                _addresses
            );

        uint256 lastIndex = _addresses.length - 1;
        // If the index to remove is not the last one, overwrite the element at the index
        // with the last element.
        if (_elementIndex != lastIndex) {
            _addresses[_elementIndex] = _addresses[lastIndex];
        }
        // Remove the last element.
        _addresses.pop();
    }
}

// src/contracts/core/one/interfaces/IONE.sol

interface IONE is IERC20Permit, IVaultExtender, IKopioIssuer, IERC165 {
    function vault() external view returns (address);

    function protocol() external view returns (address);

    /**
     * @notice This function adds ONE to circulation
     * Caller must be a contract and have the OPERATOR_ROLE
     * @param amount amount to mint
     * @param to address to mint tokens to
     * @return uint256 amount minted
     */
    function issue(
        uint256 amount,
        address to
    ) external override returns (uint256);

    /**
     * @notice This function removes ONE from circulation
     * Caller must be a contract and have the OPERATOR_ROLE
     * @param amount amount to burn
     * @param from address to burn tokens from
     * @return uint256 amount burned
     *
     * @inheritdoc IKopioIssuer
     */
    function destroy(
        uint256 amount,
        address from
    ) external override returns (uint256);

    /**
     * @notice Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external;

    /**
     * @notice  Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external;

    /**
     * @notice Exchange rate of vONE to USD.
     * @return rate vONE/USD exchange rate.
     */
    function exchangeRate() external view returns (uint256 rate);

    function grantRole(bytes32, address) external;
}

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

interface IGnosisSafeL2 {
    function isOwner(address owner) external view returns (bool);

    function getOwners() external view returns (address[] memory);
}

struct CommonState {
    /* -------------------------------------------------------------------------- */
    /*                                    Core                                    */
    /* -------------------------------------------------------------------------- */
    mapping(address asset => Asset) assets;
    mapping(bytes32 asset => mapping(Enums.OracleType provider => Oracle)) oracles;
    mapping(address asset => mapping(Enums.Action action => SafetyState)) safetyState;
    /// @notice The recipient of protocol fees.
    address feeRecipient;
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
    uint256 entered;
    mapping(bytes32 role => RoleData data) _roles;
    mapping(bytes32 role => EnumerableSet.AddressSet member) _roleMembers;
    address marketStatusProvider;
}

bytes32 constant COMMON_SLOT = keccak256("kopio.common.storage");

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

/**
 * @title Asset configuration
 * @author the kopio project
 * @notice all assets in the protocol share this configuration.
 * @notice ticker is shared eg. kETH and WETH use "ETH"
 * @dev Percentages use 2 decimals: 1e4 (10000) == 100.00%. See {PercentageMath.sol}.
 * @dev Noting the percentage value of uint16 caps at 655.36%.
 */
struct Asset {
    /// @notice Underlying asset ticker (eg. "ETH")
    bytes32 ticker;
    /// @notice The share address, if any.
    address share;
    /// @notice Oracles for this asset.
    /// @notice 0 is the primary price source, 1 being the reference price for deviation checks.
    Enums.OracleType[2] oracles;
    /// @notice Decreases collateral valuation, Always <= 100% or 1e4.
    uint16 factor;
    /// @notice Increases debt valution, >= 100% or 1e4.
    uint16 dFactor;
    /// @notice Fee percent for opening a debt position, deducted from collaterals.
    uint16 openFee;
    /// @notice Fee percent for closing a debt position, deducted from collaterals.
    uint16 closeFee;
    /// @notice Liquidation incentive when seized as collateral.
    uint16 liqIncentive;
    /// @notice Supply cap of the ICDP.
    uint256 mintLimit;
    /// @notice Supply cap of the SCDP.
    uint256 mintLimitSCDP;
    /// @notice Limit for SCDP deposit amount
    uint256 depositLimitSCDP;
    /// @notice Fee percent for swaps that sell the asset.
    uint16 swapInFee;
    /// @notice Fee percent for swaps that buy the asset.
    uint16 swapOutFee;
    /// @notice Protocol share of swap fees. Cap 50% == a.feeShare + b.feeShare <= 100%.
    uint16 protocolFeeShareSCDP;
    /// @notice Liquidation incentive for kopio debt in the SCDP.
    /// @notice Discounts the seized collateral in SCDP liquidations.
    uint16 liqIncentiveSCDP;
    /// @notice Set once during setup - kopios have 18 decimals.
    uint8 decimals;
    /// @notice Asset can be deposited as ICDP collateral.
    bool isCollateral;
    /// @notice Asset can be minted from the ICDP.
    bool isKopio;
    /// @notice Asset can be explicitly deposited into the SCDP.
    bool isGlobalDepositable;
    /// @notice Asset can be minted for swap output in the SCDP.
    bool isSwapMintable;
    /// @notice Asset belongs to total collateral value calculation in the SCDP.
    /// @notice kopios default to true due to indirect deposits from swaps.
    bool isGlobalCollateral;
    /// @notice Asset can be used to cover SCDP debt.
    bool isCoverAsset;
}

/// @notice The access control role data.
struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
}

/// @notice Variables used for calculating the max liquidation value.
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

/// @notice Convenience struct for checking configurations
struct RawPrice {
    int256 answer;
    uint256 timestamp;
    uint256 staleTime;
    bool isStale;
    bool isZero;
    Enums.OracleType oracle;
    address feed;
}

/// @notice Configuration for pausing `Action`
struct Pause {
    bool enabled;
    uint256 timestamp0;
    uint256 timestamp1;
}

/// @notice Safety configuration for assets
struct SafetyState {
    Pause pause;
}

/**
 * @notice Initialization arguments for common values
 */
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

/**
 * @title Storage for the ICDP.
 * @author the kopio project
 */
struct ICDPState {
    mapping(address account => address[]) depositedCollaterals;
    mapping(address account => mapping(address kopio => uint256)) collateralDeposits;
    mapping(address account => mapping(address kopio => uint256)) kopioDebt;
    mapping(address account => address[]) mintedKopios;
    /* --------------------------------- Assets --------------------------------- */
    address[] kopios;
    address[] collaterals;
    address feeRecipient;
    /// @notice max liquidation ratio, this is the max collateral ratio liquidations can liquidate to.
    uint32 maxLiquidationRatio;
    /// @notice minimum ratio of collateral to debt that can be taken by direct action.
    uint32 minCollateralRatio;
    /// @notice collateralization ratio at which positions may be liquidated.
    uint32 liquidationThreshold;
    /// @notice minimum debt value of a single account.
    uint256 minDebtValue;
}

bytes32 constant ICDP_SLOT = keccak256("kopio.icdp.storage");

function ms() pure returns (ICDPState storage state) {
    bytes32 position = ICDP_SLOT;
    assembly {
        state.slot := position
    }
}

/**
 * @title Storage layout for the shared cdp state
 * @author the kopio project
 */
struct SCDPState {
    /// @notice Array of deposit assets which can be swapped
    address[] collaterals;
    /// @notice Array of kopio assets which can be swapped
    address[] kopios;
    mapping(address assetIn => mapping(address assetOut => bool)) isRoute;
    mapping(address asset => bool enabled) isEnabled;
    mapping(address asset => SCDPAssetData) assetData;
    mapping(address account => mapping(address collateral => uint256 amount)) deposits;
    mapping(address account => mapping(address collateral => uint256 amount)) depositsPrincipal;
    mapping(address collateral => SCDPAssetIndexes) assetIndexes;
    mapping(address account => mapping(address collateral => SCDPAccountIndexes)) accountIndexes;
    mapping(address account => mapping(uint256 liqIndex => SCDPSeizeData)) seizeEvents;
    /// @notice current income asset
    address feeAsset;
    /// @notice minimum ratio of collateral to debt.
    uint32 minCollateralRatio;
    /// @notice collateralization ratio at which positions may be liquidated.
    uint32 liquidationThreshold;
    /// @notice limits the liquidatable value of a position to a CR.
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

bytes32 constant SCDP_SLOT = keccak256("kopio.scdp.storage");
bytes32 constant SDI_SLOT = keccak256("kopio.scdp.sdi.storage");

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

// src/contracts/core/common/interfaces/IAssetConfigFacet.sol

interface IAssetConfigFacet {
    /**
     * @notice Adds a new asset to the common state.
     * @notice Performs validations according to the `cfg` provided.
     * @dev Use validateAssetConfig / static call this for validation.
     * @param addr Asset address.
     * @param cfg Configuration struct to save for the asset.
     * @param feeds Configuration struct for the asset's oracles
     * @return Asset Result of addAsset.
     */
    function addAsset(
        address addr,
        Asset memory cfg,
        FeedConfiguration memory feeds
    ) external returns (Asset memory);

    /**
     * @notice Update asset config.
     * @notice Performs validations according to the `cfg` set.
     * @dev Use validateAssetConfig / static call this for validation.
     * @param addr The asset address.
     * @param cfg Configuration struct to apply for the asset.
     */
    function updateAsset(
        address addr,
        Asset memory cfg
    ) external returns (Asset memory);

    /**
     * @notice Updates the cFactor of an asset.
     * @param asset The collateral asset.
     * @param newFactor The new collateral factor.
     */
    function setCFactor(address asset, uint16 newFactor) external;

    /**
     * @notice Updates the dFactor of a kopio.
     * @param asset The kopio.
     * @param newDFactor The new dFactor.
     */
    function setDFactor(address asset, uint16 newDFactor) external;

    /**
     * @notice Validate supplied asset config. Reverts with information if invalid.
     * @param addr The asset address.
     * @param cfg Configuration for the asset.
     * @return bool True for convenience.
     */
    function validateAssetConfig(
        address addr,
        Asset memory cfg
    ) external view returns (bool);

    /**
     * @notice Update oracle order for an asset.
     * @param addr The asset address.
     * @param types 2 OracleTypes. 0 = primary, 1 = reference.
     */
    function setOracleTypes(
        address addr,
        Enums.OracleType[2] memory types
    ) external;
}

// src/contracts/core/common/interfaces/IAssetStateFacet.sol

interface IAssetStateFacet {
    function getAsset(address _assetAddr) external view returns (Asset memory);

    function getPrice(address _assetAddr) external view returns (uint256);

    function getPushPrice(
        address _assetAddr
    ) external view returns (RawPrice memory);

    function getValue(
        address _assetAddr,
        uint256 _amount
    ) external view returns (uint256);

    function getFeedForAddress(
        address _assetAddr,
        Enums.OracleType _oracleType
    ) external view returns (address feedAddr);

    function getMarketStatus(address _assetAddr) external view returns (bool);
}

// src/contracts/core/common/interfaces/ICommonConfigFacet.sol

interface ICommonConfigFacet {
    struct PythConfig {
        bytes32[] pythIds;
        uint256[] staleTimes;
        bool[] invertPyth;
        bool[] isClosables;
    }

    /**
     * @notice Updates the fee recipient.
     * @param recipient The new fee recipient.
     */
    function setFeeRecipient(address recipient) external;

    function setPythEndpoint(address addr) external;

    /**
     * @notice Sets the decimal precision of external oracle
     * @param dec Amount of decimals
     */
    function setOracleDecimals(uint8 dec) external;

    /**
     * @notice Sets the decimal precision of external oracle
     * @param newDeviation Amount of decimals
     */
    function setOracleDeviation(uint16 newDeviation) external;

    /**
     * @notice Sets L2 sequencer uptime feed address
     * @param newFeed sequencer uptime feed address
     */
    function setSequencerUptimeFeed(address newFeed) external;

    /**
     * @notice Sets sequencer grace period time
     * @param newGracePeriod grace period time
     */
    function setSequencerGracePeriod(uint32 newGracePeriod) external;

    /**
     * @notice Set feeds for a ticker.
     * @param ticker Ticker in bytes32 eg. bytes32("ETH")
     * @param feedCfg List oracle configuration containing oracle identifiers and feed addresses.
     */
    function setFeedsForTicker(
        bytes32 ticker,
        FeedConfiguration memory feedCfg
    ) external;

    /**
     * @notice Set chainlink feeds for tickers.
     * @dev Has modifiers: onlyRole.
     * @param tickers Bytes32 list of tickers
     * @param feeds List of feed addresses.
     */
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

    /**
     * @notice Set a vault feed for ticker.
     * @dev Has modifiers: onlyRole.
     * @param ticker Ticker in bytes32 eg. bytes32("ETH")
     * @param vault Vault address
     * @custom:signature setVaultFeed(bytes32,address)
     * @custom:selector 0xc3f9c901
     */
    function setVaultFeed(bytes32 ticker, address vault) external;

    /**
     * @notice Set a pyth feeds for tickers.
     * @dev Has modifiers: onlyRole.
     * @param tickers Bytes32 list of tickers
     * @param pythCfg Pyth configuration
     */
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

// src/contracts/core/common/interfaces/ICommonStateFacet.sol

interface ICommonStateFacet {
    /// @notice The recipient of protocol fees.
    function getFeeRecipient() external view returns (address);

    /// @notice The pyth endpoint.
    function getPythEndpoint() external view returns (address);

    /// @notice Offchain oracle decimals
    function getOracleDecimals() external view returns (uint8);

    /// @notice max deviation between main oracle and fallback oracle
    function getOracleDeviationPct() external view returns (uint16);

    /// @notice Get the market status provider address.
    function getMarketStatusProvider() external view returns (address);

    /// @notice Get the L2 sequencer uptime feed address.
    function getSequencerUptimeFeed() external view returns (address);

    /// @notice Get the L2 sequencer uptime feed grace period
    function getSequencerGracePeriod() external view returns (uint32);

    /**
     * @notice Get configured feed of the ticker
     * @param _ticker Ticker in bytes32, eg. bytes32("ETH").
     * @param _oracleType The oracle type.
     * @return feedAddr Feed address matching the oracle type given.
     */
    function getOracleOfTicker(
        bytes32 _ticker,
        Enums.OracleType _oracleType
    ) external view returns (Oracle memory);

    function getChainlinkPrice(bytes32 _ticker) external view returns (uint256);

    function getVaultPrice(bytes32 _ticker) external view returns (uint256);

    function getRedstonePrice(bytes32 _ticker) external view returns (uint256);

    function getAPI3Price(bytes32 _ticker) external view returns (uint256);

    function getPythPrice(bytes32 _ticker) external view returns (uint256);
}

// src/contracts/core/common/interfaces/ISafetyCouncilFacet.sol

interface ISafetyCouncilFacet {
    /**
     * @dev Toggle paused-state of assets in a per-action basis
     *
     * @notice These functions are only callable by a multisig quorum.
     * @param _assets list of addresses of kopios and/or collateral assets
     * @param _action One of possible user actions:
     *  Deposit = 0
     *  Withdraw = 1,
     *  Repay = 2,
     *  Borrow = 3,
     *  Liquidate = 4
     * @param _withDuration Set a duration for this pause - @todo: implement it if required
     * @param _duration Duration for the pause if `_withDuration` is true
     */
    function toggleAssetsPaused(
        address[] memory _assets,
        Enums.Action _action,
        bool _withDuration,
        uint256 _duration
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
     * @param _assetAddr kopio / collateral asset
     * @param _action One of possible user actions:
     *
     *  Deposit = 0
     *  Withdraw = 1,
     *  Repay = 2,
     *  Borrow = 3,
     *  Liquidate = 4
     */
    function safetyStateFor(
        address _assetAddr,
        Enums.Action _action
    ) external view returns (SafetyState memory);

    /**
     * @notice Check if `_assetAddr` has a pause enabled for `_action`
     * @param _action enum `Action`
     *  Deposit = 0
     *  Withdraw = 1,
     *  Repay = 2,
     *  Borrow = 3,
     *  Liquidate = 4
     * @return true if `_action` is paused
     */
    function assetActionPaused(
        Enums.Action _action,
        address _assetAddr
    ) external view returns (bool);
}

// src/contracts/core/periphery/ViewTypes.sol
// solhint-disable state-visibility, max-states-count, var-name-mixedcase, no-global-import, const-name-snakecase, no-empty-blocks, no-console, code-complexity

library View {
    struct AssetData {
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
        Asset config;
    }

    struct STotals {
        uint256 valColl;
        uint256 valCollAdj;
        uint256 valFees;
        uint256 valDebt;
        uint256 valDebtOg;
        uint256 valDebtOgAdj;
        uint256 sdiPrice;
        uint256 cr;
        uint256 crOg;
        uint256 crOgAdj;
    }

    struct Protocol {
        SCDP scdp;
        ICDP icdp;
        AssetView[] assets;
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
        MAccount icdp;
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
        Position[] debts;
        STotals totals;
        uint32 coverIncentive;
        uint32 coverThreshold;
    }

    struct Synthwrap {
        address token;
        uint256 openFee;
        uint256 closeFee;
    }

    struct AssetView {
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

    struct MAccount {
        MTotals totals;
        Position[] deposits;
        Position[] debts;
    }

    struct MTotals {
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
        Asset config;
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
        Asset config;
    }

    struct Position {
        uint256 amount;
        address addr;
        string symbol;
        uint256 amountAdj;
        uint256 val;
        uint256 valAdj;
        int256 index;
        uint256 price;
        Asset config;
    }
}

// src/contracts/core/icdp/interfaces/IICDPLiquidationFacet.sol

interface IICDPLiquidationFacet {
    /**
     * @notice Attempts to liquidate an account by repaying debt, seizing collateral in return.
     * @param args LiquidationArgs the amount, assets and prices for the liquidation.
     */
    function liquidate(LiquidationArgs calldata args) external payable;

    /**
     * @dev Calculate total value that can be liquidated from the account (if any)
     * @param account account to liquidate
     * @param kopio kopio to repay
     * @param collateral collateral to seize
     * @return MaxLiqInfo the maximum values for the liquidation.
     */
    function getMaxLiqValue(
        address account,
        address kopio,
        address collateral
    ) external view returns (MaxLiqInfo memory);
}

// src/contracts/core/periphery/interfaces/IViewDataFacet.sol

interface IViewDataFacet {
    function viewProtocolData(
        PythView calldata prices
    ) external view returns (View.Protocol memory);

    function viewAccountData(
        PythView calldata prices,
        address account
    ) external view returns (View.Account memory);

    function viewICDPAccounts(
        PythView calldata prices,
        address[] memory accounts
    ) external view returns (View.MAccount[] memory);

    function viewSCDPAccount(
        PythView calldata prices,
        address account
    ) external view returns (View.SAccount memory);

    function viewSCDPDepositAssets() external view returns (address[] memory);

    function viewTokenBalances(
        PythView calldata prices,
        address account,
        address[] memory tokens
    ) external view returns (View.Balance[] memory result);

    function viewSCDPAccounts(
        PythView calldata prices,
        address[] memory accounts,
        address[] memory assets
    ) external view returns (View.SAccount[] memory);

    function viewSCDPAssets(
        PythView calldata prices,
        address[] memory assets
    ) external view returns (View.AssetData[] memory);
}

// src/contracts/core/scdp/interfaces/ISCDPFacet.sol

interface ISCDPFacet {
    /**
     * @notice Deposits global collateral for the account
     * @param account account to deposit for
     * @param collateral collateral to deposit
     * @param amount amount to deposit
     */
    function depositSCDP(
        address account,
        address collateral,
        uint256 amount
    ) external payable;

    /**
     * @notice Withdraws global collateral.
     * @param args asset and amount to withdraw.
     */
    function withdrawSCDP(
        SCDPWithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;

    /**
     * @notice Withdraw collateral without caring about fees.
     * @param args asset and amount to withdraw.
     */
    function emergencyWithdrawSCDP(
        SCDPWithdrawArgs memory args,
        bytes[] calldata prices
    ) external payable;

    /**
     * @notice Claim pending fees.
     * @param account account to claim fees for.
     * @param collateral collateral with accumulated fees.
     * @param receiver reciver of the fees, 0 -> account.
     * @return fees amount claimed
     */
    function claimFeesSCDP(
        address account,
        address collateral,
        address receiver
    ) external payable returns (uint256 fees);

    /**
     * @notice Repays debt and withdraws protocol collateral with no fees.
     * @notice self deposits from the protocol must exists, otherwise reverts.
     * @param args the selected assets, amounts and prices.
     */
    function repaySCDP(SCDPRepayArgs calldata args) external payable;

    /**
     * @notice Liquidate the global position.
     * @notice affects every depositor if self deposits from the protocol cannot cover it.
     * @param args selected assets and amounts.
     */
    function liquidateSCDP(
        SCDPLiquidationArgs memory args,
        bytes[] calldata prices
    ) external payable;

    /**
     * @dev Calculates the total value that is allowed to be liquidated from SCDP (if it is liquidatable)
     * @param kopio Address of the asset to repay
     * @param collateral Address of collateral to seize
     * @return MaxLiqInfo Calculated information about the maximum liquidation.
     */
    function getMaxLiqValueSCDP(
        address kopio,
        address collateral
    ) external view returns (MaxLiqInfo memory);

    function getLiquidatableSCDP() external view returns (bool);
}

// src/contracts/core/periphery/IKopioProtocol.sol

// solhint-disable-next-line no-empty-blocks
interface IKopioProtocol is
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
    IViewDataFacet,
    IBatchFacet
{}

interface IKopioShare is
    IKopioIssuer,
    IERC4626Upgradeable,
    IERC20Permit,
    IAccessControlEnumerable,
    IERC165
{
    function totalAssets()
        external
        view
        override(IERC4626Upgradeable)
        returns (uint256);

    function reinitializeERC20(
        string memory _name,
        string memory _symbol,
        uint8 _version
    ) external;

    /**
     * @notice Mints shares to asset contract.
     * @param assets amount of assets.
     */
    function wrap(uint256 assets) external;

    /**
     * @notice Burns shares from the asset contract.
     * @param assets amount of assets.
     */
    function unwrap(uint256 assets) external;
}
