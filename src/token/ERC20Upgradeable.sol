// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Initializable} from "@oz-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Base} from "./ERC20Base.sol";

contract ERC20Upgradeable is ERC20Base, Initializable {
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should set it in constructor.
     */
    function __ERC20Upgradeable_init(
        string memory _name,
        string memory _symbol
    ) internal onlyInitializing {
        name = _name;
        symbol = _symbol;
    }
}
