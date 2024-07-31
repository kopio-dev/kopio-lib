// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;
import {IERC20Permit} from "../token/IERC20Permit.sol";
import {IKopioIssuer} from "./IKopioIssuer.sol";
import {IERC4626Upgradeable} from "./IERC4626Upgradeable.sol";

interface ISyncable {
    function sync() external;
}

interface IReinitializable {
    /**
     * @notice Updates ERC20 metadata for the token in case eg. a ticker change
     * @param _name new name for the asset
     * @param _symbol new symbol for the asset
     * @param _version number that must be greater than latest emitted `Initialized` version
     */
    function reinitializeERC20(
        string memory _name,
        string memory _symbol,
        uint8 _version
    ) external;
}

interface IKopio is IReinitializable, IERC20Permit {
    event Wrap(
        address indexed asset,
        address underlying,
        address indexed to,
        uint256 amount
    );
    event Unwrap(
        address indexed asset,
        address underlying,
        address indexed to,
        uint256 amount
    );

    /**
     * @notice Rebase information
     * @param positive supply increasing/reducing rebase
     * @param denominator the denominator for the operator, 1 ether = 1
     */
    struct Rebase {
        uint248 denominator;
        bool positive;
    }

    /**
     * @notice wrap configuration of the kopio
     * @param underlying if set, corresponds to an underlying on-chain ERC20.
     * @param underlyingDecimals decimals of the underlying ERC20.
     * @param openFee wrap fee from underlying to kopio.
     * @param closeFee unwrap fee from kopio back to underlying.
     * @param nativeUnderlyingEnabled supports wrapping native to kopio
     * @param feeRecipient fee recipient.
     */
    struct Wrapping {
        address underlying;
        uint8 underlyingDecimals;
        uint48 openFee;
        uint40 closeFee;
        bool nativeUnderlyingEnabled;
        address payable feeRecipient;
    }

    function protocol() external view returns (address);

    function rebaseInfo() external view returns (Rebase memory);

    function wrappingInfo() external view returns (Wrapping memory);

    function isRebased() external view returns (bool);

    /**
     * @notice Perform a rebase, changing the denumerator and its operator
     * @param _denominator the denumerator for the operator, 1 ether = 1
     * @param _positive supply increasing/reducing rebase
     * @param _pools UniswapV2Pair address to sync so we wont get rekt by skim() calls.
     * @dev denumerator values 0 and 1 ether will disable the rebase
     */
    function rebase(
        uint248 _denominator,
        bool _positive,
        address[] calldata _pools
    ) external;

    /**
     * @notice Mints tokens to an address.
     * @dev Only callable by operator.
     * @dev Internal balances are always unrebased, events emitted are not.
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Burns tokens from an address.
     * @dev Only callable by operator.
     * @dev Internal balances are always unrebased, events emitted are not.
     * @param from The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function burn(address from, uint256 amount) external;

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
     * @notice Deposit underlying tokens to receive equal value of kopio (-fee).
     * @param to The address to send tokens to.
     * @param amount The amount (uint256).
     */
    function wrap(address to, uint256 amount) external;

    /**
     * @notice Withdraw kopio to receive underlying / native (-fee).
     * @param to The address to send unwrapped tokens to.
     * @param amount The amount (uint256).
     * @param _receiveNative bool whether to receive underlying as native
     */
    function unwrap(address to, uint256 amount, bool _receiveNative) external;

    /**
     * @notice Sets address of the fixed share.
     * @dev Has modifiers: onlyRole.
     * @param addr fixed share address
     */
    function setFixedShare(address addr) external;

    /**
     * @notice Enables depositing native token ETH in case of kopio ETH
     * @dev Has modifiers: onlyRole.
     * @param enabled The enabled (bool).
     */
    function enableNativeUnderlying(bool enabled) external;

    function setFeeRecipient(address) external;

    /**
     * @notice Sets deposit fee
     * @dev Has modifiers: onlyRole.
     * @param _openFee The open fee (uint48).
     */
    function setOpenFee(uint48 _openFee) external;

    /**
     * @notice Sets withdraw fee
     * @dev Has modifiers: onlyRole.
     * @param _closeFee The open fee (uint48).
     */
    function setCloseFee(uint40 _closeFee) external;

    /**
     * @notice Sets underlying token address (and its decimals)
     * @notice Zero address will disable functionality provided for the underlying.
     * @dev Has modifiers: onlyRole.
     * @param _underlyingAddr The underlying address.
     */
    function setUnderlying(address _underlyingAddr) external;
}

interface IFixedKopio is
    IKopioIssuer,
    IERC4626Upgradeable,
    IReinitializable,
    IERC20Permit
{
    /**
     * @notice The underlying kopio
     */
    function asset() external view returns (IKopio);

    function totalAssets() external view override returns (uint256);

    /**
     * @notice wrap base amount to kopio (only kopio)
     * @param assets The assets (uint256).
     */
    function wrap(uint256 assets) external;

    /**
     * @notice unwrap base amount of kopio (only kopio)
     * @param assets The assets (uint256).
     */

    function unwrap(uint256 assets) external;
}
