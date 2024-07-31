// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../token/IERC20.sol";
import {IKopioIssuer} from "./IKopioIssuer.sol";
import {IVaultExtender} from "./IVaultExtender.sol";
import {IERC165} from "./IERC165.sol";

interface IONE is IKopioIssuer, IVaultExtender, IERC20, IERC165 {
    function vault() external view returns (address);

    function pause() external;

    function unpause() external;

    /**
     * @notice Exchange rate of vONE to USD.
     * @return uint256 vONE/USD exchange rate.
     * @custom:signature exchangeRate()
     * @custom:selector 0x3ba0b9a9
     */
    function exchangeRate() external view returns (uint256);

    function grantRole(bytes32, address) external;
}
