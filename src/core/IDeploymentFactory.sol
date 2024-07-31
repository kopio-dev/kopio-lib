// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {ITransparentUpgradeableProxy} from "../vendor/TransparentUpgradeableProxy.sol";

enum CreationKind {
    NONE,
    CREATE,
    CREATE2,
    CREATE3
}

/**
 * @notice Deployment information
 * @param implementation Current implementation address
 * @param updatedAt Timestamp of latest upgrade
 * @param kind Creation mechanism used for the deployment
 * @param proxy Address of the proxy or zero if not a proxy deployment
 * @param index Array index of the deployment in the internal tracking list
 * @param createdAt Creation timestamp of the deployment
 * @param version Current version of the deployment (can be over 1 for proxies)
 */
struct Deployment {
    address implementation;
    uint88 updatedAt;
    CreationKind kind;
    ITransparentUpgradeableProxy proxy;
    uint48 index;
    uint48 createdAt;
    uint256 version;
    bytes32 salt;
}

interface IDeploymentFactory {
    error BatchRevertSilentOrCustomError(bytes innerError);
    error CreateProxyPreview(address proxy);
    error CreateProxyAndLogicPreview(address proxy, address impl);
    error InvalidKind(Deployment);
    error ArrayLengthMismatch(
        uint256 proxies,
        uint256 implementations,
        uint256 datas
    );
    error InvalidSalt(Deployment);
    error DeployerAlreadySet(address, bool);

    event DeployerSet(address, bool);
    event Deployed(Deployment);
    event Upgrade(Deployment);

    function setDeployer(address _who, bool _to) external;

    function isDeployer(address) external view returns (bool);

    /**
     * @notice Get available deployment information for address.
     * @param addr Address of the contract.
     * @return Deployment Deployment information.
     */
    function getDeployment(
        address addr
    ) external view returns (Deployment memory);

    /**
     * @notice Get the topmost `_count` of deployments.
     * @return Deployment[] List of information about the deployments.
     */
    function getLatestDeployments(
        uint256 _count
    ) external view returns (Deployment[] memory);

    /**
     * @notice Get available information of deployment in index.
     * @param _index Index of the deployment.
     * @return Deployment Deployment information.
     */
    function getDeployByIndex(
        uint256 _index
    ) external view returns (Deployment memory);

    /**
     * @notice Get all deployments.
     * @return Deployment[] Array of deployments.
     */
    function getDeployments() external view returns (Deployment[] memory);

    /**
     * @notice Get number of deployments.
     * @return uint256 Number of deployments.
     */
    function getDeployCount() external view returns (uint256);

    /**
     * @notice Inspect if an address is created by this contract.
     * @param addr Address to inspect
     * @return bool True if deployment was created by this contract.
     */
    function isDeployment(address addr) external view returns (bool);

    /**
     * @notice Inspect if an address is a proxy created by this contract.
     * @param addr Address to inspect
     * @return bool True if proxy was created by this contract.
     */
    function isProxy(address addr) external view returns (bool);

    /// @notice Inspect if an address is a non proxy deployment created by this contract.
    function isNonProxy(address addr) external view returns (bool);

    function isDeterministic(address addr) external view returns (bool);

    /**
     * @notice Inspect the current implementation address of a proxy.
     * @param _proxy Address of the proxy.
     * @return address Implementation address of the proxy
     */
    function getImplementation(address _proxy) external view returns (address);

    /**
     * @notice Get the init code hash for a proxy.
     * @param _impl Address of the implementation.
     * @param _calldata Initializer calldata.
     * @return bytes32 Hash of the init code.
     */
    function getProxyInitCodeHash(
        address _impl,
        bytes memory _calldata
    ) external view returns (bytes32);

    /**
     * @notice Preview address from CREATE2 with given salt and creation code.
     */
    function getCreate2Address(
        bytes32 _salt,
        bytes memory _creationCode
    ) external view returns (address);

    /**
     * @notice Preview address from CREATE3 with given salt.
     */
    function getCreate3Address(bytes32 salt) external view returns (address);

    /**
     * @notice Preview proxy address from {createProxy} through {CreateProxyPreview} custom error.
     * @param _impl Bytecode of the implementation.
     * @param _calldata Initializer calldata.
     * @return proxyAddr Address of the proxy that would be created.
     */
    function previewCreateProxy(
        address _impl,
        bytes memory _calldata
    ) external returns (address proxyAddr);

    /**
     * @notice Preview resulting proxy address from {create2AndCall} with given salt.
     * @param _impl Address of the implementation.
     * @param _calldata Initializer calldata.
     * @param _salt Salt for the deterministic deployment.
     * @return proxyAddr Address of the proxy that would be created.
     */
    function previewCreate2Proxy(
        address _impl,
        bytes memory _calldata,
        bytes32 _salt
    ) external view returns (address proxyAddr);

