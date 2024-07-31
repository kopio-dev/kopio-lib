// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {hasVM, mAddr, store, IMinVm, mvm} from "./MinVm.s.sol";
import {PLog} from "./PLog.s.sol";
import {Purify} from "../utils/Purify.sol";
import {Utils} from "../utils/Libs.sol";

library VmCaller {
    struct Values {
        address msgSender;
        address txOrigin;
        string mode;
    }

    function msgSender() internal returns (address s_) {
        (, s_, ) = mvm.readCallers();
    }

    function clear()
        internal
        returns (IMinVm.CallerMode m_, address s_, address o_)
    {
        (m_, s_, o_) = unbroadcast();

        if (
            m_ == IMinVm.CallerMode.Prank ||
            m_ == IMinVm.CallerMode.RecurrentPrank
        ) {
            mvm.stopPrank();
        }
    }

    function restore(IMinVm.CallerMode _m, address _ss, address _so) internal {
        if (_m == IMinVm.CallerMode.Broadcast) mvm.broadcast(_ss);
        if (_m == IMinVm.CallerMode.RecurrentBroadcast) mvm.startBroadcast(_ss);
        if (_m == IMinVm.CallerMode.Prank) {
            _ss == _so ? mvm.prank(_ss, _so) : mvm.prank(_ss);
        }
        if (_m == IMinVm.CallerMode.RecurrentPrank) {
            _ss == _so ? mvm.startPrank(_ss, _so) : mvm.startPrank(_ss);
        }
    }

    function unbroadcast()
        internal
        returns (IMinVm.CallerMode m_, address s_, address o_)
    {
        (m_, s_, o_) = mvm.readCallers();
        if (
            m_ == IMinVm.CallerMode.Broadcast ||
            m_ == IMinVm.CallerMode.RecurrentBroadcast
        ) {
            mvm.stopBroadcast();
        }
    }

    function unprank()
        internal
        returns (IMinVm.CallerMode m_, address s_, address o_)
    {
        (m_, s_, o_) = mvm.readCallers();
        if (
            m_ == IMinVm.CallerMode.Prank ||
            m_ == IMinVm.CallerMode.RecurrentPrank
        ) {
            mvm.stopPrank();
        }
    }

    function values() internal returns (Values memory) {
        (IMinVm.CallerMode m_, address s_, address o_) = mvm.readCallers();
        return Values(s_, o_, callModeStr(m_));
    }

    function callModeStr(
        IMinVm.CallerMode _mode
    ) internal pure returns (string memory) {
        if (_mode == IMinVm.CallerMode.Broadcast) return "broadcast";
        if (_mode == IMinVm.CallerMode.RecurrentBroadcast)
            return "persistent broadcast";
        if (_mode == IMinVm.CallerMode.Prank) return "prank";
        if (_mode == IMinVm.CallerMode.RecurrentPrank)
            return "persistent prank";
        if (_mode == IMinVm.CallerMode.None) return "none";
        return "unknown";
    }

    function mode() internal returns (string memory) {
        (IMinVm.CallerMode _m, , ) = mvm.readCallers();
        return callModeStr(_m);
    }
}

