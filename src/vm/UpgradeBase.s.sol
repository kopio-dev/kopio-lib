// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Cutter, Revert} from "../vm-ffi/Cutter.s.sol";
import {Log, VmHelp} from "./VmLibs.s.sol";
import {Deployment} from "../IProxyFactory.sol";
import {ITransparentUpgradeableProxy} from "../vendor/TransparentUpgradeableProxy.sol";
import {Utils} from "../utils/Libs.sol";

struct ProxyUpgrade {
    address proxy;
    address prevImpl;
    bytes32 prevHash;
    address newImpl;
    bytes32 newHash;
    bytes functionCall;
    bytes ctor;
    bytes callData;
}

abstract contract UpgradeBase is Cutter {
    using Log for *;
    using Utils for *;
    using VmHelp for *;

    ProxyUpgrade[] private _upgrades;
    string private _batchId;

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

    function _upgrade(address proxy) internal returns (ProxyUpgrade memory) {
        return _upgrade(proxy, false);
    }

    function _upgrade(
        address proxy,
        bool batch
    )
        internal
        withJSON(string.concat("upgrade-", proxy.txt(), VmHelp.getTime().str()))
        returns (ProxyUpgrade memory res)
    {
        res.prevImpl = factory.getImplementation(proxy);
        res.prevHash = res.prevImpl.codehash;

        (bytes memory ctor, bytes memory impl) = _implementation();

        res.newHash = keccak256(impl);
        res.ctor = ctor;
        res.functionCall = _functionCall();
        res.callData = abi.encodeCall(
            factory.upgradeAndCall,
            (ITransparentUpgradeableProxy(proxy), impl, res.functionCall)
        );
        if (batch) {
            _upgrades.push(res);
        } else {
            (bool s, bytes memory upgrade) = address(factory).call(
                res.callData
            );
            if (!s) Revert(upgrade);

            return _handleResult(res, upgrade);
        }
    }

    function _upgradeBatch(address proxy) internal returns (uint256) {
        _startBatch();
        _upgrade(proxy, true);
        return _upgrades.length;
    }

    function _upgradeBatch() internal returns (ProxyUpgrade[] memory res) {
        bytes[] memory calls = new bytes[](_upgrades.length);

        for (uint256 i; i < _upgrades.length; i++)
            calls[i] = _upgrades[i].callData;

        bytes[] memory deploys = factory.batch(calls);

        for (uint256 i; i < deploys.length; i++) {
            _upgrades[i] = _handleResult(_upgrades[i], deploys[i]);
        }

        res = _upgrades;

        _endBatch();
    }

    function _handleResult(
        ProxyUpgrade memory info,
        bytes memory data
    ) private returns (ProxyUpgrade memory) {
        Deployment memory upgraded = abi.decode(data, (Deployment));
        address(upgraded.proxy).clg("upgraded-proxy");
        upgraded.implementation.clg("new-implementation");

        info.proxy = address(upgraded.proxy);
        info.newImpl = upgraded.implementation;
        info.newHash = upgraded.implementation.codehash;

        return _toJSON(info);
    }

    function _startBatch() internal {
        if (bytes(_batchId).length == 0) {
            _batchId = string.concat(
                "ugprade-batch-",
                string(bytes.concat(VmHelp.getRandomId()))
            );
            jsonStart(_batchId);
        }
    }

    function _endBatch() internal {
        jsonEnd();
        delete _upgrades;
        delete _batchId;
    }

    function _toJSON(
        ProxyUpgrade memory data
    ) private returns (ProxyUpgrade memory) {
        jsonKey("info");
        json(data.prevImpl, "prev-implementation");
        json(bytes.concat(data.prevHash), "prev-implementation-codehash");
        json(bytes.concat(data.newHash), "new-implementation-codehash");
        json(data.ctor, "ctor");
        json(data.functionCall, "functionCall");
        json(data.newImpl, "new-implementation");
        json(data.proxy, "proxy");
        jsonKey();

        return data;
    }
}
