// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable no-global-import, no-unused-import
import "../vendor/TransparentUpgradeableProxy.sol";

import {Utils} from "../utils/Libs.sol";
import {Log, VmHelp, mvm, getSeconds, getId} from "./VmLibs.s.sol";
import {Revert} from "../utils/Funcs.sol";
import {ArbDeploy} from "../info/ArbDeploy.sol";
import {Json, Factory} from "./Json.s.sol";
import "../IProxyFactory.sol";

import "../support/IDiamond.sol";
import "../vm-ffi/ffi-facets.s.sol";

abstract contract DeployerBase is ArbDeploy, Json {
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
