// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20Permit} from "../token/IERC20Permit.sol";

library Permit {
    bytes32 internal constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    function getPermitHash(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            getPermitHash(
                owner,
                spender,
                amount,
                token.nonces(owner),
                deadline,
                token.DOMAIN_SEPARATOR()
            );
    }

    function getPermitHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        bytes32 domainSeparator
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            );
    }
}
