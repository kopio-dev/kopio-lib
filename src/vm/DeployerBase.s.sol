// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable no-global-import, no-unused-import
import "../vendor/TransparentUpgradeableProxy.sol";

import {Utils, Meta} from "../utils/Libs.sol";
import {Log, VmHelp, mvm, getSeconds, getId} from "./VmLibs.s.sol";
import {Revert} from "../utils/Funcs.sol";
import {ArbDeploy, addr as Addr} from "../info/ArbDeploy.sol";
import {Json, Factory} from "./Json.s.sol";
import "../IProxyFactory.sol";

import "../support/IDiamond.sol";
import "../vm-ffi/ffi-facets.s.sol";

abstract contract DeployerBase is ArbDeploy, Json {
    string internal _outputDir;
    string internal _cutsDir = "cuts/";
    string internal _upgradeDir = "upgrade/";
    string internal _deployDir = "deploy/";
    string internal _batchDir = "batch/";

    function setOutputDir(string memory dir) external {
        _outputDir = dir;
        _cutsDir = string.concat(dir, "cuts/");
        _upgradeDir = string.concat(dir, "upgrade/");
        _deployDir = string.concat(dir, "deploy/");
        _batchDir = string.concat(dir, "batch/");
    }

    function resetOutputDir() external {
        _outputDir = "";
        _cutsDir = "cuts/";
        _upgradeDir = "upgrade/";
        _deployDir = "deploy/";
        _batchDir = "batch/";
    }

    enum CreateMode {
        Create1,
        Create2,
        Create3,
        Proxy1,
        Proxy2,
        Proxy3
    }

    struct FactoryContract {
        address proxy;
        address prevImpl;
        bytes32 prevHash;
        address newImpl;
        bytes32 newHash;
        bytes32 salt;
        bytes initCode;
        bytes functionCall;
        bytes ctor;
        bytes callData;
        CreateMode mode;
    }
}
