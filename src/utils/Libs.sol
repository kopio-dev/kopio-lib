// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
    using Utils for *;

    function toDec(
        uint256 _val,
        uint8 _from,
        uint8 _to
    ) internal pure returns (uint256) {
        if (_val == 0 || _from == _to) return _val;

        if (_from < _to) {
            return _val * (10 ** (_to - _from));
        }
        return _val / (10 ** (_from - _to));
    }

    function toWad(int256 _val, uint8 _dec) internal pure returns (uint256) {
        if (_val < 0) revert("-");
        return toWad(uint256(_val), _dec);
    }

    function toWad(uint256 _val, uint8 _dec) internal pure returns (uint256) {
        return toDec(_val, _dec, 18);
    }

    function fromWad(uint256 _val, uint8 _dec) internal pure returns (uint256) {
        return toDec(_val, 18, _dec);
    }

    struct FindResult {
        uint256 index;
        bool exists;
    }

    error ELEMENT_NOT_FOUND(uint256 idx, uint256 length);

    function find(
        address[] storage _els,
        address _el
    ) internal pure returns (FindResult memory result) {
        address[] memory els = _els;
        for (uint256 i; i < els.length; ) {
            if (els[i] == _el) return FindResult(i, true);
            unchecked {
                ++i;
            }
        }
    }

    function find(
        bytes32[] storage _els,
        bytes32 _el
    ) internal pure returns (FindResult memory result) {
        bytes32[] memory els = _els;
        for (uint256 i; i < els.length; ) {
            if (els[i] == _el) return FindResult(i, true);
            unchecked {
                ++i;
            }
        }
    }

    function find(
        string[] storage _els,
        string memory _el
    ) internal pure returns (FindResult memory result) {
        string[] memory els = _els;
        for (uint256 i; i < els.length; ) {
            if (els[i].equals(_el)) return FindResult(i, true);
            unchecked {
                ++i;
            }
        }
    }

    function pushUnique(address[] storage _arr, address _val) internal {
        if (!_arr.find(_val).exists) _arr.push(_val);
    }

    function pushUnique(bytes32[] storage _arr, bytes32 _val) internal {
        if (!_arr.find(_val).exists) _arr.push(_val);
    }

    function pushUnique(string[] storage _arr, string memory _val) internal {
        if (!_arr.find(_val).exists) _arr.push(_val);
    }

    function removeExisting(address[] storage _arr, address _val) internal {
        FindResult memory r = _arr.find(_val);
        if (r.exists) _arr.removeAddress(_val, r.index);
    }

    function removeAddress(
        address[] storage _arr,
        address _val,
        uint256 _idx
    ) internal {
        if (_arr[_idx] != _val) revert ELEMENT_NOT_FOUND(_idx, _arr.length);

        uint256 last = _arr.length - 1;
        if (_idx != last) _arr[_idx] = _arr[last];
        _arr.pop();
    }

    function zero(address[2] memory _arr) internal pure returns (bool) {
        return _arr[0] == address(0) && _arr[1] == address(0);
    }

    function zero(string memory _val) internal pure returns (bool) {
        return bytes(_val).length == 0;
    }

    function equals(
        string memory _a,
        string memory _b
    ) internal pure returns (bool) {
        return equals(bytes(_a), bytes(_b));
    }

    function equals(
        bytes memory _a,
        bytes memory _b
    ) internal pure returns (bool) {
        return keccak256(_a) == keccak256(_b);
    }

    function str(bytes32 _val) internal pure returns (string memory) {
        return str(bytes.concat(_val));
    }

    function str(bytes memory _val) internal pure returns (string memory res) {
        for (uint256 i; i < _val.length; i++) {
            if (_val[i] != 0)
                res = string.concat(res, string(bytes.concat(_val[i])));
        }
    }

    function dstr(uint256 _val) internal pure returns (string memory) {
        return dstr(_val, 18);
    }

    function dstr(
        uint256 _val,
        uint256 _dec
    ) internal pure returns (string memory) {
        uint256 ds = 10 ** _dec;

        bytes memory d = bytes(str(_val % ds));
        (d = bytes.concat(bytes(str(10 ** (_dec - d.length))), d))[0] = 0;

        for (uint256 i = d.length; --i > 2; d[i] = 0) if (d[i] != "0") break;

        return string.concat(str(_val / ds), ".", str(d));
    }

    function str(uint256 _val) internal pure returns (string memory s) {
        unchecked {
            if (_val == 0) return "0";
            else {
                uint256 c1 = itoa32(_val % 1e32);
                _val /= 1e32;
                if (_val == 0) s = string(abi.encode(c1));
                else {
                    uint256 c2 = itoa32(_val % 1e32);
                    _val /= 1e32;
                    if (_val == 0) {
                        s = string(abi.encode(c2, c1));
                        c1 = c2;
                    } else {
                        uint256 c3 = itoa32(_val);
                        s = string(abi.encode(c3, c2, c1));
                        c1 = c3;
                    }
                }
                uint256 z = 0;
                if (c1 >> 128 == 0x30303030303030303030303030303030) {
                    c1 <<= 128;
                    z += 16;
                }
                if (c1 >> 192 == 0x3030303030303030) {
                    c1 <<= 64;
                    z += 8;
                }
                if (c1 >> 224 == 0x30303030) {
                    c1 <<= 32;
                    z += 4;
                }
                if (c1 >> 240 == 0x3030) {
                    c1 <<= 16;
                    z += 2;
                }
                if (c1 >> 248 == 0x30) {
                    z += 1;
                }
                assembly {
                    let l := mload(s)
                    s := add(s, z)
                    mstore(s, sub(l, z))
                }
            }
        }
    }

    function itoa32(uint256 x) private pure returns (uint256 y) {
        unchecked {
            require(x < 1e32);
            y = 0x3030303030303030303030303030303030303030303030303030303030303030;
            y += x % 10;
            x /= 10;
            y += x % 10 << 8;
            x /= 10;
            y += x % 10 << 16;
            x /= 10;
            y += x % 10 << 24;
            x /= 10;
            y += x % 10 << 32;
            x /= 10;
            y += x % 10 << 40;
            x /= 10;
            y += x % 10 << 48;
            x /= 10;
            y += x % 10 << 56;
            x /= 10;
            y += x % 10 << 64;
            x /= 10;
            y += x % 10 << 72;
            x /= 10;
            y += x % 10 << 80;
            x /= 10;
            y += x % 10 << 88;
            x /= 10;
            y += x % 10 << 96;
            x /= 10;
            y += x % 10 << 104;
            x /= 10;
            y += x % 10 << 112;
            x /= 10;
            y += x % 10 << 120;
            x /= 10;
            y += x % 10 << 128;
            x /= 10;
            y += x % 10 << 136;
            x /= 10;
            y += x % 10 << 144;
            x /= 10;
            y += x % 10 << 152;
            x /= 10;
            y += x % 10 << 160;
            x /= 10;
            y += x % 10 << 168;
            x /= 10;
            y += x % 10 << 176;
            x /= 10;
            y += x % 10 << 184;
            x /= 10;
            y += x % 10 << 192;
            x /= 10;
            y += x % 10 << 200;
            x /= 10;
            y += x % 10 << 208;
            x /= 10;
            y += x % 10 << 216;
            x /= 10;
            y += x % 10 << 224;
            x /= 10;
            y += x % 10 << 232;
            x /= 10;
            y += x % 10 << 240;
            x /= 10;
            y += x % 10 << 248;
        }
    }

    uint256 internal constant PCT_F = 1e4;
    uint256 internal constant HALF_PCT_F = 0.5e4;

    function pmul(
        uint256 _val,
        uint256 _pct
    ) internal pure returns (uint256 result) {
        assembly {
            if iszero(
                or(
                    iszero(_pct),
                    iszero(gt(_val, div(sub(not(0), HALF_PCT_F), _pct)))
                )
            ) {
                revert(0, 0)
            }

            result := div(add(mul(_val, _pct), HALF_PCT_F), PCT_F)
        }
    }

    function pdiv(
        uint256 _val,
        uint256 _pct
    ) internal pure returns (uint256 result) {
        assembly {
            if or(
                iszero(_pct),
                iszero(iszero(gt(_val, div(sub(not(0), div(_pct, 2)), PCT_F))))
            ) {
                revert(0, 0)
            }

            result := div(add(mul(_val, PCT_F), div(_pct, 2)), _pct)
        }
    }

    uint256 internal constant WAD = 1e18;
    uint256 internal constant HALF_WAD = 0.5e18;

    function wmul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assembly {
            if iszero(
                or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_WAD), b))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, b), HALF_WAD), WAD)
        }
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assembly {
            if or(
                iszero(b),
                iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD))))
            ) {
                revert(0, 0)
            }

            c := div(add(mul(a, WAD), div(b, 2)), b)
        }
    }

    error Overflow(uint256, uint256);

    function slice(
        bytes memory _b,
        uint256 _s
    ) internal pure returns (bytes memory res) {
        return slice(_b, _s, 32);
    }

    function slice(
        bytes memory _b,
        uint256 _s,
        uint256 _l
    ) internal pure returns (bytes memory res) {
        if (_b.length < _s + _l) revert Overflow(_b.length, _s + _l);
        if (_l > 32) revert Overflow(32, _l);
        assembly {
            mstore(res, _l)
            mstore(add(res, 0x20), mload(add(_b, add(0x20, _s))))
        }
    }

    function cc(
        string memory _a,
        string memory _b
    ) internal pure returns (string memory) {
        return string.concat(_a, _b);
    }
    function cc(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory) {
        return string.concat(_a, _b, _c);
    }
    function cc(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory) {
        return string.concat(_a, _b, _c, _d);
    }

    function toAddress(bytes32 b) internal pure returns (address) {
        return address(uint160(uint256(b)));
    }

    function toBytes32(address a) internal pure returns (bytes32) {
        return bytes32(bytes20(uint160(a)));
    }

    function toAddr(bytes memory b) internal pure returns (address) {
        return abi.decode(b, (address));
    }

    function toArray(
        bytes memory value
    ) internal pure returns (bytes[] memory result) {
        result = new bytes[](1);
        result[0] = value;
    }

    function add(bytes32 a, uint256 b) internal pure returns (bytes32) {
        return bytes32(uint256(a) + b);
    }

    function sub(bytes32 a, uint256 b) internal pure returns (bytes32) {
        return bytes32(uint256(a) - b);
    }
}

