// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Factory} from "./Factory.s.sol";

abstract contract Files {
    modifier withJSON(string memory _id) {
        Factory.initJSON(_id);
        _;
        Factory.writeJSON();
    }

    function jsonStart(string memory _id) internal {
        Factory.initJSON(_id);
    }

    function jsonEnd() internal {
        Factory.writeJSON();
    }

    function jsonKey(string memory _key) internal {
        Factory.setKey(_key);
    }

    function jsonKey() internal {
        Factory.writeKey();
    }

    function json(address _val, string memory _key) internal {
        Factory.set(_val, _key);
    }

    function json(address _val) internal {
        Factory.set(_val, "address");
    }

    function json(bool _val, string memory _key) internal {
        Factory.set(_val, _key);
    }

    function json(uint256 _val, string memory _key) internal {
        Factory.set(_val, _key);
    }

    function json(bytes memory _val, string memory _key) internal {
        Factory.set(_val, _key);
    }

    function jsons(string memory _id, address _val) internal {
        Factory.initJSON(_id);
        Factory.set(_val, _id);
        Factory.writeJSON();
    }

    function jsons(string memory _id, bytes memory _val) internal {
        Factory.initJSON(_id);
        Factory.set(_val, _id);
        Factory.writeJSON();
    }

    function jsons(string memory _id, uint256 _val) internal {
        Factory.initJSON(_id);
        Factory.set(_val, _id);
        Factory.writeJSON();
    }
}
