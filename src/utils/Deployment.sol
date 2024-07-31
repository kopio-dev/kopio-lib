// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Solady} from "./Solady.sol";
import {Deployment} from "../core/IDeploymentFactory.sol";
import {ITransparentUpgradeableProxy, TransparentUpgradeableProxy} from "../vendor/TransparentUpgradeableProxy.sol";

library Deploys {
    function create(
        bytes memory creationCode,
        uint256 value
    ) internal returns (address location) {
        assembly {
            location := create(
                value,
                add(creationCode, 0x20),
                mload(creationCode)
            )
            if iszero(extcodesize(location)) {
                revert(0, 0)
            }
        }
    }

    function create2(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address location) {
        uint256 _salt = uint256(salt);
        assembly {
            location := create2(
                value,
                add(creationCode, 0x20),
                mload(creationCode),
                _salt
            )
            if iszero(extcodesize(location)) {
                revert(0, 0)
            }
        }
    }

    function create3(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address location) {
        return Solady.create3(salt, creationCode, value);
    }

    function create(
        bytes memory creationCode
    ) internal returns (address location) {
        return create(creationCode, msg.value);
    }

    function create2(
        bytes32 salt,
        bytes memory creationCode
    ) internal returns (address location) {
        return create2(salt, creationCode, msg.value);
    }

    function create3(
        bytes32 salt,
        bytes memory creationCode
    ) internal returns (address location) {
        return create3(salt, creationCode, msg.value);
    }

    function peek2(
        bytes32 salt,
        address _c2caller,
        bytes memory creationCode
    ) internal pure returns (address) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                _c2caller,
                                salt,
                                keccak256(creationCode)
                            )
                        )
                    )
                )
            );
    }

    function peek3(bytes32 salt) internal view returns (address) {
        return Solady.peek3(salt);
    }
}

library Proxies {
    using Proxies for address;

    function proxyInitCode(
        address implementation,
        address _factory,
        bytes memory _calldata
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                type(TransparentUpgradeableProxy).creationCode,
                abi.encode(implementation, _factory, _calldata)
            );
    }

    function proxyInitCode(
        address implementation,
        bytes memory _calldata
    ) internal view returns (bytes memory) {
        return implementation.proxyInitCode(address(this), _calldata);
    }

    function proxyInitCodeHash(
        address implementation,
        address _factory,
        bytes memory _calldata
    ) internal pure returns (bytes32) {
        return keccak256(implementation.proxyInitCode(_factory, _calldata));
    }

    function proxyInitCodeHash(
        address implementation,
        bytes memory _calldata
    ) internal view returns (bytes32) {
        return proxyInitCodeHash(implementation, address(this), _calldata);
    }

    function iface(
        address proxy
    ) internal pure returns (ITransparentUpgradeableProxy) {
        return ITransparentUpgradeableProxy(proxy);
    }
}

library Conversions {
    function toDeployment(
        bytes memory b
    ) internal pure returns (Deployment memory) {
        return abi.decode(b, (Deployment));
    }

    function map(
        bytes[] memory rawData,
        function(bytes memory) pure returns (address) dataHandler
    ) internal pure returns (address[] memory result) {
        result = new address[](rawData.length);
        unchecked {
            for (uint256 i; i < rawData.length; i++) {
                result[i] = dataHandler(rawData[i]);
            }
        }
    }

    function map(
        bytes[] memory rawData,
        function(bytes memory) pure returns (Deployment memory) dataHandler
    ) internal pure returns (Deployment[] memory result) {
        result = new Deployment[](rawData.length);
        unchecked {
            for (uint256 i; i < rawData.length; i++) {
                result[i] = dataHandler(rawData[i]);
            }
        }
    }
}
