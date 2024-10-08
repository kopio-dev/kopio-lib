// SPDX-License-Identifier: AGPL-3.0-only
// solhint-disable
pragma solidity ^0.8.0;

import {ERC20} from "../token/ERC20.sol";

// solhint-disable no-empty-blocks

contract ERC20MockRestricted is ERC20 {
    mapping(address => bool) public minters;
    address public owner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) ERC20(_name, _symbol, _decimals) {
        _mint(msg.sender, _initialSupply);
        minters[msg.sender] = true;
    }

    function reinitializeERC20(
        string memory _name,
        string memory _symbol
    ) external {
        require(msg.sender == owner, "!owner");
        name = _name;
        symbol = _symbol;
    }

    function toggleMinters(address[] calldata _minters) external {
        require(minters[msg.sender], "!minter");
        for (uint256 i; i < _minters.length; i++) {
            minters[_minters[i]] = !minters[_minters[i]];
        }
    }

    function mint(address to, uint256 value) public virtual {
        require(minters[msg.sender], "!minter");
        _mint(to, value);
    }

    function burn(address from, uint256 value) public virtual {
        require(minters[msg.sender], "!minter");
        _burn(from, value);
    }
}

contract ERC20Mock is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 mintAmount
    ) ERC20(name_, symbol_, decimals_) {
        _mint(msg.sender, mintAmount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract WETH is ERC20Mock {
    constructor() ERC20Mock("WETH", "WETH", 18, 0) {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}

contract USDC is ERC20Mock {
    constructor() ERC20Mock("USDC", "USDC", 18, 0) {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}

contract DAI is ERC20Mock {
    constructor() ERC20Mock("DAI", "DAI", 18, 0) {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}

contract USDT is ERC20Mock {
    constructor() ERC20Mock("USDT", "USDT", 6, 0) {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}
