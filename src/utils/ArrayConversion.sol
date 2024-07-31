// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ArrayConversion {
    event log_array(uint256[] val);
    event log_array(int256[] val);
    event log_array(address[] val);
    event log_named_array(string key, uint256[] val);
    event log_named_array(string key, int256[] val);
    event log_named_array(string key, address[] val);

    using ArrayConversion for *;

    function arr(address _v1) internal pure returns (address[] memory d_) {
        d_ = new address[](1);
        d_[0] = _v1;
    }

    function clg(uint256[2] memory _val, string memory _lbl) internal {
        emit log_named_array(_lbl, _val.dyn());
    }

    function arr(
        address _v1,
        address _v2
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](2);
        d_[0] = _v1;
        d_[1] = _v2;
    }

    function arr(
        address _v1,
        address _v2,
        address _v3
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](3);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
    }

    function arr(
        address _v1,
        address _v2,
        address _v3,
        address _v4
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](4);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
        d_[3] = _v4;
    }

    function arr(uint16 _value) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](1);
        d_[0] = _value;
    }

    function arr(
        uint16 _v1,
        uint16 _v2
    ) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](2);
        d_[0] = _v1;
        d_[1] = _v2;
    }

    function arr(
        uint16 _v1,
        uint16 _v2,
        uint16 _v3
    ) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](3);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
    }

    function arr(uint32 _value) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](1);
        d_[0] = _value;
    }

    function arr(
        uint32 _v1,
        uint32 _v2
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](2);
        d_[0] = _v1;
        d_[1] = _v2;
    }

    function arr(
        uint32 _v1,
        uint32 _v2,
        uint32 _v3
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](3);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
    }

    function arr(uint256 _value) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](1);
        d_[0] = _value;
    }

    function arr(
        uint256 _v1,
        uint256 _v2
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](2);
        d_[0] = _v1;
        d_[1] = _v2;
    }

    function arr(
        uint256 _v1,
        uint256 _v2,
        uint256 _v3
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](3);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
    }

    function arr(
        uint256 _v1,
        uint256 _v2,
        uint256 _v3,
        uint256 _v4
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](4);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
        d_[3] = _v4;
    }

    function arr(
        uint256 _v1,
        uint256 _v2,
        uint256 _v3,
        uint256 _v4,
        uint256 _v5
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](5);
        d_[0] = _v1;
        d_[1] = _v2;
        d_[2] = _v3;
        d_[3] = _v4;
        d_[4] = _v5;
    }

    function dyn(
        address[1] memory _f
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](1);
        d_[0] = _f[0];
        return d_;
    }

    function dyn(
        address[2] memory _f
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](2);
        d_[0] = _f[0];
        d_[1] = _f[1];
        return d_;
    }

    function dyn(
        address[3] memory _f
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](3);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        return d_;
    }

    function dyn(
        address[4] memory _f
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](4);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        return d_;
    }

    function dyn(
        address[5] memory _f
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](5);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        return d_;
    }

    function dyn(
        address[6] memory _f
    ) internal pure returns (address[] memory d_) {
        d_ = new address[](6);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        d_[5] = _f[5];
        return d_;
    }

    function dyn(uint8[1] memory _f) internal pure returns (uint8[] memory d_) {
        d_ = new uint8[](1);
        d_[0] = _f[0];
        return d_;
    }

    function dyn(uint8[2] memory _f) internal pure returns (uint8[] memory d_) {
        d_ = new uint8[](2);
        d_[0] = _f[0];
        d_[1] = _f[1];
        return d_;
    }

    function dyn256(
        uint8[2] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](2);
        d_[0] = _f[0];
        d_[1] = _f[1];
        return d_;
    }

    function arr(
        uint8 _v1,
        uint8 _v2
    ) internal pure returns (uint8[] memory d_) {
        d_ = new uint8[](2);
        d_[0] = _v1;
        d_[1] = _v2;
    }

    function arr256(
        uint8 _v1,
        uint8 _v2
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](2);
        d_[0] = _v1;
        d_[1] = _v2;
    }

    function fix(uint8[] memory _f) internal pure returns (uint8[2] memory) {
        require(_f.length >= 2, "Invalid length");
        return [_f[0], _f[1]];
    }

    function flip(uint8[2] memory _f) internal pure returns (uint8[2] memory) {
        return [_f[1], _f[0]];
    }

    function dyn(
        uint16[1] memory _f
    ) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](1);
        d_[0] = _f[0];
        return d_;
    }

    function dyn(
        uint16[2] memory _f
    ) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](2);
        d_[0] = _f[0];
        d_[1] = _f[1];
        return d_;
    }

    function dyn(
        uint16[3] memory _f
    ) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](3);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        return d_;
    }

    function dyn(
        uint16[4] memory _f
    ) internal pure returns (uint16[] memory d_) {
        d_ = new uint16[](4);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        return d_;
    }

    function dyn(
        uint32[1] memory _f
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](1);
        d_[0] = _f[0];
        return d_;
    }

    function dyn(
        uint32[2] memory _f
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](2);
        d_[0] = _f[0];
        d_[1] = _f[1];
        return d_;
    }

    function dyn(
        uint32[3] memory _f
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](3);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        return d_;
    }

    function dyn(
        uint32[4] memory _f
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](4);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        return d_;
    }

    function dyn(
        uint32[5] memory _f
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](5);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        return d_;
    }

    function dyn(
        uint32[6] memory _f
    ) internal pure returns (uint32[] memory d_) {
        d_ = new uint32[](6);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        d_[5] = _f[5];
        return d_;
    }

    function dyn(
        uint256[1] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](1);
        d_[0] = _f[0];
        return d_;
    }

    function dyn(
        uint256[2] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](2);
        d_[0] = _f[0];
        d_[1] = _f[1];
        return d_;
    }

    function dyn(
        uint256[3] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](3);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        return d_;
    }

    function dyn(
        uint256[4] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](4);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        return d_;
    }

    function dyn(
        uint256[5] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](5);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        return d_;
    }

    function dyn(
        uint256[6] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](6);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        d_[5] = _f[5];
        return d_;
    }

    function dyn(
        uint256[7] memory _f
    ) internal pure returns (uint256[] memory d_) {
        d_ = new uint256[](7);
        d_[0] = _f[0];
        d_[1] = _f[1];
        d_[2] = _f[2];
        d_[3] = _f[3];
        d_[4] = _f[4];
        d_[5] = _f[5];
        d_[6] = _f[6];
        return d_;
    }

    function clg(uint8[2] memory _val, string memory _lbl) internal {
        emit log_named_array(_lbl, _val.dyn256());
    }

    function clg(uint8 _val1, uint8 _val2, string memory _lbl) internal {
        emit log_named_array(_lbl, [_val1, _val2].dyn256());
    }

    function clg(string memory _lbl, uint8[2] memory _val) internal {
        emit log_named_array(_lbl, _val.dyn256());
    }

    function clg(string memory _lbl, uint8 _val1, uint8 _val2) internal {
        emit log_named_array(_lbl, [_val1, _val2].dyn256());
    }

    function clg(string memory _lbl, uint256[2] memory _val) internal {
        emit log_named_array(_lbl, _val.dyn());
    }
}
