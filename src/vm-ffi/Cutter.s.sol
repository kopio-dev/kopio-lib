// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PLog} from "../vm/PLog.s.sol";
import {FacetCut, FacetCutAction, IDiamond, Initializer} from "../support/IDiamond.sol";
import {defaultFacetLoc, FacetData, getFacet, getFacets} from "./ffi-facets.s.sol";
import {Scripted} from "../vm/Scripted.s.sol";
import {ArbDeploy} from "../info/ArbDeploy.sol";
import {Factory, Json} from "../vm/Json.s.sol";

contract Cutter is ArbDeploy, Json, Scripted {
    using PLog for *;
    CreateMode internal createMode;

    enum CreateMode {
        Create1,
        Create2,
        Create3
    }

    IDiamond internal _diamond;
    FacetCut[] internal _cuts;
    string[] internal _fileInfo;
    string[] internal _skipInfo;
    address[] internal _facets;
    Initializer internal _initializer;

    constructor() {
        createMode = CreateMode.Create1;
    }

    function cutterBase(address diamond, CreateMode cmode) internal {
        _diamond = IDiamond(diamond);
        createMode = cmode;
    }

    function previewCuts(string memory glob) internal returns (bytes memory) {
        return fullCut(glob, createMode, false);
    }

    /// @notice execute stored cuts, save to json with `_id`
    function executeCuts(bool exec) internal returns (bytes memory data) {
        jsonKey("diamondCut");
        json(address(_diamond), "to");
        json(
            data = abi.encodeWithSelector(
                _diamond.diamondCut.selector,
                _cuts,
                _initializer.initContract,
                _initializer.initData
            ),
            "calldata"
        );
        if (exec) {
            (bool success, bytes memory retdata) = address(_diamond).call(data);
            if (!success) {
                _revert(retdata);
            }
        }
    }

    function fullCut() internal {
        fullCut("full-cut-default", defaultFacetLoc);
    }

    function fullCut(
        string memory id,
        string memory glob
    ) internal withJSON(string.concat(id, "-full-cutter")) {
        clearAndCut(glob, createMode);
        executeCuts(true);
    }

    function fullCut(
        string memory glob,
        CreateMode cmode,
        bool exec
    ) internal returns (bytes memory) {
        clearAndCut(glob, cmode);
        clgCuts();
        return executeCuts(exec);
    }

    /**
     * @notice Deploys a new facet and executes the diamond cut.
     */
    function createFacetAndCut(
        string memory artifact,
        CreateMode cmode
    ) internal withJSON(artifact) {
        clearCuts();
        createMode = cmode;
        createFacet(artifact);
        executeCuts(true);
    }

    /**
     * @notice Deploys a new facet and adds it to the diamond cut without executing the cut.
     */
    function createFacet(string memory artifact) internal {
        _handleFacet(getFacet(artifact));
    }

    function createFacets(string memory glob) private {
        FacetData[] memory facets = getFacets(glob);
        for (uint256 i; i < facets.length; i++) _handleFacet(facets[i]);
    }

    function facetDeploy(
        bytes memory ccode,
        string memory salt
    ) internal returns (address addr) {
        if (createMode == CreateMode.Create1) {
            addr = _create1(ccode);
        } else if (createMode == CreateMode.Create2) {
            addr = Factory.d2(ccode, "", bytes32(bytes(salt))).implementation;
        } else {
            addr = Factory
                .d3(ccode, "", keccak256(abi.encodePacked(ccode)))
                .implementation;
        }
    }

    function _handleFacet(
        FacetData memory f
    ) private returns (address facetAddr) {
        address oldFacet = _diamond.facetAddress(f.selectors[0]);
        if (oldFacet == address(0)) {
            oldFacet = _diamond.facetAddress(
                f.selectors[f.selectors.length - 1]
            );
        }

        bytes4[] memory oldSelectors;
        if (oldFacet != address(0) && bytes(f.file).length > 0) {
            bytes32 newCodeHash = keccak256(
                vm.getDeployedCode(string.concat(f.file, ".sol:", f.file))
            );
            // skip if code is the same
            if (newCodeHash == oldFacet.codehash) {
                jsonKey(string.concat(f.file, "-skip"));
                json(oldFacet);
                json(true, "skipped");
                jsonKey();
                _skipInfo.push(
                    string.concat(
                        "Skip -> ",
                        f.file,
                        " exists @ ",
                        vm.toString(oldFacet)
                    )
                );
                return oldFacet;
            }

            oldSelectors = _diamond.facetFunctionSelectors(oldFacet);
            _cuts.push(
                FacetCut({
                    facetAddress: address(0),
                    action: FacetCutAction.Remove,
                    functionSelectors: oldSelectors
                })
            );
            _fileInfo.push(
                string.concat(
                    "Remove Facet -> ",
                    f.file,
                    " (",
                    vm.toString(oldFacet),
                    ")"
                )
            );
        }
        jsonKey(f.file);
        json(oldSelectors.length, "oldSelectors");
        facetAddr = facetDeploy(f.facet, f.file);
        json(facetAddr);

        _cuts.push(
            FacetCut({
                facetAddress: facetAddr,
                action: FacetCutAction.Add,
                functionSelectors: f.selectors
            })
        );
        _facets.push(facetAddr);
        _fileInfo.push(string.concat("New Facet -> ", f.file));
        json(f.selectors.length, "newSelectors");
        jsonKey();
    }

    function compareCuts(address[] memory facets) internal {
        if (_cuts.length == 0) {
            "No cuts to compare".clg();
            return;
        }
        executeCuts(true);
        address[] memory nextFacets = _diamond.facetAddresses();
        string
            .concat(
                "Facets -> Prev: ",
                vm.toString(facets.length),
                " | Next: ",
                vm.toString(nextFacets.length)
            )
            .clg();
        address[2][] memory pairs = findBySelector(nextFacets, facets);

        for (uint256 i; i < pairs.length; i++) {
            string
                .concat(
                    "Facet ",
                    string.concat("#", vm.toString(i)),
                    " replaced -> ",
                    vm.toString(pairs[i][0]),
                    " <-> ",
                    vm.toString(pairs[i][1])
                )
                .clg();
        }

        string.concat("Facets replaced: ", vm.toString(pairs.length)).clg();
    }

    function findBySelector(
        address[] memory prev,
        address[] memory next
    ) internal returns (address[2][] memory result) {
        (uint256 i, uint256 j, uint256 k, uint256 l) = (0, 0, 0, 0);

        while (i < next.length) {
            address nextFacet = next[i++];
            bytes4[] memory nextSels = _diamond.facetFunctionSelectors(
                nextFacet
            );
            while (j < prev.length) {
                address prevFacet = prev[j++];
                bytes4[] memory prevSels = _diamond.facetFunctionSelectors(
                    prevFacet
                );
                while (k < prevSels.length) {
                    bytes4 prevSel = prevSels[k++];
                    while (l < nextSels.length)
                        if (prevSel == nextSels[l++])
                            _findResult.push([prevFacet, nextFacet]);
                }
            }
        }

        return _findResult;
    }
    address[2][] private _findResult;
    function clgCuts() internal view {
        _cuts.length.clg("[Cutter] FacetCuts:");
        for (uint256 i; i < _cuts.length; i++) {
            PLog.clg("\n");
            PLog.clg(
                "*****************************************************************"
            );
            _fileInfo[i].clg(string.concat("[CUT #", vm.toString(i), "]"));
            _cuts[i].facetAddress.clg("Facet Address");
            uint8(_cuts[i].action).clg("Action");
            uint256 selectorLength = _cuts[i].functionSelectors.length;

            string memory selectorStr = "[";
            for (uint256 sel; sel < selectorLength; sel++) {
                selectorStr = string.concat(
                    selectorStr,
                    string(
                        vm.toString(
                            abi.encodePacked(_cuts[i].functionSelectors[sel])
                        )
                    ),
                    sel == selectorLength - 1 ? "" : ","
                );
            }
            string.concat(selectorStr, "]").clg(
                string.concat("Selectors (", vm.toString(selectorLength), ")")
            );
            selectorLength.clg("Selector Count");
        }

        if (_skipInfo.length > 0) {
            PLog.clg("\n");
            PLog.clg(
                "*****************************************************************"
            );
            for (uint256 i; i < _skipInfo.length; i++) {
                _skipInfo[i].clg(string.concat("[SKIP #", vm.toString(i), "]"));
            }
        }
    }

    function clearCuts() internal {
        delete _cuts;
        delete _fileInfo;
        delete _skipInfo;
        delete _initializer;
    }

    function clearAndCut(string memory glob, CreateMode cmode) private {
        clearCuts();
        createMode = cmode;
        createFacets(glob);
    }
}
