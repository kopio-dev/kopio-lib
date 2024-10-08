// SPDX-License-Identifier: MIT
// solhint-disable

pragma solidity ^0.8.0;
import {Deployment, IProxyFactory} from "../IProxyFactory.sol";
import {mvm} from "./MinVm.s.sol";
import {iFactory} from "../info/ArbDeploy.sol";

library Factory {
    struct FactoryState {
        IProxyFactory factory;
        string id;
        string outputLocation;
        string currentKey;
        string currentJson;
        string outputJson;
        bool disableLog;
    }

    bytes32 internal constant FACTORY_STATE_SLOT =
        keccak256("vm.factory.state.slot");

    function initJSON(string memory cfgId) internal {
        initJSON("", cfgId);
    }

    function initJSON(string memory dir, string memory cfgId) internal {
        string memory outDir = string.concat(
            "./temp/",
            mvm.toString(block.chainid),
            "/",
            dir
        );
        if (!mvm.exists(outDir)) mvm.createDir(outDir, true);
        data().id = cfgId;
        data().outputLocation = outDir;
        data().outputJson = cfgId;
        data().currentKey = "";
        data().currentJson = "";
    }

    function writeJSON() internal {
        string memory runsDir = string.concat(data().outputLocation, "runs/");
        if (!mvm.exists(runsDir)) mvm.createDir(runsDir, true);
        mvm.writeFile(
            string.concat(
                runsDir,
                data().id,
                "-",
                mvm.toString(mvm.unixTime()),
                ".json"
            ),
            data().outputJson
        );
        mvm.writeFile(
            string.concat(
                data().outputLocation,
                data().id,
                "-",
                "latest",
                ".json"
            ),
            data().outputJson
        );

        resetJSON();
    }

    function resetJSON() internal {
        data().id = "";
        data().currentKey = "";
        data().currentJson = "";
        data().outputLocation = "";
        data().outputJson = "";
    }

    function data() internal pure returns (FactoryState storage ds) {
        bytes32 slot = FACTORY_STATE_SLOT;
        assembly {
            ds.slot := slot
        }
    }

    modifier saveOutput(string memory _id) {
        setKey(_id);
        _;
        writeKey();
    }

    function setKey(string memory _id) internal {
        data().currentKey = _id;
        data().currentJson = "";
    }

    function set(address _val, string memory _key) internal {
        data().currentJson = mvm.serializeAddress(
            data().currentKey,
            _key,
            _val
        );
    }

    function set(string memory _val, string memory _key) internal {
        data().currentJson = mvm.serializeString(data().currentKey, _key, _val);
    }

    function set(bool _val, string memory _key) internal {
        data().currentJson = mvm.serializeBool(data().currentKey, _key, _val);
    }

    function set(uint256 _val, string memory _key) internal {
        data().currentJson = mvm.serializeUint(data().currentKey, _key, _val);
    }

    function set(bytes memory _val, string memory _key) internal {
        data().currentJson = mvm.serializeBytes(data().currentKey, _key, _val);
    }

    function writeKey() internal {
        data().outputJson = mvm.serializeString(
            string.concat(data().id, "-out"),
            data().currentKey,
            data().currentJson
        );
    }

    function pd3(bytes32 _salt) internal view returns (address) {
        return iFactory.getCreate3Address(_salt);
    }

    function pp3(bytes32 _salt) internal view returns (address, address) {
        return iFactory.previewCreate3ProxyAndLogic(_salt);
    }

    function ctor(
        bytes memory _contract,
        bytes memory _args
    ) internal returns (bytes memory ccode_) {
        set(_args, "ctor");
        return abi.encodePacked(_contract, _args);
    }

    function d2(
        bytes memory _ccode,
        bytes memory _initCall,
        bytes32 _salt
    ) internal returns (Deployment memory result_) {
        result_ = iFactory.deployCreate2(_ccode, _initCall, _salt);
        set(result_.implementation, "address");
    }

    function d3(
        bytes memory ccode,
        bytes memory _initCall,
        bytes32 _salt
    ) internal returns (Deployment memory result_) {
        result_ = iFactory.deployCreate3(ccode, _initCall, _salt);
        set(result_.implementation, "address");
    }

    function p3(
        bytes memory ccode,
        bytes memory _initCall,
        bytes32 _salt
    ) internal returns (Deployment memory result_) {
        result_ = iFactory.create3ProxyAndLogic(ccode, _initCall, _salt);
        set(address(result_.proxy), "address");
        set(
            abi.encode(result_.implementation, address(iFactory), _initCall),
            "initializer"
        );
        set(result_.implementation, "implementation");
    }
}