    /**
     * @notice Preview resulting proxy address from {create3AndCall} or {deployCreate3AndCall} with given salt.
     * @param _salt Salt for the deterministic deployment.
     * @return proxyAddr Address of the proxy that would be created.
     */
    function previewCreate3Proxy(
        bytes32 _salt
    ) external view returns (address proxyAddr);

    /**
     * @notice Preview resulting proxy and implementation address from {deployCreateAndCall} through the {CreateProxyAndLogic} custom error.
     * @param _impl Bytecode of the implementation.
     * @param _calldata Initializer calldata.
     * @return proxyAddr Address of the proxy that would be created.
     * @return implAddr Address of the deployed implementation.
     */
    function previewCreateProxyAndLogic(
        bytes memory _impl,
        bytes memory _calldata
    ) external returns (address proxyAddr, address implAddr);

    /**
     * @notice Preview resulting proxy and implementation address from {deployCreate2AndCall} with given salt.
     * @param _impl Bytecode of the implementation.
     * @param _calldata Initializer calldata.
     * @param _salt Salt for the deterministic deployment.
     * @return proxyAddr Address of the proxy that would be created.
     * @return implAddr Address of the deployed implementation.
     */
    function previewCreate2ProxyAndLogic(
        bytes memory _impl,
        bytes memory _calldata,
        bytes32 _salt
    ) external view returns (address proxyAddr, address implAddr);

    /**
     * @notice Preview implementation and proxy address from {deployCreate3AndCall} with given salt.
     * @param _salt Salt for the deterministic deployment.
     * @return proxyAddr Address of the new proxy.
     * @return implAddr Address of the deployed implementation.
     */
    function previewCreate3ProxyAndLogic(
        bytes32 _salt
    ) external view returns (address proxyAddr, address implAddr);

    /**
     * @notice Preview resulting implementation address from {upgrade2AndCall} with given salt.
     * @param _proxy Existing ITransparentUpgradeableProxy address.
     * @param _impl Bytecode of the new implementation.
     * @return implAddr Address for the next implementation.
     * @return version New version number of the proxy.
     */
    function previewCreate2Upgrade(
        ITransparentUpgradeableProxy _proxy,
        bytes memory _impl
    ) external view returns (address implAddr, uint256 version);

    /**
     * @notice Preview resulting implementation address from {upgrade3AndCall} with given salt.
     * @param _proxy Existing ITransparentUpgradeableProxy address.
     * @return implAddr Address for the next implementation.
     * @return version New version number of the proxy.
     */
    function previewCreate3Upgrade(
        ITransparentUpgradeableProxy _proxy
    ) external view returns (address implAddr, uint256 version);

    /**
     * @notice Creates a new proxy for the `implementation` and initializes it with `data`.
     * @param _impl Address of the implementation.
     * @param _calldata Initializer calldata.
     * @return Deployment information.
     * See {TransparentUpgradeableProxy-constructor}.
     * @custom:signature createProxy(address,bytes)
     * @custom:selector 0x61b69abd
     */
    function createProxy(
        address _impl,
        bytes memory _calldata
    ) external payable returns (Deployment memory);

    /**
     * @notice Creates a new proxy with deterministic address derived from arguments given.
     * @param _impl Address of the implementation.
     * @param _calldata Initializer calldata.
     * @param _salt Salt for the deterministic deployment.
     * @return Deployment information.
     * @custom:signature create2Proxy(address,bytes,bytes32)
     * @custom:selector 0xd2492cd5
     */
    function create2Proxy(
        address _impl,
        bytes memory _calldata,
        bytes32 _salt
    ) external payable returns (Deployment memory);

    /**
     * @notice Creates a new proxy with deterministic address derived only from the salt given.
     * @param _impl Address of the implementation.
     * @param _calldata Initializer calldata.
     * @param _salt Salt for the deterministic deployment.
     * @return Deployment information.
     * @custom:signature create3Proxy(address,bytes,bytes32)
     * @custom:selector 0xfe9438ed
     */
    function create3Proxy(
        address _impl,
        bytes memory _calldata,
        bytes32 _salt
    ) external payable returns (Deployment memory);

    /**
     * @notice Deploys an implementation and creates a proxy initialized with `data` for it.
     * @param _impl Bytecode of the implementation.
     * @param _calldata Initializer calldata.
     * @return Deployment information.
     * @custom:signature createProxyAndLogic(bytes,bytes)
     * @custom:selector 0xfc35acd4
     */
    function createProxyAndLogic(
        bytes memory _impl,
        bytes memory _calldata
    ) external payable returns (Deployment memory);

