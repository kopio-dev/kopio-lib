// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ProxyAdmin} from "@oz/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "./vendor/TransparentUpgradeableProxy.sol";
import {IProxyFactory, CreationKind, Deployment} from "./IProxyFactory.sol";
import {Proxies, Create, Convert, Solady} from "./utils/Deployment.sol";

/**
 * @author the kopio project
 * @title ProxyFactory
 * @notice Deploys contracts, optionally with a {TransparentUpgradeableProxy}. Is the (immutable) admin of proxies.
 * @notice Upgrades of proxies are only available for the owner of the ProxyFactory.
 * @notice Deployments can be made by the owner or whitelisted deployer.
 */
contract ProxyFactory is ProxyAdmin, IProxyFactory {
    using Create for bytes32;
    using Create for bytes;
    using Proxies for address;
    using Convert for bytes32;
    /* -------------------------------------------------------------------------- */
    /*                                    State                                   */
    /* -------------------------------------------------------------------------- */
    mapping(address => bool) private _deployer;
    mapping(address => Deployment) private _deployment;

    Deployment[] private _deploymentList;
    /**
     * @dev Set the initial owner of the contract.
     */
    constructor(address initialOwner) ProxyAdmin(initialOwner) {}

    /* -------------------------------------------------------------------------- */
    /*                                    Auth                                    */
    /* -------------------------------------------------------------------------- */

    modifier onlyDeployerOrOwner() {
        if (!_deployer[_msgSender()]) {
            _checkOwner();
        }
        _;
    }

    function setDeployer(address who, bool value) external onlyOwner {
        if (_deployer[who] == value) revert DeployerAlreadySet(who, value);

        _deployer[who] = value;
        emit DeployerSet(who, value);
    }

    /* -------------------------------------------------------------------------- */
    /*                                    Views                                   */
    /* -------------------------------------------------------------------------- */

    function isDeployer(address who) external view returns (bool) {
        return _deployer[who];
    }

    /// @inheritdoc IProxyFactory
    function getDeployment(
        address addr
    ) external view returns (Deployment memory) {
        return _deployment[addr];
    }

    /// @inheritdoc IProxyFactory
    function getLatestDeployments(
        uint256 count
    ) external view returns (Deployment[] memory result) {
        uint256 length = _deploymentList.length;
        if (count > length) count = length;

        result = new Deployment[](count);
        for (uint256 i = length - count; i < length; i++) {
            result[i - (length - count)] = _deploymentList[i];
        }
    }

    /// @inheritdoc IProxyFactory
    function getDeployByIndex(
        uint256 index
    ) external view returns (Deployment memory) {
        return _deploymentList[index];
    }

    /// @inheritdoc IProxyFactory
    function getDeployments() external view returns (Deployment[] memory) {
        return _deploymentList;
    }

    /// @inheritdoc IProxyFactory
    function getDeployCount() external view returns (uint256) {
        return _deploymentList.length;
    }

    /// @inheritdoc IProxyFactory
    function isDeployment(address addr) external view returns (bool) {
        return _deployment[addr].version != 0;
    }

    /// @inheritdoc IProxyFactory
    function isNonProxy(address addr) external view returns (bool) {
        return
            _deployment[addr].implementation != address(0) &&
            address(_deployment[addr].proxy) == address(0);
    }

    /// @inheritdoc IProxyFactory
    function isProxy(address addr) external view returns (bool) {
        return address(_deployment[addr].proxy) != address(0);
    }

    /// @inheritdoc IProxyFactory
    function isDeterministic(address addr) public view returns (bool) {
        return _deployment[addr].salt != bytes32(0);
    }

    /// @inheritdoc IProxyFactory
    function getImplementation(
        address proxy
    ) external view override returns (address) {
        return _deployment[proxy].implementation;
    }

    /// @inheritdoc IProxyFactory
    function getProxyInitCodeHash(
        address implementation,
        bytes memory _calldata
    ) public view returns (bytes32) {
        return implementation.proxyInitCodeHash(_calldata);
    }

    /// @inheritdoc IProxyFactory
    function getCreate2Address(
        bytes32 salt,
        bytes memory creationCode
    ) public view returns (address) {
        return salt.peek2(address(this), creationCode);
    }

    /// @inheritdoc IProxyFactory
    function getCreate3Address(bytes32 salt) public view returns (address) {
        return salt.peek3();
    }

    function previewCreateProxy(
        address implementation,
        bytes memory _calldata
    ) external returns (address proxyPreview) {
        proxyPreview = address(
            new TransparentUpgradeableProxy(
                implementation,
                address(this),
                _calldata
            )
        );
        revert CreateProxyPreview(proxyPreview);
    }

    /// @inheritdoc IProxyFactory
    function createProxy(
        address implementation,
        bytes memory _calldata
    ) public payable onlyDeployerOrOwner returns (Deployment memory newProxy) {
        newProxy.proxy = address(
            new TransparentUpgradeableProxy(
                implementation,
                address(this),
                _calldata
            )
        ).asInterface();
        newProxy.implementation = implementation;
        newProxy.kind = CreationKind.CREATE;
        return _save(newProxy);
    }

    /// @inheritdoc IProxyFactory
    function previewCreate2Proxy(
        address implementation,
        bytes memory _calldata,
        bytes32 salt
    ) public view returns (address proxyPreview) {
        return getCreate2Address(salt, implementation.proxyInitCode(_calldata));
    }

    /// @inheritdoc IProxyFactory
    function previewCreate3Proxy(
        bytes32 salt
    ) external view returns (address proxyPreview) {
        return getCreate3Address(salt);
    }

    function previewCreateProxyAndLogic(
        bytes memory implementation,
        bytes memory _calldata
    ) external returns (address proxyPreview, address implementationPreview) {
        implementationPreview = address(implementation.create());
        proxyPreview = address(
            new TransparentUpgradeableProxy(
                implementationPreview,
                address(this),
                _calldata
            )
        );
        revert CreateProxyAndLogicPreview(proxyPreview, implementationPreview);
    }

    /// @inheritdoc IProxyFactory
    function previewCreate2ProxyAndLogic(
        bytes memory implementation,
        bytes memory _calldata,
        bytes32 salt
    )
        external
        view
        returns (address proxyPreview, address implementationPreview)
    {
        proxyPreview = previewCreate2Proxy(
            (implementationPreview = getCreate2Address(
                salt.add(1),
                implementation
            )),
            _calldata,
            salt
        );
    }

    /// @inheritdoc IProxyFactory
    function previewCreate3ProxyAndLogic(
        bytes32 salt
    )
        external
        view
        returns (address proxyPreview, address implementationPreview)
    {
        return (salt.peek3(), salt.add(1).peek3());
    }

    /// @inheritdoc IProxyFactory
    function previewCreate2Upgrade(
        ITransparentUpgradeableProxy proxy,
        bytes memory implementation
    ) external view returns (address implementationPreview, uint256 version) {
        Deployment memory info = _deployment[address(proxy)];

        version = info.version + 1;
        if (info.salt == bytes32(0) || version == 1) revert InvalidKind(info);

        return (
            getCreate2Address(info.salt.add(version), implementation),
            version
        );
    }

    /// @inheritdoc IProxyFactory
    function previewCreate3Upgrade(
        ITransparentUpgradeableProxy proxy
    ) external view returns (address implementationPreview, uint256 version) {
        Deployment memory info = _deployment[address(proxy)];

        version = info.version + 1;
        if (info.salt == bytes32(0) || version == 1) revert InvalidKind(info);

        return (getCreate3Address(info.salt.add(version)), version);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  Creation                                  */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IProxyFactory
    function create2Proxy(
        address implementation,
        bytes memory _calldata,
        bytes32 salt
    ) public payable onlyDeployerOrOwner returns (Deployment memory newProxy) {
        newProxy.proxy = salt
            .create2(implementation.proxyInitCode(_calldata))
            .asInterface();
        newProxy.implementation = implementation;
        newProxy.kind = CreationKind.CREATE2;
        newProxy.salt = salt;
        return _save(newProxy);
    }

    /// @inheritdoc IProxyFactory
    function create3Proxy(
        address implementation,
        bytes memory _calldata,
        bytes32 salt
    ) public payable onlyDeployerOrOwner returns (Deployment memory newProxy) {
        newProxy.proxy = salt
            .create3(implementation.proxyInitCode(_calldata))
            .asInterface();
        newProxy.implementation = implementation;
        newProxy.kind = CreationKind.CREATE3;
        newProxy.salt = salt;
        return _save(newProxy);
    }

    /* ---------------------------- With implentation --------------------------- */

    /// @inheritdoc IProxyFactory
    function createProxyAndLogic(
        bytes memory implementation,
        bytes memory _calldata
    ) external payable onlyDeployerOrOwner returns (Deployment memory) {
        return createProxy(implementation.create(), _calldata);
    }

    /// @inheritdoc IProxyFactory
    function create2ProxyAndLogic(
        bytes memory implementation,
        bytes memory _calldata,
        bytes32 salt
    ) external payable onlyDeployerOrOwner returns (Deployment memory) {
        return
            create2Proxy(salt.add(1).create2(implementation), _calldata, salt);
    }

    /// @inheritdoc IProxyFactory
    function create3ProxyAndLogic(
        bytes memory implementation,
        bytes memory _calldata,
        bytes32 salt
    ) external payable onlyDeployerOrOwner returns (Deployment memory) {
        return
            create3Proxy(salt.add(1).create3(implementation), _calldata, salt);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   Upgrade                                  */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IProxyFactory
    function upgradeAndCall(
        ITransparentUpgradeableProxy proxy,
        bytes memory implementation,
        bytes memory _calldata
    ) external payable returns (Deployment memory) {
        return upgradeAndCallReturn(proxy, implementation.create(), _calldata);
    }

    /// @inheritdoc ProxyAdmin
    function upgradeAndCall(
        ITransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory _calldata
    ) public payable override(ProxyAdmin) {
        Deployment memory info = _deployment[address(proxy)];

        info.implementation = implementation;
        ProxyAdmin.upgradeAndCall(proxy, implementation, _calldata);

        _save(info);
    }

    /// @inheritdoc IProxyFactory
    function upgradeAndCallReturn(
        ITransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory _calldata
    ) public payable returns (Deployment memory) {
        Deployment memory info = _deployment[address(proxy)];

        info.implementation = implementation;
        ProxyAdmin.upgradeAndCall(proxy, implementation, _calldata);

        return _save(info);
    }

    /// @inheritdoc IProxyFactory
    function create2UpgradeAndCall(
        ITransparentUpgradeableProxy proxy,
        bytes memory implementation,
        bytes memory _calldata
    ) external payable returns (Deployment memory) {
        Deployment memory info = _deployment[address(proxy)];
        if (info.salt == bytes32(0)) revert InvalidKind(info);
        return
            upgradeAndCallReturn(
                proxy,
                info.salt.add(info.version + 1).create2(implementation),
                _calldata
            );
    }

    /// @inheritdoc IProxyFactory
    function create3UpgradeAndCall(
        ITransparentUpgradeableProxy proxy,
        bytes memory implementation,
        bytes memory _calldata
    ) public payable returns (Deployment memory) {
        Deployment memory info = _deployment[address(proxy)];
        if (info.salt == bytes32(0)) revert InvalidKind(info);
        return
            upgradeAndCallReturn(
                proxy,
                info.salt.add(info.version + 1).create3(implementation),
                _calldata
            );
    }

    /// @inheritdoc IProxyFactory
    function batchStatic(
        bytes[] calldata calls
    ) external view returns (bytes[] memory results) {
        results = new bytes[](calls.length);
        unchecked {
            for (uint256 i; i < calls.length; i++) {
                // solhint-disable-next-line avoid-low-level-calls
                (bool success, bytes memory result) = address(this).staticcall(
                    calls[i]
                );

                if (!success) _tryParseRevert(result);
                results[i] = result;
            }
        }
    }

    function deployCreate2(
        bytes memory creationCode,
        bytes calldata _calldata,
        bytes32 salt
    )
        external
        payable
        onlyDeployerOrOwner
        returns (Deployment memory newDeployment)
    {
        newDeployment.implementation = salt.create2(creationCode);

        if (_calldata.length != 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory result) = newDeployment
                .implementation
                .call{value: msg.value}(_calldata);
            if (!success) _tryParseRevert(result);
        }

        newDeployment.kind = CreationKind.CREATE2;
        newDeployment.salt = salt;

        return _save(newDeployment);
    }

    function deployCreate3(
        bytes memory creationCode,
        bytes calldata _calldata,
        bytes32 salt
    )
        external
        payable
        onlyDeployerOrOwner
        returns (Deployment memory newDeployment)
    {
        newDeployment.implementation = salt.create3(creationCode);

        if (_calldata.length != 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory result) = newDeployment
                .implementation
                .call{value: msg.value}(_calldata);
            if (!success) _tryParseRevert(result);
        }

        newDeployment.kind = CreationKind.CREATE3;
        newDeployment.salt = salt;

        return _save(newDeployment);
    }

    /// @inheritdoc IProxyFactory
    function batch(
        bytes[] calldata calls
    ) external payable onlyDeployerOrOwner returns (bytes[] memory) {
        return Solady.multicall(calls);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  Internals                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Updates deployment fields to _deployment and _deploymentList.
     */
    function _save(
        Deployment memory update
    ) internal returns (Deployment memory) {
        address deploymentAddr = address(update.proxy) != address(0)
            ? address(update.proxy)
            : update.implementation;
        if (deploymentAddr == address(0)) revert InvalidKind(update);

        uint48 blockTimestamp = uint48(block.timestamp);
        update.version++;
        update.updatedAt = blockTimestamp;

        if (update.createdAt == 0) {
            update.index = uint48(_deploymentList.length);
            update.createdAt = blockTimestamp;
            _deploymentList.push(update);
            emit Deployed(update);
        } else {
            _deploymentList[update.index] = update;
            emit Upgrade(update);
        }

        _deployment[deploymentAddr] = update;

        return update;
    }

    /**
     * @notice Function that tries to extract some useful information about a failed call.
     * @dev If returned data is malformed or has incorrect encoding this can fail itself.
     */
    function _tryParseRevert(bytes memory _returnData) internal pure {
        // If the _res length is less than 68, then
        // the transaction failed with custom error or silently (without a revert message)
        if (_returnData.length < 68) {
            revert BatchRevertSilentOrCustomError(_returnData);
        }

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        revert(abi.decode(_returnData, (string))); // All that remains is the revert string
    }
}
