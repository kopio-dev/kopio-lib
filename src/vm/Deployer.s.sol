// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// solhint-disable no-global-import
import "../vm-ffi/Cutter.s.sol";

contract Deployer is Cutter {
    using Log for *;
    using Utils for *;
    using VmHelp for *;

    FactoryContract[] private _batch;
    string private _batchId;

    bytes internal _creationCode;
    bytes internal _ctor;
    bytes internal _callData;
    bool internal _persistDeployment;

    function _implementation()
        internal
        view
        virtual
        returns (bytes memory ctor, bytes memory creationCode)
    {
        ctor = _ctor;
        creationCode = _creationCode;
    }

    function _functionCall()
        internal
        view
        virtual
        returns (bytes memory callData)
    {
        callData = _callData;
    }

    modifier clear() {
        _;
        if (!_persistDeployment) {
            delete _ctor;
            delete _creationCode;
            delete _callData;
        }
    }

    function deploy(
        bytes32 salt,
        CreateMode mode
    )
        internal
        withJSON(deployId(salt, mode))
        clear
        returns (FactoryContract memory)
    {
        return execFactory(_getData(salt, mode, address(0)));
    }

    function upgrade(
        address proxy
    )
        internal
        withJSON(upgradeId(proxy))
        clear
        returns (FactoryContract memory)
    {
        return execFactory(_getData(0, CreateMode.Create1, proxy));
    }

    function deployBatch(
        bytes32 salt,
        CreateMode mode
    ) internal clear returns (uint256) {
        _startBatch();
        _batch.push(_getData(salt, mode, address(0)));
        return _batch.length;
    }

    function upgradeBatch(address proxy) internal clear returns (uint256) {
        _startBatch();
        _batch.push(_getData(0, CreateMode.Create1, proxy));
        return _batch.length;
    }

    function _handleResult(
        FactoryContract memory info,
        bytes memory data
    ) private returns (FactoryContract memory) {
        Deployment memory upgraded = abi.decode(data, (Deployment));
        if (address(upgraded.proxy) != address(0)) {
            address(upgraded.proxy).clg("[PROXY]");
        }
        upgraded.implementation.clg("[IMPL]");

        info.proxy = address(upgraded.proxy);
        info.newImpl = upgraded.implementation;
        if (info.prevImpl != address(0)) info.prevHash = info.prevImpl.codehash;
        info.newHash = upgraded.implementation.codehash;

        return _toJSON(info);
    }

    function _startBatch() internal {
        if (bytes(_batchId).length == 0) {
            _batchId = string.concat("ugprade-batch-", VmHelp.getTime().str());
            jsonStart(_batchId);
        }
    }

    function _endBatch() internal {
        jsonEnd();
        delete _batch;
        delete _batchId;
    }

    function execFactoryBatch()
        internal
        returns (FactoryContract[] memory res)
    {
        if (_batch.length == 0) revert("No upgrades to execute");

        bytes[] memory calls = new bytes[](_batch.length);
        for (uint256 i; i < _batch.length; i++) {
            calls[i] = _batch[i].callData;
        }

        bytes[] memory results = factory.batch(calls);
        for (uint256 i; i < results.length; i++) {
            _batch[i] = _handleResult(_batch[i], results[i]);
        }

        res = _batch;
        _endBatch();
    }

    function execFactory(
        FactoryContract memory args
    ) internal returns (FactoryContract memory) {
        (bool s, bytes memory result) = address(factory).call(args.callData);
        if (!s) Revert(result);

        return _handleResult(args, result);
    }

    function _getData(
        bytes32 salt,
        CreateMode mode,
        address proxy
    ) internal view returns (FactoryContract memory res) {
        (bytes memory ctor, bytes memory creationCode) = _implementation();
        require(creationCode.length > 0, "No code");

        res.initCode = abi.encodePacked(creationCode, res.ctor = ctor);
        res.functionCall = _functionCall();
        res.mode = mode;

        if (proxy != address(0)) {
            res.prevImpl = factory.getImplementation(proxy);
            require(res.prevImpl != address(0), "No proxy");

            res.prevHash = res.prevImpl.codehash;
            res.callData = abi.encodeCall(
                factory.upgradeAndCall,
                (
                    ITransparentUpgradeableProxy(proxy),
                    res.initCode,
                    res.functionCall
                )
            );

            return res;
        }

        if (mode == CreateMode.Create1) {
            res.callData = abi.encodeCall(
                factory.createProxyAndLogic,
                (res.initCode, res.functionCall)
            );
        }

        if (mode == CreateMode.Proxy1) {
            res.callData = abi.encodeCall(
                factory.createProxyAndLogic,
                (res.initCode, res.functionCall)
            );
        }

        if (mode == CreateMode.Create2 || mode == CreateMode.Create3) {
            res.callData = abi.encodeCall(
                mode == CreateMode.Create3
                    ? factory.deployCreate3
                    : factory.deployCreate2,
                (res.initCode, res.functionCall, res.salt = salt)
            );
        }

        if (mode == CreateMode.Proxy2 || mode == CreateMode.Proxy3) {
            res.callData = abi.encodeCall(
                mode == CreateMode.Proxy3
                    ? factory.create3ProxyAndLogic
                    : factory.create2ProxyAndLogic,
                (res.initCode, res.functionCall, res.salt = salt)
            );
        }
    }

    function previewCreate2(
        bytes32 salt,
        bytes memory initCode
    ) public view returns (address addr) {
        (addr) = factory.getCreate2Address(salt, initCode);

        Log.clg(
            "[CREATE2]",
            string.concat(
                "\n    -> Inithash:",
                keccak256(initCode).txt(),
                "\n    -> Salt:",
                salt.txt(),
                "\n    -> Address:",
                addr.txt()
            )
        );
    }

    function previewCreate3(bytes32 salt) public view returns (address addr) {
        (addr) = factory.getCreate3Address(salt);

        Log.clg(
            "[CREATE3]",
            string.concat(
                "\n    -> Salt:",
                salt.txt(),
                "\n    -> Address:",
                addr.txt()
            )
        );
    }

    function previewProxy1(
        address impl,
        bytes memory callData
    ) public returns (address proxy) {
        (, bytes memory result) = address(factory).call(
            bytes.concat(hex"58117864", abi.encode(impl, callData))
        );
        (proxy) = abi.decode(result.slice(4), (address));

        Log.clg(
            "[CREATE1]",
            string.concat(
                "\n    -> Impl:",
                impl.txt(),
                "\n    -> Proxy:",
                proxy.txt()
            )
        );
    }

    function previewProxy1(
        bytes memory ccode,
        bytes memory ctor,
        bytes memory callData
    ) public returns (address proxy, address impl) {
        bytes memory initCode = abi.encodePacked(ccode, ctor);
        (, bytes memory result) = address(factory).call(
            bytes.concat(hex"8c7031aa", abi.encode(initCode, callData))
        );

        (proxy, impl) = abi.decode(result.slice(4), (address, address));

        Log.clg(
            "[CREATE1]",
            string.concat(
                "\n    -> Inithash:",
                keccak256(initCode).txt(),
                "\n    -> Nonce:",
                mvm.getNonce(address(factory)).str(),
                "\n    -> Proxy:",
                proxy.txt(),
                "\n    -> Impl:",
                impl.txt()
            )
        );
    }

    function previewProxy3(
        bytes32 salt
    ) public view returns (address proxy, address impl) {
        (proxy, impl) = factory.previewCreate3ProxyAndLogic(salt);

        Log.clg(
            "[CREATE3]",
            string.concat(
                "\n    -> Salt:",
                salt.txt(),
                "\n    -> Proxy:",
                proxy.txt(),
                "\n    -> Impl:",
                impl.txt()
            )
        );
    }

    function previewProxy2(
        bytes32 salt,
        bytes memory ccode,
        bytes memory ctor,
        bytes memory callData
    ) public view returns (address proxy, address impl) {
        bytes memory initCode = abi.encodePacked(ccode, ctor);
        (proxy, impl) = factory.previewCreate2ProxyAndLogic(
            initCode,
            callData,
            salt
        );

        Log.clg(
            "[CREATE2]",
            string.concat(
                "\n    -> Inithash:",
                keccak256(initCode).txt(),
                "\n    -> Salt:",
                salt.txt(),
                "\n    -> Proxy:",
                proxy.txt(),
                "\n    -> Impl:",
                impl.txt()
            )
        );
    }

    function upgradeId(address proxy) internal returns (string memory) {
        return
            string.concat("upgradeProxy-", proxy.txt(), VmHelp.getTime().str());
    }
    function deployId(
        bytes32 hash,
        CreateMode mode
    ) internal returns (string memory) {
        return
            string.concat(
                "deploy",
                uint8(mode).str(),
                "Proxy-",
                hash.txt(),
                VmHelp.getTime().str()
            );
    }

    function _toJSON(
        FactoryContract memory data
    ) private returns (FactoryContract memory) {
        jsonKey("info");
        json(data.prevImpl, "prevImplAddr");
        json(data.newImpl, "newImplAddr");
        json(bytes.concat(data.prevHash), "prevImplCodehash");
        json(bytes.concat(data.newHash), "newImplCodehash");
        json(data.ctor, "ctor");
        json(data.salt, "salt");
        json(data.functionCall, "functionCall");
        json(data.proxy, "proxyAddr");
        json(uint8(data.mode), "mode");
        jsonKey();

        return data;
    }
}
