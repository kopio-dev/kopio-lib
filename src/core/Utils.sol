// SPDX-License-Identifier: MIT
// solhint-disable no-inline-assembly, one-contract-per-file
pragma solidity ^0.8.0;

import {Enums} from "./types/Const.sol";
import {IErrorsEvents, Errors} from "./IErrorsEvents.sol";

/**
 * @title Library for operations on arrays
 */
library Arrays {
    using Arrays for address[];
    using Arrays for bytes32[];
    using Arrays for string[];

    struct FindResult {
        uint256 index;
        bool exists;
    }

    function empty(address[2] memory _addresses) internal pure returns (bool) {
        return _addresses[0] == address(0) && _addresses[1] == address(0);
    }

    function empty(
        Enums.OracleType[2] memory _oracles
    ) internal pure returns (bool) {
        return
            _oracles[0] == Enums.OracleType.Empty &&
            _oracles[1] == Enums.OracleType.Empty;
    }

    function find(
        address[] storage _elements,
        address _elementToFind
    ) internal pure returns (FindResult memory result) {
        address[] memory elements = _elements;
        for (uint256 i; i < elements.length; ) {
            if (elements[i] == _elementToFind) {
                return FindResult(i, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    function find(
        bytes32[] storage _elements,
        bytes32 _elementToFind
    ) internal pure returns (FindResult memory result) {
        bytes32[] memory elements = _elements;
        for (uint256 i; i < elements.length; ) {
            if (elements[i] == _elementToFind) {
                return FindResult(i, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    function find(
        string[] storage _elements,
        string memory _elementToFind
    ) internal pure returns (FindResult memory result) {
        string[] memory elements = _elements;
        for (uint256 i; i < elements.length; ) {
            if (
                keccak256(abi.encodePacked(elements[i])) ==
                keccak256(abi.encodePacked(_elementToFind))
            ) {
                return FindResult(i, true);
            }
            unchecked {
                ++i;
            }
        }
    }

    function pushUnique(
        address[] storage _elements,
        address _elementToAdd
    ) internal {
        if (!_elements.find(_elementToAdd).exists) {
            _elements.push(_elementToAdd);
        }
    }

    function pushUnique(
        bytes32[] storage _elements,
        bytes32 _elementToAdd
    ) internal {
        if (!_elements.find(_elementToAdd).exists) {
            _elements.push(_elementToAdd);
        }
    }

    function pushUnique(
        string[] storage _elements,
        string memory _elementToAdd
    ) internal {
        if (!_elements.find(_elementToAdd).exists) {
            _elements.push(_elementToAdd);
        }
    }

    function removeExisting(
        address[] storage _addresses,
        address _elementToRemove
    ) internal {
        FindResult memory result = _addresses.find(_elementToRemove);
        if (result.exists) {
            _addresses.removeAddress(_elementToRemove, result.index);
        }
    }

    /**
     * @dev Removes an element by copying the last element to the element to remove's place and removing
     * the last element.
     * @param _addresses The address array containing the item to be removed.
     * @param _elementToRemove The element to be removed.
     * @param _elementIndex The index of the element to be removed.
     */
    function removeAddress(
        address[] storage _addresses,
        address _elementToRemove,
        uint256 _elementIndex
    ) internal {
        if (_addresses[_elementIndex] != _elementToRemove)
            revert IErrorsEvents.ELEMENT_DOES_NOT_MATCH_PROVIDED_INDEX(
                Errors.id(_elementToRemove),
                _elementIndex,
                _addresses
            );

        uint256 lastIndex = _addresses.length - 1;
        // If the index to remove is not the last one, overwrite the element at the index
        // with the last element.
        if (_elementIndex != lastIndex) {
            _addresses[_elementIndex] = _addresses[lastIndex];
        }
        // Remove the last element.
        _addresses.pop();
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(bytes32 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        if (value != 0) revert IErrorsEvents.STRING_HEX_LENGTH_INSUFFICIENT();
        return string(buffer);
    }
}

library NumericArrayLib {
    // This function sort array in memory using bubble sort algorithm,
    // which performs even better than quick sort for small arrays

    uint256 internal constant BYTES_ARR_LEN_VAR_BS = 32;
    uint256 internal constant UINT256_VALUE_BS = 32;

    error CanNotPickMedianOfEmptyArray();

    // This function modifies the array
    function pickMedian(uint256[] memory arr) internal pure returns (uint256) {
        if (arr.length == 0) {
            revert CanNotPickMedianOfEmptyArray();
        }
        sort(arr);
        uint256 middleIndex = arr.length / 2;
        if (arr.length % 2 == 0) {
            uint256 sum = arr[middleIndex - 1] + arr[middleIndex];
            return sum / 2;
        } else {
            return arr[middleIndex];
        }
    }

    function sort(uint256[] memory arr) internal pure {
        assembly {
            let arrLength := mload(arr)
            let valuesPtr := add(arr, BYTES_ARR_LEN_VAR_BS)
            let endPtr := add(valuesPtr, mul(arrLength, UINT256_VALUE_BS))
            for {
                let arrIPtr := valuesPtr
            } lt(arrIPtr, endPtr) {
                arrIPtr := add(arrIPtr, UINT256_VALUE_BS) // arrIPtr += 32
            } {
                for {
                    let arrJPtr := valuesPtr
                } lt(arrJPtr, arrIPtr) {
                    arrJPtr := add(arrJPtr, UINT256_VALUE_BS) // arrJPtr += 32
                } {
                    let arrI := mload(arrIPtr)
                    let arrJ := mload(arrJPtr)
                    if lt(arrI, arrJ) {
                        mstore(arrIPtr, arrJ)
                        mstore(arrJPtr, arrI)
                    }
                }
            }
        }
    }
}
