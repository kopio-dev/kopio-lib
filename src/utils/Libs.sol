// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IDec {
    function decimals() external view returns (uint8);
}

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

    function toDec(
        uint256 v,
        uint8 f,
        address t
    ) internal view returns (uint256) {
        return toDec(uint256(v), f, dec(t));
    }

    function toDec(
        uint256 v,
        address f,
        uint8 t
    ) internal view returns (uint256) {
        return toDec(uint256(v), dec(f), t);
    }

    function toWad(int256 val, uint8 d) internal pure returns (uint256) {
        if (val < 0) revert("-");
        return toWad(uint256(val), d);
    }

    function toWad(uint256 val, address t) internal view returns (uint256) {
        return toWad(val, dec(t));
    }

    function dec(address _t) internal view returns (uint8) {
        return IDec(_t).decimals();
    }

    function toWad(uint256 val, uint8 d) internal pure returns (uint256) {
        return toDec(val, d, 18);
    }

    function fromWad(uint256 val, uint8 d) internal pure returns (uint256) {
        return toDec(val, 18, d);
    }

    function fromWad(uint256 val, address d) internal view returns (uint256) {
        return toDec(val, 18, dec(d));
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

    function str(bytes32 val) internal pure returns (string memory) {
        return str(bytes.concat(val));
    }

    function str(bytes memory val) internal pure returns (string memory res) {
        for (uint256 i; i < val.length; i++) {
            if (val[i] != 0)
                res = string.concat(res, string(bytes.concat(val[i])));
        }
    }

    function vstr(uint256 val) internal pure returns (string memory) {
        return string.concat("$", dstr(val, 8));
    }

    function dstr(uint256 val) internal pure returns (string memory) {
        return dstr(val, 18);
    }

    function dstr(
        uint256 val,
        address t
    ) internal view returns (string memory) {
        return dstr(val, dec(t));
    }

    function dstr(
        uint256 val,
        uint256 _dec
    ) internal pure returns (string memory) {
        uint256 ds = 10 ** _dec;

        bytes memory d = bytes(str(val % ds));
        (d = bytes.concat(bytes(str(10 ** (_dec - d.length))), d))[0] = 0;

        for (uint256 i = d.length; --i > 2; d[i] = 0) if (d[i] != "0") break;

        return string.concat(str(val / ds), ".", str(d));
    }

    function str(uint256 val) internal pure returns (string memory s) {
        unchecked {
            if (val == 0) return "0";
            else {
                uint256 c1 = itoa32(val % 1e32);
                val /= 1e32;
                if (val == 0) s = string(abi.encode(c1));
                else {
                    uint256 c2 = itoa32(val % 1e32);
                    val /= 1e32;
                    if (val == 0) {
                        s = string(abi.encode(c2, c1));
                        c1 = c2;
                    } else {
                        uint256 c3 = itoa32(val);
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
        uint256 val,
        uint256 pct
    ) internal pure returns (uint256 result) {
        assembly {
            if iszero(
                or(
                    iszero(pct),
                    iszero(gt(val, div(sub(not(0), HALF_PCT_F), pct)))
                )
            ) {
                revert(0, 0)
            }

            result := div(add(mul(val, pct), HALF_PCT_F), PCT_F)
        }
    }

    function pdiv(
        uint256 _val,
        uint256 pct
    ) internal pure returns (uint256 result) {
        assembly {
            if or(
                iszero(pct),
                iszero(iszero(gt(_val, div(sub(not(0), div(pct, 2)), PCT_F))))
            ) {
                revert(0, 0)
            }

            result := div(add(mul(_val, PCT_F), div(pct, 2)), pct)
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
        return slice(_b, _s, _b.length - _s);
    }

    function slice(
        bytes memory _b,
        uint256 _s,
        uint256 _l
    ) internal pure returns (bytes memory res) {
        if (_b.length < _s + _l) revert Overflow(_b.length, _s + _l);
        assembly {
            switch iszero(_l)
            case 0 {
                res := mload(0x40)
                let lengthmod := and(_l, 31)
                let mc := add(add(res, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _l)
                for {
                    let _c := add(
                        add(add(_b, lengthmod), mul(0x20, iszero(lengthmod))),
                        _s
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    _c := add(_c, 0x20)
                } {
                    mstore(mc, mload(_c))
                }

                mstore(res, _l)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                res := mload(0x40)
                mstore(res, 0)

                mstore(0x40, add(res, 0x20))
            }
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
        address val,
        uint256 len
    ) internal pure returns (address[] memory r) {
        (r = new address[](len))[0] = val;
    }

    function toArray(
        bytes memory val
    ) internal pure returns (bytes[] memory r) {
        (r = new bytes[](1))[0] = val;
    }

    function add(bytes32 a, uint256 b) internal pure returns (bytes32) {
        return bytes32(uint256(a) + b);
    }

    function sub(bytes32 a, uint256 b) internal pure returns (bytes32) {
        return bytes32(uint256(a) - b);
    }

    function padLeft(
        string memory val,
        uint256 len,
        string memory char
    ) internal pure returns (string memory result) {
        result = val;

        uint256 strLen = bytes(val).length;
        if (strLen >= len) return result;

        for (uint256 i = strLen; i < len; i++) {
            result = string.concat(char, result);
        }
    }

    function padRight(
        string memory val,
        uint256 len,
        string memory char
    ) internal pure returns (string memory result) {
        result = val;

        uint256 strLen = bytes(val).length;
        if (strLen >= len) return result;

        for (uint256 i = strLen; i < len; i++) {
            result = string.concat(result, char);
        }
    }
}

library Meta {
    using Utils for string;
    struct Result {
        string name;
        string symbol;
        string skName;
        string skSymbol;
        SaltResult addr;
        Salts salts;
    }

    struct Salts {
        bytes32 kopio;
        bytes32 share;
    }

    struct SaltResult {
        address proxy;
        address impl;
        address skProxy;
        address skImpl;
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

    function getKopioAsset(
        address factory,
        string memory name,
        string memory symbol
    ) internal view returns (Result memory res) {
        (res.name, res.symbol) = kopioMeta(name, symbol);
        (res.skName, res.skSymbol) = fKopioMeta(name, symbol);
        res.addr = kopioAddr(factory, res.symbol);
        res.salts = getSalts(res.symbol, res.skSymbol);
    }

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
        uint24 fee,
        address b
    ) internal pure returns (bytes memory) {
        return bytes.concat(bytes20(a), bytes3(fee), bytes20(b));
    }

    function concatv3(
        bytes memory p,
        uint24 fee,
        address out
    ) internal pure returns (bytes memory) {
        return bytes.concat(p, bytes3(fee), bytes20(out));
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
        (addrs.skProxy, addrs.skImpl) = abi.decode(_data, (address, address));
    }

    function getSalts(
        string memory symbol,
        string memory skSymbol
    ) internal pure returns (Salts memory res) {
        res.kopio = bytes32(
            bytes.concat(bytes(symbol), bytes(skSymbol), SALT_ID)
        );
        res.share = bytes32(
            bytes.concat(bytes(skSymbol), bytes(symbol), SALT_ID)
        );
    }
}