library Meta {
    using Utils for string;
    struct Result {
        string name;
        string symbol;
        string fkName;
        string fkSymbol;
        bytes32 kSalt;
        bytes32 fkSalt;
    }

    struct Salts {
        bytes32 kopio;
        bytes32 share;
    }

    struct SaltResult {
        address proxy;
        address impl;
        address fkProxy;
        address fkImpl;
    }

    bytes32 constant SALT_ID = "_1";
    bytes32 constant ONE_SALT = "ONE";
    bytes32 constant VAULT_SALT = "vONE";

    string constant KOPIO_NAME_PREFIX = "Kopio ";
    string constant ONE_PREFIX = "Kopio ";

    string constant SHARE_NAME_PREFIX = "Kopio Share: ";
    string constant SHARE_SYMBOL_PREFIX = "s";

    string constant VAULT_NAME_PREFIX = "Kopio Vault: ";
    string constant VAULT_SYMBOL_PREFIX = "kv";

    function kopioMeta(
        string memory name,
        string memory symbol
    ) internal pure returns (string memory, string memory) {
        return (KOPIO_NAME_PREFIX.cc(name), symbol);
    }

    function fKopioMeta(
        string memory name,
        string memory symbol
    ) internal pure returns (string memory, string memory) {
        return (SHARE_NAME_PREFIX.cc(name), SHARE_SYMBOL_PREFIX.cc(symbol));
    }

    function getSalts(
        string memory symbol
    ) internal pure returns (Salts memory) {
        return getSalts(symbol, SHARE_SYMBOL_PREFIX.cc(symbol));
    }

    function pathV3(
        address a,
        uint24 f,
        address b
    ) internal pure returns (bytes memory) {
        return bytes.concat(bytes20(a), bytes3(f), bytes20(b));
    }

    function concatv3(
        bytes memory p,
        uint24 f,
        address out
    ) internal pure returns (bytes memory) {
        return bytes.concat(p, bytes3(f), bytes20(out));
    }

    function kopioAddr(
        address factory,
        string memory symbol
    ) internal view returns (SaltResult memory addrs) {
        Salts memory salts = getSalts(symbol);

        bytes4 sig = 0xc6bdc35b;

        bytes memory _data;
        (, _data) = factory.staticcall(bytes.concat(sig, salts.kopio));
        (addrs.proxy, addrs.impl) = abi.decode(_data, (address, address));

        (, _data) = factory.staticcall(bytes.concat(sig, salts.share));
        (addrs.fkProxy, addrs.fkImpl) = abi.decode(_data, (address, address));
    }

    function getSalts(
        string memory ksymbol,
        string memory fsymbol
    ) internal pure returns (Salts memory res) {
        res.kopio = bytes32(
            bytes.concat(bytes(ksymbol), bytes(fsymbol), SALT_ID)
        );
        res.share = bytes32(
            bytes.concat(bytes(fsymbol), bytes(ksymbol), SALT_ID)
        );
    }
}