library VmHelp {
    function getAddr(
        string memory _mEnv,
        uint32 _idx
    ) internal returns (address) {
        return mAddr(_mEnv, _idx);
    }

    function getTime() internal returns (uint256) {
        return uint256(mvm.unixTime() / 1000);
    }

    function txt(address _val) internal pure returns (string memory) {
        return mvm.toString(_val);
    }

    function txt(uint256 _val) internal pure returns (string memory) {
        return mvm.toString(_val);
    }

    function txt(bytes32 _val) internal pure returns (string memory) {
        return mvm.toString(_val);
    }
    function txt(
        bytes32 _val,
        uint256 _l
    ) internal pure returns (string memory) {
        return txt(bytes.concat(_val), _l);
    }

    function txt(bytes memory _val) internal pure returns (string memory) {
        return mvm.toString(_val);
    }

    function txt(
        bytes memory _p0,
        uint256 _l
    ) internal pure returns (string memory) {
        bytes memory p0;
        assembly {
            p0 := _p0
            mstore(p0, _l)
        }
        return mvm.toString(p0);
    }

    function toAddr(string memory _val) internal pure returns (address) {
        return mvm.parseAddress(_val);
    }

    function toUint(string memory _val) internal pure returns (uint256) {
        return mvm.parseUint(_val);
    }

    function toB32(string memory _val) internal pure returns (bytes32) {
        return mvm.parseBytes32(_val);
    }

    function toBytes(string memory _val) internal pure returns (bytes memory) {
        return mvm.parseBytes(_val);
    }
}

