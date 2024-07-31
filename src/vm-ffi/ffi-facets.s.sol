// SPDX-License-Identifier: BUSL-1.1
// solhint-disable

pragma solidity ^0.8.0;

import {execFFI, getFFIPath, vmFFI} from "../vm/Base.s.sol";
import {FacetCut, Initializer} from "../core/IDiamond.sol";

struct DiamondCtor {
    FacetCut[] cuts;
    Initializer init;
}

string constant defaultFacetLoc = "./**/facets/*Facet.sol";

struct FacetData {
    string file;
    bytes facet;
    bytes4[] selectors;
}

function getFacets() returns (FacetData[] memory) {
    return getFacets(defaultFacetLoc);
}

function getFacet(string memory _artifact) returns (FacetData memory) {
    FacetData[] memory results = getFacets(
        string.concat("./**/facets/", _artifact, ".sol")
    );
    require(results.length == 1, "Only one facet should be found");
    return results[0];
}

function getFacets(string memory _from) returns (FacetData[] memory res) {
    string[] memory cmd = new string[](2);
    cmd[0] = getFFIPath("ffi-facets.sh");
    cmd[1] = _from;

    (string[] memory files, bytes4[][] memory selectors) = abi.decode(
        execFFI(cmd),
        (string[], bytes4[][])
    );
    res = new FacetData[](files.length);

    for (uint256 i; i < files.length; i++) {
        res[i].file = files[i];
        res[i].selectors = selectors[i];

        (, bytes memory facetCode) = address(vmFFI).call(
            abi.encodeWithSignature(
                "getCode(string)",
                string.concat(res[i].file, ".sol:", res[i].file)
            )
        );
        res[i].facet = abi.decode(facetCode, (bytes));
    }

    require(
        res.length == selectors.length,
        "Facets and selectors length mismatch"
    );
}

function create1(bytes memory _bcode) returns (address loc_) {
    assembly {
        loc_ := create(0, add(_bcode, 0x20), mload(_bcode))
    }
}
