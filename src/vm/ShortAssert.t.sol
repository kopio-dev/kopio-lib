// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {stdMath} from "forge-std/StdMath.sol";
import {hasVM, vmAddr, store} from "./MinVm.s.sol";
import {PLog} from "./PLog.s.sol";

library ShortAssert {
    bool constant IS_TEST = true;
    event log(string);
    event logs(bytes);

    event log_address(address);
    event log_bytes32(bytes32);
    event log_int(int256);
    event log_uint(uint256);
    event log_bytes(bytes);
    event log_string(string);

    event log_named_address(string key, address val);
    event log_named_bytes32(string key, bytes32 val);
    event log_named_int(string key, int256 val);
    event log_named_uint(string key, uint256 val);
    event log_named_bytes(string key, bytes val);
    event log_named_string(string key, string val);

    event log_array(uint256[] val);
    event log_array(int256[] val);
    event log_array(address[] val);
    event log_named_array(string key, uint256[] val);
    event log_named_array(string key, int256[] val);
    event log_named_array(string key, address[] val);

    function failed() public returns (bool) {
        if (store()._failed) {
            return store()._failed;
        } else {
            bool gFail = false;
            if (hasVM()) {
                (, bytes memory retdata) = vmAddr.call(
                    abi.encodePacked(
                        bytes4(keccak256("load(address,bytes32)")),
                        abi.encode(vmAddr, bytes32("failed"))
                    )
                );
                gFail = abi.decode(retdata, (bool));
            }
            return gFail;
        }
    }

    function fail() internal {
        if (hasVM()) {
            (bool status, ) = vmAddr.call(
                abi.encodePacked(
                    bytes4(keccak256("store(address,bytes32,bytes32)")),
                    abi.encode(
                        vmAddr,
                        bytes32("failed"),
                        bytes32(uint256(0x01))
                    )
                )
            );
            status; // Silence compiler warnings
        }
        store()._failed = true;
    }

    function eqz(uint256 a) internal returns (bool) {
        if (a != 0) {
            emit log("Error: a == 0 not satisfied [uint]");
            _log("  Value a", a);
            fail();
        }

        return !store()._failed;
    }

    function eqz(uint256 a, string memory err) internal returns (bool) {
        if (a != 0) {
            _log("Error", err);
            eqz(a);
        }

        return !store()._failed;
    }

    function gtz(uint256 a) internal returns (bool) {
        if (a <= 0) {
            emit log("Error: a > 0 not satisfied [uint]");
            fail();
        }

        return !store()._failed;
    }

    function gtz(uint256 a, string memory err) internal returns (bool) {
        if (a <= 0) {
            _log("Error", err);
            gtz(a);
        }

        return !store()._failed;
    }

    function gtz(int256 a) internal returns (bool) {
        if (a <= 0) {
            emit log("Error: a > 0 not satisfied [int]");
            emit log_named_int("  Value a", a);
            fail();
        }

        return !store()._failed;
    }

    function gtz(int256 a, string memory err) internal returns (bool) {
        if (a <= 0) {
            _log("Error", err);
            gtz(a);
        }

        return !store()._failed;
    }

    function eq(address a, address b) internal returns (bool) {
        if (a != b) {
            emit log("Error: a == b not satisfied [address]");
            emit log_named_address("      Left", a);
            emit log_named_address("     Right", b);
            fail();
        }
        return !store()._failed;
    }

    function eq(
        address a,
        address b,
        string memory err
    ) internal returns (bool) {
        if (a != b) {
            _log("Error", err);
            eq(a, b);
        }
        return !store()._failed;
    }

    function eq(bytes32 a, bytes32 b) internal {
        if (a != b) {
            emit log("Error: a == b not satisfied [bytes32]");
            emit log_named_bytes32("      Left", a);
            emit log_named_bytes32("     Right", b);
            fail();
        }
    }

    function eq(bytes32 a, bytes32 b, string memory err) internal {
        if (a != b) {
            _log("Error", err);
            eq(a, b);
        }
    }

    function eq(int a, int b) internal returns (bool) {
        if (a != b) {
            emit log("Error: a == b not satisfied [int]");
            emit log_named_int("      Left", a);
            emit log_named_int("     Right", b);
            fail();
        }
        return !store()._failed;
    }

    function eq(int a, int b, string memory err) internal returns (bool) {
        if (a != b) {
            _log("Error", err);
            eq(a, b);
        }
        return !store()._failed;
    }

    function eq(uint a, uint b) internal returns (bool) {
        if (a != b) {
            emit log("Error: a == b not satisfied [uint]");
            _log("      Left", a);
            _log("     Right", b);
            fail();
        }
        return !store()._failed;
    }

    function eq(uint a, uint b, string memory err) internal returns (bool) {
        if (a != b) {
            _log("Error", err);
            return eq(a, b);
        }

        return !store()._failed;
    }

    function eqDecimal(int a, int b, uint d) internal {
        if (a != b) {
            emit log("Error: a == b not satisfied [decimal int]");
            _log("      Left", a, d);
            _log("     Right", b, d);
            fail();
        }
    }

    function eqDecimal(int a, int b, uint d, string memory err) internal {
        if (a != b) {
            _log("Error", err);
            eqDecimal(a, b, d);
        }
    }

    function eqDecimal(uint a, uint b, uint d) internal {
        if (a != b) {
            emit log("Error: a == b not satisfied [decimal uint]");
            _log("      Left", a, d);
            _log("     Right", b, d);
            fail();
        }
    }

    function eqDecimal(uint a, uint b, uint d, string memory err) internal {
        if (a != b) {
            _log("Error", err);
            eqDecimal(a, b, d);
        }
    }

    function notEq(address a, address b) internal {
        if (a == b) {
            emit log("Error: a != b not satisfied [address]");
            emit log_named_address("      Left", a);
            emit log_named_address("     Right", b);
            fail();
        }
    }

    function notEq(address a, address b, string memory err) internal {
        if (a == b) {
            _log("Error", err);
            notEq(a, b);
        }
    }

    function notEq(bytes32 a, bytes32 b) internal {
        if (a == b) {
            emit log("Error: a != b not satisfied [bytes32]");
            emit log_named_bytes32("      Left", a);
            emit log_named_bytes32("     Right", b);
            fail();
        }
    }

    function notEq(bytes32 a, bytes32 b, string memory err) internal {
        if (a == b) {
            _log("Error", err);
            notEq(a, b);
        }
    }

    function notEq32(bytes32 a, bytes32 b) internal {
        notEq(a, b);
    }

    function notEq32(bytes32 a, bytes32 b, string memory err) internal {
        notEq(a, b, err);
    }

    function notEq(int a, int b) internal returns (bool) {
        if (a == b) {
            emit log("Error: a != b not satisfied [int]");
            emit log_named_int("      Left", a);
            emit log_named_int("     Right", b);
            fail();
        }

        return !store()._failed;
    }

    function notEq(int a, int b, string memory err) internal returns (bool) {
        if (a == b) {
            _log("Error", err);
            notEq(a, b);
        }

        return !store()._failed;
    }

    function notEq(uint a, uint b) internal returns (bool) {
        if (a == b) {
            emit log("Error: a != b not satisfied [uint]");
            _log("      Left", a);
            _log("     Right", b);
            fail();
        }

        return !store()._failed;
    }

    function notEq(uint a, uint b, string memory err) internal returns (bool) {
        if (a == b) {
            _log("Error", err);
            notEq(a, b);
        }

        return !store()._failed;
    }

    function notEqDecimal(int a, int b, uint d) internal {
        if (a == b) {
            emit log("Error: a != b not satisfied [decimal int]");
            _log("      Left", a, d);
            _log("     Right", b, d);
            fail();
        }
    }

    function notEqDecimal(int a, int b, uint d, string memory err) internal {
        if (a == b) {
            _log("Error", err);
            notEqDecimal(a, b, d);
        }
    }

    function notEqDecimal(uint a, uint b, uint d) internal {
        if (a == b) {
            emit log("Error: a != b not satisfied [decimal uint]");
            _log("      Left", a, d);
            _log("     Right", b, d);
            fail();
        }
    }

    function notEqDecimal(uint a, uint b, uint d, string memory err) internal {
        if (a == b) {
            _log("Error", err);
            notEqDecimal(a, b, d);
        }
    }

    function gt(uint a, uint b) internal returns (bool) {
        if (a <= b) {
            emit log("Error: a > b not satisfied [uint]");
            _log("  Value a", a);
            _log("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function gt(uint a, uint b, string memory err) internal returns (bool) {
        if (a <= b) {
            _log("Error", err);
            gt(a, b);
        }

        return !store()._failed;
    }

    function gt(int a, int b) internal returns (bool) {
        if (a <= b) {
            emit log("Error: a > b not satisfied [int]");
            emit log_named_int("  Value a", a);
            emit log_named_int("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function gt(int a, int b, string memory err) internal returns (bool) {
        if (a <= b) {
            _log("Error", err);
            gt(a, b);
        }

        return !store()._failed;
    }

    function gtDecimal(int a, int b, uint d) internal {
        if (a <= b) {
            emit log("Error: a > b not satisfied [decimal int]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function gtDecimal(int a, int b, uint d, string memory err) internal {
        if (a <= b) {
            _log("Error", err);
            gtDecimal(a, b, d);
        }
    }

    function gtDecimal(uint a, uint b, uint d) internal {
        if (a <= b) {
            emit log("Error: a > b not satisfied [decimal uint]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function gtDecimal(uint a, uint b, uint d, string memory err) internal {
        if (a <= b) {
            _log("Error", err);
            gtDecimal(a, b, d);
        }
    }

    function gte(uint a, uint b) internal returns (bool) {
        if (a < b) {
            emit log("Error: a >= b not satisfied [uint]");
            _log("  Value a", a);
            _log("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function gte(uint a, uint b, string memory err) internal returns (bool) {
        if (a < b) {
            _log("Error", err);
            gte(a, b);
        }

        return !store()._failed;
    }

    function gte(int a, int b) internal returns (bool) {
        if (a < b) {
            emit log("Error: a >= b not satisfied [int]");
            emit log_named_int("  Value a", a);
            emit log_named_int("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function gte(int a, int b, string memory err) internal returns (bool) {
        if (a < b) {
            _log("Error", err);
            gte(a, b);
        }

        return !store()._failed;
    }

    function gteDec(int a, int b, uint d) internal {
        if (a < b) {
            emit log("Error: a >= b not satisfied [decimal int]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function gteDec(int a, int b, uint d, string memory err) internal {
        if (a < b) {
            _log("Error", err);
            gteDec(a, b, d);
        }
    }

    function gteDec(uint a, uint b, uint d) internal {
        if (a < b) {
            emit log("Error: a >= b not satisfied [decimal uint]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function gteDec(uint a, uint b, uint d, string memory err) internal {
        if (a < b) {
            _log("Error", err);
            gteDec(a, b, d);
        }
    }

    function lt(uint a, uint b) internal returns (bool) {
        if (a >= b) {
            emit log("Error: a < b not satisfied [uint]");
            _log("  Value a", a);
            _log("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function lt(uint a, uint b, string memory err) internal returns (bool) {
        if (a >= b) {
            _log("Error", err);
            lt(a, b);
        }

        return !store()._failed;
    }

    function lt(int a, int b) internal returns (bool) {
        if (a >= b) {
            emit log("Error: a < b not satisfied [int]");
            emit log_named_int("  Value a", a);
            emit log_named_int("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function lt(int a, int b, string memory err) internal returns (bool) {
        if (a >= b) {
            _log("Error", err);
            lt(a, b);
        }

        return !store()._failed;
    }

    function ltDec(int a, int b, uint d) internal {
        if (a >= b) {
            emit log("Error: a < b not satisfied [decimal int]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function ltDec(int a, int b, uint d, string memory err) internal {
        if (a >= b) {
            _log("Error", err);
            ltDec(a, b, d);
        }
    }

    function ltDec(uint a, uint b, uint d) internal {
        if (a >= b) {
            emit log("Error: a < b not satisfied [decimal uint]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function ltDec(uint a, uint b, uint d, string memory err) internal {
        if (a >= b) {
            _log("Error", err);
            ltDec(a, b, d);
        }
    }

    function lte(uint a, uint b) internal returns (bool) {
        if (a > b) {
            emit log("Error: a <= b not satisfied [uint]");
            _log("  Value a", a);
            _log("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function lte(uint a, uint b, string memory err) internal returns (bool) {
        if (a > b) {
            _log("Error", err);
            lte(a, b);
        }

        return !store()._failed;
    }

    function lte(int a, int b) internal returns (bool) {
        if (a > b) {
            emit log("Error: a <= b not satisfied [int]");
            emit log_named_int("  Value a", a);
            emit log_named_int("  Value b", b);
            fail();
        }

        return !store()._failed;
    }

    function lte(int a, int b, string memory err) internal returns (bool) {
        if (a > b) {
            _log("Error", err);
            lte(a, b);
        }
        return !store()._failed;
    }

    function lteDec(int a, int b, uint d) internal {
        if (a > b) {
            emit log("Error: a <= b not satisfied [decimal int]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function lteDec(int a, int b, uint d, string memory err) internal {
        if (a > b) {
            _log("Error", err);
            lteDec(a, b, d);
        }
    }

    function lteDec(uint a, uint b, uint d) internal {
        if (a > b) {
            emit log("Error: a <= b not satisfied [decimal uint]");
            _log("  Value a", a, d);
            _log("  Value b", b, d);
            fail();
        }
    }

    function lteDec(uint a, uint b, uint d, string memory err) internal {
        if (a > b) {
            _log("Error", err);
            lteDec(a, b, d);
        }
    }

    function eq(string memory a, string memory b) internal {
        if (keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b))) {
            emit log("Error: a == b not satisfied [string]");
            _log("      Left", a);
            _log("     Right", b);
            fail();
        }
    }

    function eq(string memory a, string memory b, string memory err) internal {
        if (keccak256(abi.encodePacked(a)) != keccak256(abi.encodePacked(b))) {
            _log("Error", err);
            eq(a, b);
        }
    }

    function notEq(string memory a, string memory b) internal {
        if (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b))) {
            emit log("Error: a != b not satisfied [string]");
            _log("      Left", a);
            _log("     Right", b);
            fail();
        }
    }

    function notEq(
        string memory a,
        string memory b,
        string memory err
    ) internal {
        if (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b))) {
            _log("Error", err);
            notEq(a, b);
        }
    }

    function isEqz(
        bytes memory a,
        bytes memory b
    ) internal pure returns (bool ok) {
        ok = true;
        if (a.length == b.length) {
            for (uint i = 0; i < a.length; i++) {
                if (a[i] != b[i]) {
                    ok = false;
                }
            }
        } else {
            ok = false;
        }
    }

    function eqz(bytes memory a, bytes memory b) internal {
        if (!isEqz(a, b)) {
            emit log("Error: a == b not satisfied [bytes]");
            emit log_named_bytes("      Left", a);
            emit log_named_bytes("     Right", b);
            fail();
        }
    }

    function eqz(bytes memory a, bytes memory b, string memory err) internal {
        if (!isEqz(a, b)) {
            _log("Error", err);
            eqz(a, b);
        }
    }

    function notEq0(bytes memory a, bytes memory b) internal {
        if (isEqz(a, b)) {
            emit log("Error: a != b not satisfied [bytes]");
            emit log_named_bytes("      Left", a);
            emit log_named_bytes("     Right", b);
            fail();
        }
    }

    function notEq0(
        bytes memory a,
        bytes memory b,
        string memory err
    ) internal {
        if (isEqz(a, b)) {
            _log("Error", err);
            notEq0(a, b);
        }
    }

    function yes(bool a) internal {
        if (!a) {
            emit log("Error: Assertion Failed");
            fail();
        }
    }

    function yes(bool a, string memory err) internal {
        if (!a) {
            _log("Error", err);
            yes(a);
        }
    }

    function no(bool a) internal {
        yes(!a);
    }

    function no(bool a, string memory err) internal {
        yes(!a, err);
    }

    function eq(bool a, bool b) internal {
        if (a != b) {
            emit log("Error: a == b not satisfied [bool]");
            _log("      Left", a ? "true" : "false");
            _log("     Right", b ? "true" : "false");
            fail();
        }
    }

    function eq(bool a, bool b, string memory err) internal {
        if (a != b) {
            _log("Error", err);
            eq(a, b);
        }
    }

    function eq(bytes memory a, bytes memory b) internal {
        eqz(a, b);
    }

    function eq(bytes memory a, bytes memory b, string memory err) internal {
        eqz(a, b, err);
    }

    function eq(uint256[] memory a, uint256[] memory b) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log("Error: a == b not satisfied [uint[]]");
            emit log_named_array("      Left", a);
            emit log_named_array("     Right", b);
            fail();
        }
    }

    function eq(int256[] memory a, int256[] memory b) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log("Error: a == b not satisfied [int[]]");
            emit log_named_array("      Left", a);
            emit log_named_array("     Right", b);
            fail();
        }
    }

    function eq(address[] memory a, address[] memory b) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log("Error: a == b not satisfied [address[]]");
            emit log_named_array("      Left", a);
            emit log_named_array("     Right", b);
            fail();
        }
    }

    function eq(
        uint256[] memory a,
        uint256[] memory b,
        string memory err
    ) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            _log("Error", err);
            eq(a, b);
        }
    }

    function eq(
        int256[] memory a,
        int256[] memory b,
        string memory err
    ) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            _log("Error", err);
            eq(a, b);
        }
    }

    function eq(
        address[] memory a,
        address[] memory b,
        string memory err
    ) internal {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            _log("Error", err);
            eq(a, b);
        }
    }

    // Legacy helper
    function eqUint(uint256 a, uint256 b) internal {
        eq(uint256(a), uint256(b));
    }

    function closeTo(
        uint256 a,
        uint256 b,
        uint256 maxDelta
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            emit log("Error: a ~= b not satisfied [uint]");
            _log("      Left", a);
            _log("     Right", b);
            _log(" Max Delta", maxDelta);
            _log("     Delta", delta);
            fail();
        }

        return !store()._failed;
    }

    function closeTo(
        uint256 a,
        uint256 b,
        uint256 maxDelta,
        string memory err
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            _log("Error", err);
            closeTo(a, b, maxDelta);
        }

        return !store()._failed;
    }

    function closeToDec(
        uint256 a,
        uint256 b,
        uint256 maxDelta,
        uint256 d
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            emit log("Error: a ~= b not satisfied [uint]");
            _log("      Left", a, d);
            _log("     Right", b, d);
            _log(" Max Delta", maxDelta, d);
            _log("     Delta", delta, d);
            fail();
        }

        return !store()._failed;
    }

    function closeToDec(
        uint256 a,
        uint256 b,
        uint256 maxDelta,
        uint256 d,
        string memory err
    ) internal {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            _log("Error", err);
            closeToDec(a, b, maxDelta, d);
        }
    }

    function closeTo(
        int256 a,
        int256 b,
        uint256 maxDelta
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            emit log("Error: a ~= b not satisfied [int]");
            emit log_named_int("       Left", a);
            emit log_named_int("      Right", b);
            _log(" Max Delta", maxDelta);
            _log("     Delta", delta);
            fail();
        }

        return !store()._failed;
    }

    function closeTo(
        int256 a,
        int256 b,
        uint256 maxDelta,
        string memory err
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            _log("Error", err);
            closeTo(a, b, maxDelta);
        }

        return !store()._failed;
    }

    function closeToDec(
        int256 a,
        int256 b,
        uint256 maxDelta,
        uint256 d
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            emit log("Error: a ~= b not satisfied [int]");
            _log("      Left", a, d);
            _log("     Right", b, d);
            _log(" Max Delta", maxDelta, d);
            _log("     Delta", delta, d);
            fail();
        }

        return !store()._failed;
    }

    function closeToDec(
        int256 a,
        int256 b,
        uint256 maxDelta,
        uint256 d,
        string memory err
    ) internal returns (bool) {
        uint256 delta = stdMath.delta(a, b);

        if (delta > maxDelta) {
            _log("Error", err);
            closeToDec(a, b, maxDelta, d);
        }

        return !store()._failed;
    }

    function _log(string memory key, uint256 val, uint256 d) internal pure {
        PLog.dlg(val, key, d);
    }

    function _log(string memory key, int256 val, uint256 d) internal pure {
        PLog.dlg(val, key, d);
    }

    function _log(string memory key, uint256 val) internal pure {
        PLog.clg(val, key);
    }

    function _log(string memory key, string memory val) internal pure {
        PLog.clg(val, key);
    }

    function eq(
        function() external view returns (uint256) a,
        uint256 b
    ) internal returns (bool) {
        return eq(a(), b);
    }

    function eqInt(
        function() external view returns (int256) a,
        int256 b
    ) internal returns (bool) {
        return eq(a(), b);
    }

    function eqInt(
        function() external view returns (int256) a,
        uint256 b,
        string memory str
    ) internal returns (bool) {
        return eq(uint256(a()), b, str);
    }

    function eq(
        function() external view returns (uint256) a,
        uint256 b,
        string memory str
    ) internal returns (bool) {
        return eq(a(), b, str);
    }

    function eq(
        function() external view returns (int256) a,
        int256 b,
        string memory str
    ) internal returns (bool) {
        return eq(a(), b, str);
    }

    struct Tuple {
        uint256 a;
        uint256 b;
    }

    function and(
        function() external view returns (uint256) a,
        function() external view returns (uint256) b
    ) internal view returns (Tuple memory) {
        return Tuple(a(), b());
    }

    function eq(
        function() external view returns (uint256) a,
        function() external view returns (uint256) b
    ) internal returns (bool) {
        return eq(a(), b());
    }

    function eq(
        function() external view returns (uint256) a,
        function() external view returns (uint256) b,
        string memory str
    ) internal returns (bool) {
        return eq(a(), b(), str);
    }

    function eq(
        Tuple memory values,
        function() external view returns (uint256) c
    ) internal returns (bool) {
        return eq(values, c());
    }

    function eq(
        Tuple memory values,
        function() external view returns (uint256) c,
        string memory str
    ) internal returns (bool) {
        return eq(values, c(), str);
    }

    function eq(Tuple memory values, uint256 c) internal returns (bool) {
        return eq(values.a, values.b) && eq(values.b, c);
    }

    function eq(
        Tuple memory values,
        uint256 c,
        string memory str
    ) internal returns (bool) {
        return eq(values.b, values.a, str) && eq(values.b, c, str);
    }

    function eq(
        Tuple memory values,
        function() external view returns (uint256) c,
        uint256 d
    ) internal returns (bool) {
        return eq(values, c()) && eq(c(), d);
    }

    function eq(
        Tuple memory values,
        function() external view returns (uint256) c,
        uint256 d,
        string memory str
    ) internal returns (bool) {
        return eq(values, c(), str) && eq(c(), d, str);
    }

    function and(
        bool prev,
        function() external view returns (uint256) next
    ) internal returns (uint256) {
        if (!prev) {
            emit log("Error: Previous value was false");
        }
        return next();
    }
}
