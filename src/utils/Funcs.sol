// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable

function Revert(bytes memory d) pure {
    assembly {
        revert(add(32, d), mload(d))
    }
}

function split(bytes32 val, uint256 bit) pure returns (bytes memory res) {
    assembly {
        mstore(res, 64)
        mstore(add(res, 32), shr(sub(256, bit), val))
        mstore(add(res, 64), shr(bit, shl(bit, val)))
    }
}
