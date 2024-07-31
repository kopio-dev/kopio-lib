// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Purify} from "../utils/Purify.sol";

address constant clgAddr = 0x000000000000000000636F6e736F6c652e6c6f67;
address constant fSender = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
address constant vmAddr = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;

string constant BASE_FFI_DIR = "./lib/kopio-lib/utils/";

function getFFIPath(string memory _path) pure returns (string memory) {
    return string.concat(BASE_FFI_DIR, _path);
}

function execFFI(string[] memory args) returns (bytes memory) {
    FFIResult memory res = vmFFI.tryFfi(args);
    if (res.exitCode == 1) {
        revert(abi.decode(res.stdout, (string)));
    }
    return res.stdout;
}

struct FFIResult {
    int32 exitCode;
    bytes stdout;
    bytes stderr;
}

interface IFFIVm {
    function ffi(string[] memory) external returns (bytes memory);

    function tryFfi(string[] memory) external returns (FFIResult memory);

    function toString(address value) external pure returns (string memory r);

    function toString(bytes32 value) external pure returns (string memory r);

    function toString(bool value) external pure returns (string memory r);

    function toString(uint256 value) external pure returns (string memory r);

    function toString(int256 value) external pure returns (string memory r);

    function toString(
        bytes calldata value
    ) external pure returns (string memory r);

    function store(address target, bytes32 slot, bytes32 value) external;
    function load(address t, bytes32 s) external view returns (bytes32);
}

IFFIVm constant vmFFI = IFFIVm(vmAddr);

function hasVM() view returns (bool) {
    uint256 len = 0;
    assembly {
        len := extcodesize(vmAddr)
    }
    return len > 0;
}

function logp(bytes memory _p) pure {
    Purify.BytesIn(logv)(_p);
}

function logv(bytes memory _b) view {
    uint256 len = _b.length;
    address _a = clgAddr;
    /// @solidity memory-safe-assembly
    assembly {
        let start := add(_b, 32)
        let r := staticcall(gas(), _a, start, len, 0, 0)
    }
}
function _exp() view returns (string memory res) {
    res = "arbiscan.io";
    if (block.chainid == 1) res = "etherscan.io";
    if (block.chainid == 11155111) res = "sepolia.etherscan.io";
    if (block.chainid == 137) res = "polygonscan.com";
    if (block.chainid == 1101) res = "zkevm.polygonscan.com";
    if (block.chainid == 1284) res = "moonscan.io";
    if (block.chainid == 56) res = "bscscan.com";
    if (block.chainid == 204) res = "opbnb.bscscan.com";
    if (block.chainid == 8453) res = "basescan.org";
    if (block.chainid == 43114) res = "snowtrace.io";
    if (block.chainid == 250) res = "ftmscan.com";
    if (block.chainid == 10) res = "optimistic.etherscan.io";
    if (block.chainid == 100) res = "gnosisscan.io";
    return string.concat("https://", res);
}

function explorer() pure returns (string memory) {
    return Purify.StrOut(_exp)();
}

function explorer(address _a) pure returns (string memory) {
    return string.concat(explorer(), "/address/", vmFFI.toString(_a));
}

function explorer20(address _a) pure returns (string memory) {
    return string.concat(explorer(), "/token/", vmFFI.toString(_a));
}

function explorer(bytes32 _tx) pure returns (string memory) {
    return string.concat(explorer(), "/tx/", vmFFI.toString(_tx));
}

function explorer(uint256 _bnr) pure returns (string memory) {
    return string.concat(explorer(), "/block/", vmFFI.toString(_bnr));
}
