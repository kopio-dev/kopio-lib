// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Cutter} from "../vm-ffi/Cutter.s.sol";
import {Log, VmHelp} from "./VmLibs.s.sol";
import {Deployment} from "../IProxyFactory.sol";
import {ITransparentUpgradeableProxy} from "../vendor/TransparentUpgradeableProxy.sol";
import {Utils} from "../utils/Libs.sol";

abstract contract UpgradeBase is Cutter {
    using Log for *;
    using Utils for *;
    using VmHelp for *;

    function _upgrade(
        address proxy
    )
        internal
        withJSON(string.concat("upgrade-", proxy.txt(), getTime().str()))
    {
        jsonKey("info");

        (bytes memory ctor, bytes memory impl) = _implementation();
        json(ctor, "ctor");

        bytes memory functionCall = _functionCall();
        json(functionCall, "functionCall");

        Deployment memory upgraded = factory.upgradeAndCall(
            ITransparentUpgradeableProxy(proxy),
            impl,
            functionCall
        );
        address(upgraded.proxy).clg("upgraded-proxy");
        upgraded.implementation.clg("new-implementation");
        json(upgraded.implementation, "new-implementation");
        json(address(upgraded.proxy), "proxy");
        jsonKey();
    }

    function _implementation()
        internal
        view
        virtual
        returns (bytes memory ctor, bytes memory initcode);

    function _functionCall()
        internal
        view
        virtual
        returns (bytes memory callData);
}
