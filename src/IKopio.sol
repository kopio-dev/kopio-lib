// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IAccessControlEnumerable} from "./support/IAccessControl.sol";
import {IERC20Permit} from "./token/IERC20Permit.sol";
import {IERC165} from "./vendor/IERC165.sol";

interface IKopio is IERC20Permit, IAccessControlEnumerable, IERC165 {
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

    struct Rebase {
        uint248 denominator;
        bool positive;
    }

    struct Wraps {
        address underlying;
        uint8 underlyingDec;
        uint48 openFee;
        uint40 closeFee;
        bool native;
        address payable feeRecipient;
    }

    function protocol() external view returns (address);
    function share() external view returns (address);

    function rebaseInfo() external view returns (Rebase memory);

    function wraps() external view returns (Wraps memory);

    function isRebased() external view returns (bool);

    function rebase(
        uint248 denominator,
        bool positive,
        bytes calldata afterRebase
    ) external;

    function reinitializeERC20(
        string memory _name,
        string memory _symbol,
        uint8 _version
    ) external;

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function pause() external;

    function unpause() external;

    function wrap(address to, uint256 amount) external;

    function unwrap(address to, uint256 amount, bool toNative) external;

    function setShare(address addr) external;

    function enableNative(bool enabled) external;

    function setFeeRecipient(address newRecipient) external;

    function setOpenFee(uint48 newOpenFee) external;

    function setCloseFee(uint40 newCloseFee) external;

    function setUnderlying(address underlyingAddr) external;
}
