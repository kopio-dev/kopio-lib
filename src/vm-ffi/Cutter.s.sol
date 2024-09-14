// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PLog} from "../vm/PLog.s.sol";
import {FacetCut, FacetCutAction, IDiamond, Initializer} from "../support/IDiamond.sol";
import {defaultFacetLoc, FacetData, getFacet, getFacets} from "./ffi-facets.s.sol";
import {Scripted} from "../vm/Scripted.s.sol";
import {ArbDeploy} from "../info/ArbDeploy.sol";
import {Factory, Json} from "../vm/Json.s.sol";

abstract contract Cutter is ArbDeploy, Json, Scripted {
    using PLog for *;

    enum CreateMode {
        Create1,
        Create2,
        Create3
    }

    function cutterBase(
        address dAddr,
        CreateMode cmode
    ) internal returns (CutterData storage) {
        setDiamond(dAddr);
        return setCreateMode(cmode);
    }

    function cutterBase(address dAddr) internal returns (CutterData storage) {
        return cutterBase(dAddr, CreateMode.Create1);
    }

    function setDiamond(
        address dAddr
    ) internal virtual returns (CutterData storage r) {
        (r = d()).diamond = IDiamond(dAddr);
    }

    function setInitializer(
        address to,
        bytes memory data
    ) internal virtual returns (CutterData storage r) {
        (r = d()).init = Initializer(to, data);
    }

    function setCreateMode(
        CreateMode cmode
    ) internal returns (CutterData storage r) {
        (r = d()).cmode = cmode;
    }

    function diamond() internal view virtual returns (IDiamond) {
        return d().diamond;
    }

    function cutter() internal pure returns (CutterData storage) {
        return d();
    }

    /**
     * @notice Executes the diamond cut.
     * @param exec - Whether to actually execute or just save tx data to JSON.
     * @return callData Transaction data of the diamond cut.
     */
    function diamondCut(
        bool exec
    ) internal ensureCuts returns (bytes memory callData) {
        jsonKey("diamondCut");
        json(address(d().diamond), "to");
        json(
            callData = abi.encodeWithSelector(
                d().diamond.diamondCut.selector,
                d().cuts,
                d().init.initContract,
                d().init.initData
            ),
            "data"
        );
        if (!exec) return callData;

        (bool success, bytes memory err) = address(d().diamond).call(callData);
        if (!success) _revert(err);
    }

    function diamondCut(
        address init,
        bytes memory data
    ) internal returns (bytes memory callData) {
        setInitializer(init, data);
        return diamondCut(true);
    }

    function previewDiamondCut(
        string memory glob
    ) internal returns (bytes memory) {
        return diamondCutFull(glob, d().cmode, false);
    }

    function previewDiamondCut() internal returns (bytes memory) {
        clgDiamondCuts();
        return compareCuts(d().diamond.facetAddresses());
    }

    function diamondCutFull() internal returns (bytes memory) {
        return diamondCutFull(defaultFacetLoc, d().cmode, true);
    }

    function diamondCutFull(
        string memory id,
        string memory glob
    ) internal returns (bytes memory) {
        return diamondCutFull(id, glob, d().cmode, true);
    }

    function diamondCutFull(
        string memory glob,
        CreateMode cmode,
        bool exec
    ) internal returns (bytes memory) {
        return diamondCutFull(vm.toString(getTime()), glob, cmode, exec);
    }

    function diamondCutFull(
        string memory id,
        string memory glob,
        CreateMode cmode,
        bool exec
    )
        internal
        withJSON(string.concat(id, "-diamond-cut"))
        returns (bytes memory)
    {
        resetCreateFacets(glob, cmode);
        return diamondCut(exec);
    }

    /**
     * @notice Deploys a new facet and executes the diamond cut.
     */
    function diamondCutSingle(
        string memory artifact,
        CreateMode cmode
    ) internal withJSON(artifact) returns (bytes memory) {
        clearCutterData();
        d().cmode = cmode;
        createFacetCut(artifact);
        return diamondCut(true);
    }

    /**
     * @notice Deploys a new facet and adds it to the diamond cut without executing the cut.
     */
    function createFacetCut(string memory artifact) internal {
        _createFacetCut(getFacet(artifact));
    }

    function createFacetCuts(string memory glob) private {
        FacetData[] memory facets = getFacets(glob);
        for (uint256 i; i < facets.length; i++) _createFacetCut(facets[i]);
    }

    function deployFacet(
        bytes memory ccode,
        bytes32 salt
    ) internal returns (address addr) {
        if (d().cmode == CreateMode.Create1) return _create1(ccode);
        if (d().cmode == CreateMode.Create2)
            return Factory.d2(ccode, "", salt).implementation;
        return
            Factory
                .d3(ccode, "", keccak256(abi.encodePacked(ccode)))
                .implementation;
    }

    function _createFacetCut(
        FacetData memory f
    ) private returns (address newFacet) {
        address oldFacet = d().diamond.facetAddress(f.selectors[0]);

        if (oldFacet == address(0)) {
            oldFacet = d().diamond.facetAddress(
                f.selectors[f.selectors.length - 1]
            );
        }

        bytes4[] memory rsels;

        if (oldFacet != address(0) && bytes(f.file).length > 0) {
            bytes32 newCodeHash = keccak256(
                vm.getDeployedCode(string.concat(f.file, ".sol:", f.file))
            );

            if (newCodeHash == oldFacet.codehash) {
                d().skipInfo.push(
                    string.concat(
                        fileStr(f.file, "Identical code exists @ "),
                        vm.toString(oldFacet)
                    )
                );

                jsonKey(string.concat(f.file, "-skip-exists"));
                json(oldFacet);
                jsonKey();
                return oldFacet;
            }

            rsels = pushRemoveFacet(oldFacet);

            if (rsels.length != 0) {
                d().fileInfo.push(
                    string.concat(
                        fileStr(f.file, "DELETE-FACET: "),
                        vm.toString(oldFacet)
                    )
                );
            } else {
                d().skipInfo.push(
                    string.concat(
                        fileStr(f.file, "All selectors are already removed ->"),
                        vm.toString(oldFacet)
                    )
                );
            }
        }

        pushAddFacet(
            newFacet = deployFacet(f.facet, bytes32(bytes(f.file))),
            f.selectors
        );

        d().facets.push(newFacet);
        d().fileInfo.push(string.concat(FILE, f.file, " (ADD-FACET)"));

        jsonKey(f.file);
        json(rsels.length, "selectorsBefore");
        json(newFacet);
        json(f.selectors.length, "selectorsAfter");
        jsonKey();
    }

    function pushRemoveFacet(
        address addr
    ) internal useTemp returns (bytes4[] memory) {
        bytes4[] memory sels = d().diamond.facetFunctionSelectors(addr);

        for (uint256 i; i < sels.length; i++) {
            bytes4 sel = sels[i];
            if (d().rsels[sel] == address(0)) {
                d().rsels[sel] = addr;
                d().rselsArr.push(sel);
                temp().sels.push(sel);
            }
        }

        if (temp().sels.length != 0) {
            d().cuts.push(
                FacetCut({
                    facetAddress: address(0),
                    action: FacetCutAction.Remove,
                    functionSelectors: temp().sels
                })
            );
            ++d().removes;
        }
        return temp().sels;
    }
    error CutterFunctionAlreadyAdded(bytes4 fn, address at);

    function pushAddFacet(address addr, bytes4[] memory sels) internal {
        for (uint256 i; i < sels.length; i++) {
            bytes4 sel = sels[i];

            if (d().asels[sel] != address(0)) {
                revert CutterFunctionAlreadyAdded({
                    fn: sel,
                    at: d().asels[sel]
                });
            }

            d().asels[sel] = addr;
            d().aselsArr.push(sel);
        }

        d().cuts.push(
            FacetCut({
                facetAddress: addr,
                action: FacetCutAction.Add,
                functionSelectors: sels
            })
        );

        ++d().adds;
    }

    function resetCreateFacets(string memory glob, CreateMode cmode) private {
        clearCutterData();
        setCreateMode(cmode);
        createFacetCuts(glob);
        clgDiamondCuts();
    }

    function d() private pure returns (CutterData storage data) {
        bytes32 DATA_SLOT = keccak256("cutter.data.slot");
        assembly {
            data.slot := DATA_SLOT
        }
    }

    function clearCutterData() internal {
        delete d().cuts;
        delete d().fileInfo;
        delete d().skipInfo;
        delete d().facets;

        for (uint256 i; i < d().rselsArr.length; i++) {
            delete d().rsels[d().rselsArr[i]];
        }
        delete d().rselsArr;

        for (uint256 i; i < d().aselsArr.length; i++) {
            delete d().aselsArr[i];
        }
        delete d().aselsArr;

        delete d().init;

        delete d().adds;
        delete d().removes;

        clearCutterTemp();
    }

    function clearCutterTemp() internal {
        delete temp().pairs;
        delete temp().sels;
    }

    error NoDiamondCuts(address);
    error NoDiamondSet();

    modifier ensureCuts() {
        if (d().cuts.length == 0) {
            revert NoDiamondCuts(address(d().diamond));
        }

        if (address(d().diamond) == address(0)) {
            revert NoDiamondSet();
        }
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                      .                                     */
    /* -------------------------------------------------------------------------- */

    function compareCuts(
        address[] memory facets
    ) internal returns (bytes memory data) {
        data = diamondCut(true);
        address[] memory facetsAfter = d().diamond.facetAddresses();
        string
            .concat(
                "[COMPARE-CUTS] Facet Count -> Before: ",
                vm.toString(facets.length),
                " | After: ",
                vm.toString(facetsAfter.length)
            )
            .clg();

        address[2][] memory pairs = findBySelector(facetsAfter, facets);

        for (uint256 i; i < pairs.length; i++) {
            string
                .concat(
                    "[COMPARE-CUTS] Facet Replaced ->",
                    vm.toString(pairs[i][0]),
                    " -> ",
                    vm.toString(pairs[i][1]),
                    "(",
                    string.concat("#", vm.toString(i)),
                    ")"
                )
                .clg();
        }

        string
            .concat(
                "[COMPARE-CUTS] Replaced Facets -> ",
                vm.toString(pairs.length)
            )
            .clg();
    }

    function findBySelector(
        address[] memory prev,
        address[] memory next
    ) internal useTemp returns (address[2][] memory) {
        (uint256 i, uint256 j, uint256 k, uint256 l) = (0, 0, 0, 0);

        while (i < next.length) {
            address nextFacet = next[i++];
            bytes4[] memory nextSels = d().diamond.facetFunctionSelectors(
                nextFacet
            );
            while (j < prev.length) {
                address prevFacet = prev[j++];
                bytes4[] memory prevSels = d().diamond.facetFunctionSelectors(
                    prevFacet
                );
                while (k < prevSels.length) {
                    bytes4 prevSel = prevSels[k++];
                    while (l < nextSels.length)
                        if (prevSel == nextSels[l++])
                            temp().pairs.push([prevFacet, nextFacet]);
                }
            }
        }

        return temp().pairs;
    }

    function clgDiamondCuts() internal view {
        for (uint256 i; i < d().cuts.length; i++)
            _toString(d().cuts[i], i).clg();

        clgSkippedDiamondCuts();
        "\n - - - - - -\n".clg();
        d().cuts.length.clg("[SUMMARY] Total Cuts ->");

        string memory removeStr = string.concat(
            "[SUMMARY] Total Removed ->",
            vm.toString(d().removes),
            " facets / ",
            vm.toString(d().rselsArr.length),
            " fns"
        );
        removeStr.clg();

        string memory addStr = string.concat(
            "[SUMMARY] Total Added ->",
            vm.toString(d().adds),
            " facets / ",
            vm.toString(d().aselsArr.length),
            " fns"
        );

        addStr.clg();
    }

    function _toString(
        FacetCut memory cut,
        uint256 idx
    ) internal view returns (string memory r) {
        r = "\n"
        "*****************************************************************"
        "\n"
        "[";

        string memory cutAction = "ADD";
        uint8 a = uint8(cut.action);
        if (a == 1) cutAction = "REPLACE";
        if (a == 2) cutAction = "REMOVE";

        r = string.concat(r, cutAction, "-FACET", END);
        r = string.concat(r, " (#", vm.toString(idx), ")\n");

        r = string.concat(r, d().fileInfo[idx], "\n");

        r = string.concat(r, "[ADDRESS] ", vm.toString(cut.facetAddress), "\n");
        r = string.concat(r, "[SELECTORS] ", _toString(cut.functionSelectors));
    }

    function _toString(
        bytes4[] memory sels
    ) private pure returns (string memory r) {
        uint256 len = sels.length;

        r = START;
        for (uint256 i; i < len; i++) {
            r = string.concat(
                r,
                vm.toString(abi.encodePacked(sels[i])),
                i == len - 1 ? END : ","
            );
        }
        return string.concat("(", vm.toString(len), ") -> ", r);
    }

    function clgSkippedDiamondCuts() internal view {
        if (d().skipInfo.length > 0) {
            PLog.clg("\n");
            PLog.clg(
                "*****************************************************************"
            );
            for (uint256 i; i < d().skipInfo.length; i++) {
                d().skipInfo[i].clg(
                    string.concat("[SKIP #", vm.toString(i), "]")
                );
            }
        } else {
            PLog.clg("\n");
            "[INFO] No skipped cuts".clg();
        }
    }

    modifier useTemp() virtual {
        _;
        clearCutterTemp();
    }

    function temp() private pure returns (CutterTemp storage data) {
        bytes32 TEMP_SLOT = keccak256("cutter.temp.slot");
        assembly {
            data.slot := TEMP_SLOT
        }
    }
}

struct CutterData {
    FacetCut[] cuts;
    string[] fileInfo;
    string[] skipInfo;
    address[] facets;
    mapping(bytes4 => address) rsels;
    bytes4[] rselsArr;
    mapping(bytes4 => address) asels;
    bytes4[] aselsArr;
    Cutter.CreateMode cmode;
    Initializer init;
    IDiamond diamond;
    uint256 adds;
    uint256 removes;
}

struct CutterTemp {
    FacetData[] facets;
    address[2][] pairs;
    bytes4[] sels;
}

string constant FILE = "[FILE] ";

function fileStr(
    string memory loc,
    string memory info
) pure returns (string memory) {
    return string.concat(FILE, loc, " -> ", info);
}

string constant START = "[";
string constant END = "]";
