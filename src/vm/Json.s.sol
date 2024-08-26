// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Factory} from "./Factory.s.sol";

abstract contract Json {
    using Factory for *;

    modifier withJSON(string memory _id) {
        _id.initJSON();
        _;
        Factory.writeJSON();
    }
    modifier withJSONS(string memory _id) {
        _id.initJSON();
        jsonKey(_id);
        _;
        jsonKey();
        Factory.writeJSON();
    }

    function jsonStart(string memory _id) internal {
        _id.initJSON();
    }

    function jsonEnd() internal {
        Factory.writeJSON();
    }

    function jsonKey(string memory _key) internal {
        _key.setKey();
    }

    function jsonKey() internal {
        Factory.writeKey();
    }

    function json(address _val, string memory _key) internal {
        _val.set(_key);
    }

    function json(address _val) internal {
        _val.set("address");
    }

    function json(bool _val, string memory _key) internal {
        _val.set(_key);
    }

    function json(uint256 _val, string memory _key) internal {
        _val.set(_key);
    }

    function json(bytes memory _val, string memory _key) internal {
        _val.set(_key);
    }

    function jsons(string memory _id, address _val) internal {
        _id.initJSON();
        jsonKey(_id);
        _val.set(_id);
        Factory.writeJSON();
        jsonKey();
    }

    function jsons(string memory _id, bytes memory _val) internal {
        _id.initJSON();
        jsonKey(_id);
        _val.set(_id);
        jsonKey();
        Factory.writeJSON();
    }

    function jsons(string memory _id, uint256 _val) internal {
        _id.initJSON();
        jsonKey(_id);
        _val.set(_id);
        jsonKey();
        Factory.writeJSON();
    }
}