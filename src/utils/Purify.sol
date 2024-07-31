// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Purify {
    function BytesIn(
        function(bytes memory) view fn
    ) internal pure returns (function(bytes memory) pure out) {
        assembly {
            out := fn
        }
    }

    function Empty(
        function() view fn
    ) internal pure returns (function() pure out) {
        assembly {
            out := fn
        }
    }

    function BoolOut(
        function() view returns (bool) fn
    ) internal pure returns (function() pure returns (bool) out) {
        assembly {
            out := fn
        }
    }

    function StrInStrOut(
        function(string memory) view returns (string memory) fn
    )
        internal
        pure
        returns (function(string memory) pure returns (string memory) out)
    {
        assembly {
            out := fn
        }
    }
    function StrOut(
        function() view returns (string memory) fn
    ) internal pure returns (function() pure returns (string memory) out) {
        assembly {
            out := fn
        }
    }
}
