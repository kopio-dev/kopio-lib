// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {vmFFI} from "./Base.s.sol";
import {store, getId} from "./MinVm.s.sol";
import {PLog} from "./PLog.s.sol";

struct File {
    string loc;
}

using Files for File global;

library Files {
    function ensureLoc(string memory loc) internal {
        if (!vmFFI.exists(loc)) vmFFI.createDir(loc, true);
    }

    function toFile(string memory loc) internal pure returns (File memory) {
        return File(loc);
    }

    function write(
        string memory loc,
        bytes memory data
    ) internal returns (File memory saved) {
        vmFFI.writeFile(loc, vmFFI.trim(vmFFI.toString(data)));
        store().files.push(loc);
        return File(loc);
    }

    function write(
        File memory f,
        bytes memory data
    ) internal returns (File memory) {
        vmFFI.writeFile(f.loc, vmFFI.trim(vmFFI.toString(data)));
        return f;
    }

    function clear() internal {
        for (uint256 i; i < store().files.length; i++) {
            File(store().files[i]).rm();
        }
        delete store().files;
    }

    function write(bytes memory data) internal returns (File memory) {
        return write(vmFFI.toString(getId()), data);
    }

    function read(string memory loc) internal returns (bytes memory) {
        return vmFFI.parseBytes(vmFFI.trim(vmFFI.readFile(loc)));
    }

    function rm(string memory loc) internal returns (File memory) {
        if (bytes(loc).length == 0) revert("loc 0");
        if (vmFFI.exists(loc)) {
            vmFFI.removeFile(loc);
        }

        return File(loc);
    }

    function rm(File memory f) internal returns (File memory) {
        rm(f.loc);
        return f;
    }

    function append(
        File memory f,
        bytes memory data
    ) internal returns (File memory) {
        write(f.loc, bytes.concat(f.flush(), data));
        return f;
    }

    function read(File memory f) internal returns (bytes memory) {
        return read(f.loc);
    }

    function flush(File memory f) internal returns (bytes memory d) {
        return flush(f.loc);
    }

    function flush(string memory loc) internal returns (bytes memory d) {
        if (bytes(loc).length == 0) revert("no last id");
        d = read(loc);
        write(loc, "");
    }

    function clg(File memory _f) internal returns (File memory) {
        PLog.clg(
            string.concat(
                "location: ",
                _f.loc,
                " contents: ",
                vmFFI.toString(_f.read())
            )
        );
        return _f;
    }
    function clg() internal {
        for (uint256 i; i < store().files.length; i++) {
            clg(File(store().files[i]));
        }
    }
}