    /**
     * @notice Deterministic version of {deployCreateAndCall} where arguments are used to derive the salt.
     * @dev Implementation salt is salt + 1. Use {previewDeployCreate3} to preview.
     * @param _impl Bytecode of the implementation.
     * @param _calldata Initializer calldata.
     * @param _salt Salt to derive both addresses from.
     * @return Deployment information.
     * @custom:signature create2ProxyAndLogic(bytes,bytes,bytes32)
     * @custom:selector 0xfb18a521
     */
    function create2ProxyAndLogic(
        bytes memory _impl,
        bytes memory _calldata,
        bytes32 _salt
    ) external payable returns (Deployment memory);

    /**
     * @notice Deterministic version of {deployCreateAndCall} where only salt matters.
     * @dev Implementation salt is salt + 1. Use {previewDeployCreate3} to preview.
     * @param _impl Bytecode of the implementation to deploy.
     * @param _calldata Initializer calldata.
     * @param _salt Salt to derive both addresses from.
     * @return Deployment information.
     * @custom:signature create3ProxyAndLogic(bytes,bytes,bytes32)
     * @custom:selector 0x4e09282f
     */
    function create3ProxyAndLogic(
        bytes memory _impl,
        bytes memory _calldata,
        bytes32 _salt
    ) external payable returns (Deployment memory);

    /// @notice Deploys the @param _impl through {upgradeAndCall} and @return Deployment information.
    function upgradeAndCall(
        ITransparentUpgradeableProxy _proxy,
        bytes memory _impl,
        bytes memory _calldata
    ) external payable returns (Deployment memory);

    /// @notice Same as {upgradeAndCall} but @return Deployment information.
    function upgradeAndCallReturn(
        ITransparentUpgradeableProxy _proxy,
        address _impl,
        bytes memory _calldata
    ) external payable returns (Deployment memory);

    /**
     * @notice Deterministically deploys the upgrade implementation and calls the {ProxyAdmin-upgradeAndCall}.
     * @dev Implementation salt is salt + next version. Use {previewUpgrade2} to preview.
     * @param _proxy Existing proxy to upgrade.
     * @param _impl Bytecode of the new implementation.
     * @param _calldata Initializer calldata.
     * @return Deployment Deployment information.
     */
    function create2UpgradeAndCall(
        ITransparentUpgradeableProxy _proxy,
        bytes memory _impl,
        bytes memory _calldata
    ) external payable returns (Deployment memory);

    /**
     * @notice Deterministically deploys the upgrade implementatio and calls the {ProxyAdmin-upgradeAndCall}.
     * @dev Implementation salt is salt + next version. Use {previewUpgrade3} to preview.
     * @param _proxy Existing proxy to upgrade.
     * @param _impl Bytecode of the new implementation.
     * @param _calldata Initializer calldata.
     * @return Deployment information.
     */
    function create3UpgradeAndCall(
        ITransparentUpgradeableProxy _proxy,
        bytes memory _impl,
        bytes memory _calldata
    ) external payable returns (Deployment memory);

    /**
     * @notice Deploy contract using create2.
     * @param _code The creation code (bytes).
     * @param _calldata The calldata (bytes).
     * @param salt The salt (bytes32).
     * @return Deployment information.
     * @custom:signature deployCreate2(bytes,bytes,bytes32)
     * @custom:selector 0x2197eeb6
     */
    function deployCreate2(
        bytes memory _code,
        bytes memory _calldata,
        bytes32 salt
    ) external payable returns (Deployment memory);

    /**
     * @notice Deploy contract using create3.
     * @param _code The creation code (bytes).
     * @param _calldata The calldata (bytes).
     * @param salt The salt (bytes32).
     * @return newDeployment Deployment information.
     * @custom:signature deployCreate3(bytes,bytes,bytes32)
     * @custom:selector 0xa3419e18
     */
    function deployCreate3(
        bytes memory _code,
        bytes memory _calldata,
        bytes32 salt
    ) external payable returns (Deployment memory);

    /**
     * @notice Batch any action in this contract.
     * @dev Reverts if any of the calls fail.
     * @dev Delegates to self which keeps context, so msg.value is fine.
     * @custom:signature batch(bytes[])
     * @custom:selector 0x1e897afb
     */
    function batch(bytes[] calldata) external payable returns (bytes[] memory);

    /**
     * @notice Batch view data from this contract.
     * @custom:signature batchStatic(bytes[])
     * @custom:selector 0xdf0d7fe5
     */
    function batchStatic(
        bytes[] calldata
    ) external view returns (bytes[] memory);
}
