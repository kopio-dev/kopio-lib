// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {logp, explorer, explorer20, vmFFI} from "./Base.s.sol";
import {Utils} from "../utils/Libs.sol";

// solhint-disable

library PLog {
    using Utils for *;

    function link(address p0, string memory _l) internal pure {
        clg(_l, explorer(p0));
    }

    function link20(address _tkn, string memory _l) internal pure {
        clg(_l, explorer20(_tkn));
    }

    function link(bytes32 _tx, string memory _l) internal pure {
        clg(_l, explorer(_tx));
    }
    function link(uint256 _bnr, string memory _l) internal pure {
        clg(_l, explorer(_bnr));
    }

    function clg(string memory p0) internal pure {
        logp(abi.encodeWithSignature("log(string)", p0));
    }

    function clg(address p0) internal pure {
        logp(abi.encodeWithSignature("log(address)", p0));
    }

    function clg(uint256 p0) internal pure {
        logp(abi.encodeWithSignature("log(uint256)", p0));
    }

    function clg(int256 p0) internal pure {
        logp(abi.encodeWithSignature("log(int256)", p0));
    }

    function blg(bytes32 p0) internal pure {
        logp(abi.encodeWithSignature("log(bytes32)", p0));
    }

    function blg(bytes memory p0) internal pure {
        logp(abi.encodeWithSignature("log(bytes)", p0));
    }

    function clg(string memory p0, string memory p1) internal pure {
        clg(string.concat(p0, " ", p1));
    }

    function clg(uint256 p1, string memory p0) internal pure {
        logp(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }

    function clg(int256 p1, string memory p0) internal pure {
        logp(abi.encodeWithSignature("log(string,int256)", p0, p1));
    }

    function clg(address p1, string memory p0) internal pure {
        clg(p0, vmFFI.toString(p1));
    }

    function dlg(int256 p1, string memory p0, uint256 dec) internal pure {
        dlg(uint256(p1), p0, dec);
    }

    function plg(uint256 p1, string memory p0) internal pure {
        clg(p0, string.concat(p1.dstr(2), "%"));
    }

    function clg(bool p0) internal pure {
        clg(p0, "");
    }

    function clg(bool p1, string memory p0) internal pure {
        clg(string.concat(p0, p1 ? "true" : "false"));
    }

    function dlg(uint256 p1, string memory p0) internal pure {
        dlg(p1, p0, 18);
    }

    function dlg(uint256 p1, string memory p0, uint256 d) internal pure {
        clg(p0, p1.dstr(d));
    }

    function clg(string memory p0, address p1, uint256 p2) internal pure {
        clg(p0, string.concat(vmFFI.toString(p1), " ", p2.str()));
    }

    function blg(bytes memory _p0, uint256 l) internal pure {
        bytes memory p0 = _p0;
        assembly {
            mstore(p0, l)
        }
        clg(vmFFI.toString(p0));
    }

    function blg(bytes32 p1, string memory p0) internal pure {
        clg(p0, vmFFI.toString(p1));
    }

    function blgstr(bytes32 p1, string memory p0) internal pure {
        clg(p0, p1.str());
    }

    function blg(bytes memory p1, string memory p0) internal pure {
        clg(p0, vmFFI.toString(p1));
    }

    function blgstr(bytes memory p1, string memory p0) internal pure {
        clg(p0, p1.str());
    }
}
