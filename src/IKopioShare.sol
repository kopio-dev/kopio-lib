// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Permit} from "./token/IERC20Permit.sol";
import {IAccessControlEnumerable} from "./support/IAccessControl.sol";
import {IKopioIssuer, IERC4626} from "./KopioCore.sol";
import {IERC165} from "./vendor/IERC165.sol";

interface IKopioShare is
    IKopioIssuer,
    IERC4626,
    IERC20Permit,
    IAccessControlEnumerable,
    IERC165
{
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
    ) external view override(IKopioIssuer, IERC4626) returns (uint256 shares);

    function convertToAssets(
        uint256 shares
    ) external view override(IKopioIssuer, IERC4626) returns (uint256 assets);

    function reinitializeERC20(
        string memory _name,
        string memory _symbol,
        uint8 _version
    ) external;

    function wrap(uint256 assets) external;

    function unwrap(uint256 assets) external;
}
