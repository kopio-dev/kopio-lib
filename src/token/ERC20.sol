// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;
import {ERC20Base} from "./ERC20Base.sol";

contract ERC20 is ERC20Base {
    uint256 internal immutable INITIAL_CHAIN_ID = block.chainid;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR =
        super.DOMAIN_SEPARATOR();

    constructor(string memory _name, string memory _symbol, uint8 dec) {
        name = _name;
        symbol = _symbol;
        decimals = dec;
    }

    function DOMAIN_SEPARATOR() public view virtual override returns (bytes32) {
        if (block.chainid == INITIAL_CHAIN_ID) return INITIAL_DOMAIN_SEPARATOR;
        return super.DOMAIN_SEPARATOR();
    }
}
