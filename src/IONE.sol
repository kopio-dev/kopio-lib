// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IKopioIssuer, IVaultExtender} from "./KopioCore.sol";
import {IVault} from "./IVault.sol";
import {IERC20Permit} from "./token/IERC20Permit.sol";
import {IERC165} from "./vendor/IERC165.sol";

interface IONE is IERC20Permit, IVaultExtender, IKopioIssuer, IERC165 {
    function protocol() external view returns (address);
    function issue(uint256 amount, address to) external returns (uint256);

    function destroy(uint256 amount, address from) external returns (uint256);

    function vault() external view returns (IVault);
    function pause() external;

    function unpause() external;

    function exchangeRate() external view returns (uint256 rate);
}
