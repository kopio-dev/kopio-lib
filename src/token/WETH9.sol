// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "./ERC20.sol";
import {SafeTransfer} from "./SafeTransfer.sol";

contract WETH9 is ERC20("Wrapped Ether", "WETH", 18) {
    using SafeTransfer for address payable;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);

        payable(msg.sender).safeTransferETH(amount);
    }

    function totalSupply() public view override returns (uint256) {
        return address(this).balance;
    }

    receive() external payable virtual {
        deposit();
    }
}
