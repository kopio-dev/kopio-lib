// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "./ERC20.sol";
import {SafeTransfer} from "./SafeTransfer.sol";
import {__revert} from "../utils/Funcs.sol";
import {IWETHBase} from "./IWETH9.sol";

contract WETH9 is ERC20("Wrapped Ether", "WETH", 18), IWETHBase {
    using SafeTransfer for address payable;

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
    function depositTo(address to) external payable virtual {
        _mint(to, msg.value);
    }
    function withdrawTo(address to) external payable virtual {
        _burn(msg.sender, msg.value);
        (bool success, bytes memory err) = payable(to).call{value: msg.value}(
            ""
        );
        if (!success) __revert(err);
    }

    function transferAndCall(
        address to,
        uint256 amount,
        bytes memory data
    ) external returns (bool) {
        transfer(to, amount);

        (bool success, bytes memory err) = to.call(
            abi.encodeWithSignature(
                "onTokenTransfer(address,uint256,bytes)",
                msg.sender,
                amount,
                data
            )
        );
        if (!success) __revert(err);
        return true;
    }

    receive() external payable virtual {
        deposit();
    }
}