library Log {
    using Utils for *;

    function id(string memory _pfix) internal {
        store().logPrefix = _pfix;
    }

    function __ispre() private view returns (bool) {
        return !store().logPrefix.zero();
    }
    function ispre() private pure returns (bool) {
        return Purify.BoolOut(__ispre)();
    }

    function __p(string memory _str) private view returns (string memory) {
        if (ispre()) {
            return string.concat("[", store().logPrefix, "] ", _str);
        } else {
            return _str;
        }
    }

    function _p(string memory _str) internal pure returns (string memory) {
        return Purify.StrInStrOut(__p)(_str);
    }

    function hr() internal pure {
        PLog.clg("--------------------------------------------------");
    }

    function br() internal pure {
        n();
    }

    function n() internal pure {
        PLog.clg("\n");
    }

    function sr() internal pure {
        PLog.clg("**************************************************");
    }

    function h1(string memory _h1) internal pure {
        sr();
        PLog.clg(_h1);
        hr();
    }

    function h2(string memory _h2) internal pure {
        PLog.clg("------", _h2.cc(" ------"));
    }

    function clg(bool _val) internal pure {
        clg("", _val);
    }

    function clg(string memory _str, bool _val) internal pure {
        PLog.clg(_p(_str), _val ? "true" : "false");
    }

    function clg(address _val) internal pure {
        !ispre() ? PLog.clg(_val) : PLog.clg(_val, _p(""));
    }

    function blg(bytes32 _val) internal pure {
        !ispre() ? PLog.blg(_val) : PLog.blg(_val, _p(""));
    }

    function clg(int256 _val) internal pure {
        !ispre() ? PLog.clg(_val) : PLog.clg(_val, _p(""));
    }

    function clg(uint256 _val) internal pure {
        !ispre() ? PLog.clg(_val) : PLog.clg(_val, _p(""));
    }

    function blg(bytes memory _val) internal pure {
        !ispre() ? PLog.blg(_val) : PLog.blg(_val, _p(""));
    }

    function plg(uint256 _val, string memory _str) internal pure {
        PLog.plg(_val, _p(_str));
    }

    function plg(string memory _str, uint256 _val) internal pure {
        plg(_val, _str);
    }

    function dlg(int256 _val, string memory _str) internal pure {
        dlg(_val, _str, 18);
    }

    function dlg(int256 _val, string memory _str, uint256 dec) internal pure {
        PLog.dlg(_val, _p(_str), dec);
    }

    function dlg(string memory _str, uint256 _val) internal pure {
        dlg(_val, _str, 18);
    }

    function dlg(string memory _str, int256 _val, uint256 dec) internal pure {
        dlg(_val, _str, dec);
    }

    function dlg(string memory _str, uint256 _val, uint256 dec) internal pure {
        PLog.dlg(_val, _p(_str), dec);
    }

    function dlg(uint256 _val, string memory _str) internal pure {
        dlg(_val, _str, 18);
    }

    function dlg(uint256 _val, string memory _str, uint256 dec) internal pure {
        PLog.dlg(_val, _p(_str), dec);
    }

    function clg(string memory _str, uint256 _val) internal pure {
        PLog.clg(_val, _p(_str));
    }

    function clg(uint256 _val, string memory _str) internal pure {
        PLog.clg(_val, _p(_str));
    }

    function clg(string memory _str, int256 _val) internal pure {
        PLog.clg(_val, _p(_str));
    }

    function clg(int256 _val, string memory _str) internal pure {
        PLog.clg(_val, _p(_str));
    }

    function clg(string memory _val) internal pure {
        PLog.clg(_p(_val));
    }

    function clg(string memory _s0, string memory _s1) internal pure {
        PLog.clg(_p(_s0), _s1);
    }

    function clg(string memory _lbl, address _val) internal pure {
        PLog.clg(_val, _p(_lbl));
    }

    function blg(string memory _lbl, bytes memory _val) internal pure {
        PLog.blg(_val, _p(_lbl));
    }

    function blg(string memory _lbl, bytes32 _val) internal pure {
        PLog.blg(_val, _p(_lbl));
    }

    function clg(address _val, string memory _str) internal pure {
        PLog.clg(_val, _p(_str));
    }

    function clg(bool _val, string memory _str) internal pure {
        clg(_str, _val);
    }

    function clg(address[] memory _val) internal pure {
        string memory _str = "[";
        for (uint256 i = 0; i < _val.length; i++) {
            _str = string.concat(_str, " ", mvm.toString(_val[i]));
        }
        clg(string.concat(_str, "] (", _val.length.str(), ")"));
    }

    function blg(bytes32 _val, uint256 len) internal pure {
        blg(bytes.concat(_val), len);
    }

    function blg(bytes memory _val, uint256 len) internal pure {
        PLog.blg(_val, len);
    }

    function blg(bytes32 _val, string memory _str) internal pure {
        PLog.blg(_val, _p(_str));
    }

    function blgstr(bytes32 _val, string memory _str) internal pure {
        PLog.blgstr(_val, _p(_str));
    }

    function blg(bytes memory _val, string memory _str) internal pure {
        PLog.blg(_val, _p(_str));
    }

    function blgstr(bytes memory _val, string memory _str) internal pure {
        PLog.blgstr(_val, _p(_str));
    }

    function link(address p0, string memory _str) internal pure {
        PLog.link(p0, _p(_str));
    }

    function link20(address _tkn, string memory _str) internal pure {
        PLog.link20(_tkn, _p(_str));
    }

    function link(bytes32 _tx, string memory _str) internal pure {
        PLog.link(_tx, _p(_str));
    }
    function link(uint256 _bnr, string memory _str) internal pure {
        PLog.link(_bnr, _p(_str));
    }

    function ctx(string memory _id) internal {
        VmCaller.Values memory _c = VmCaller.values();
        string memory _t = store().logPrefix;
        id(_id);
        hr();
        clg(
            "chain/blocknr/blocktime ->",
            block.chainid.str().cc("/", block.number.str(), "/").cc(
                block.timestamp.str()
            )
        );
        clg("address(this) ->", VmHelp.txt(address(this)));
        dlg(address(this).balance, "eth ->");
        clg(
            "msg.sender/tx.sender ->",
            VmHelp.txt(msg.sender).cc("/", VmHelp.txt(tx.origin))
        );
        clg(
            "eth ->",
            msg.sender.balance.dstr(18).cc("/", tx.origin.balance.dstr(18))
        );
        hr();
        clg(hasVM(), "HEVM ->");
        clg("tx-mode ->", _c.mode);
        clg(
            "msg.sender/tx.origin ->",
            VmHelp.txt(_c.msgSender).cc("/", VmHelp.txt(_c.txOrigin))
        );
        clg(
            "eth ->",
            _c.msgSender.balance.dstr(18).cc("/", _c.txOrigin.balance.dstr(18))
        );

        id(_t);
    }
}
