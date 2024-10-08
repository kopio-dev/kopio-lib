// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable no-global-import, use-forbidden-name
import "../vm/DeployerBase.s.sol";

abstract contract Cutter is DeployerBase {
    using Log for *;
    using Utils for *;

    function cutterBase(
        address dAddr,
        CreateMode cmode
    ) internal returns (CutterData storage) {
        setDiamond(dAddr);
        d().copyConfig = true;
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

    function setInitializer(
        address to,
        bytes4 fn
    ) internal virtual returns (CutterData storage) {
        return setInitializer(to, bytes.concat(fn));
    }

    function setCreateMode(
        CreateMode cmode
    ) internal returns (CutterData storage r) {
        (r = d()).cmode = cmode;
    }

    function setCopyConfig(bool copy) internal returns (CutterData storage r) {
        (r = d()).copyConfig = copy;
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
        json(VmHelp.getApproxDate().str, "createdAt");
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
        if (!success) Revert(err);

        delete d().init;
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
    ) internal returns (bytes memory callData) {
        callData = diamondCutFull(glob, d().cmode, false);
        clgDiamondCuts();
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
        return diamondCutFull(id, glob, true);
    }

    function diamondCutFull(
        string memory id,
        string memory glob,
        bool exec
    ) internal returns (bytes memory) {
        return diamondCutFull(id, glob, d().cmode, exec);
    }

    function diamondCutFull(
        string memory glob,
        CreateMode cmode,
        bool exec
    ) internal returns (bytes memory) {
        return diamondCutFull("full-cut", glob, cmode, exec);
    }

    function diamondCutFull(
        string memory id,
        string memory glob,
        CreateMode cmode,
        bool exec
    ) internal withJSONDir(_cutsDir, id) returns (bytes memory callData) {
        resetCreateFacets(glob, cmode);
        callData = diamondCut(exec);
        _copyConfig(id);
    }

    /**
     * @notice Deploys a new facet and executes the diamond cut.
     */
    function diamondCutSingle(
        string memory artifact,
        CreateMode cmode
    ) internal withJSONDir(_cutsDir, artifact) returns (bytes memory callData) {
        clearCutterData();
        d().cmode = cmode;
        createFacetCut(artifact);
        callData = diamondCut(true);
        _copyConfig(artifact);
    }

    /**
     * @notice Deploys a new facet and adds it to the diamond cut without executing the cut.
     */
    function createFacetCut(string memory artifact) internal {
        _createFacetCut(getFacet(artifact));
    }

    function createFacetCuts(string memory glob) internal {
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
                mvm.getDeployedCode(string.concat(f.file, ".sol:", f.file))
            );

            if (newCodeHash == oldFacet.codehash) {
                d().skipInfo.push(
                    string.concat(
                        fileStr(f.file, "Skipped as identical code exists @ "),
                        mvm.toString(oldFacet)
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
                        fileStr(f.file, "previously @ "),
                        mvm.toString(oldFacet)
                    )
                );
            } else {
                d().skipInfo.push(
                    string.concat(
                        fileStr(
                            f.file,
                            "All selectors already removed (prev @ "
                        ),
                        mvm.toString(oldFacet),
                        ")"
                    )
                );
            }
        }

        pushAddFacet(
            newFacet = deployFacet(f.facet, bytes32(bytes(f.file))),
            f.selectors
        );

        d().facets.push(newFacet);
        d().fileInfo.push(
            fileStr(f.file, string.concat("created @ ", mvm.toString(newFacet)))
        );

        jsonKey(f.file);
        json(newFacet, "1_addr");
        json(f.selectors.length, "2_selectors");
        json(oldFacet, "3_prev_addr");
        json(rsels.length, "3_prev_selectors");
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
        delete d().copyConfig;

        for (uint256 i; i < d().rselsArr.length; i++) {
            delete d().rsels[d().rselsArr[i]];
        }
        delete d().rselsArr;

        for (uint256 i; i < d().aselsArr.length; i++) {
            delete d().aselsArr[i];
        }
        delete d().aselsArr;

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

    function _copyConfig(string memory id) internal {
        try
            mvm.copyFile(
                "foundry.toml",
                string.concat("temp/", id, ".foundry.toml")
            )
        {
            Log.clg("[COPY-CONFIG] Success!");
        } catch {
            Log.clg("[COPY-CONFIG] Failed.");
        }
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
                mvm.toString(facets.length),
                " | After: ",
                mvm.toString(facetsAfter.length)
            )
            .clg();

        address[2][] memory pairs = findBySelector(facetsAfter, facets);

        for (uint256 i; i < pairs.length; i++) {
            string
                .concat(
                    "[COMPARE-CUTS] Facet Replaced ->",
                    mvm.toString(pairs[i][0]),
                    " -> ",
                    mvm.toString(pairs[i][1]),
                    "(",
                    string.concat("#", mvm.toString(i)),
                    ")"
                )
                .clg();
        }

        string
            .concat(
                "[COMPARE-CUTS] Replaced Facets -> ",
                mvm.toString(pairs.length)
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
        Log.clg("\n- - - - - - CUTS - - - - - -");

        for (uint256 i; i < d().cuts.length; i++)
            _toString(d().cuts[i], i).clg();

        clgSkippedDiamondCuts();

        Log.clg(
            string.concat(
                "\n- - - - - - SUMMARY - - - - - -",
                "\n[SUMMARY] Facet Cuts       -> ",
                mvm.toString(d().cuts.length),
                "\n[SUMMARY] Deployed Facets  -> ",
                mvm.toString(d().facets.length),
                "\n\n[SUMMARY] Removed Facets   -> ",
                string.concat(
                    mvm.toString(d().removes),
                    " - Fns: ",
                    mvm.toString(d().rselsArr.length)
                ),
                "\n[SUMMARY] Added Facets     -> ",
                string.concat(
                    mvm.toString(d().adds),
                    " - Fns: ",
                    mvm.toString(d().aselsArr.length)
                )
            )
        );
    }

    function _toString(
        FacetCut memory cut,
        uint256 idx
    ) internal view returns (string memory r) {
        r = "\n"
        "*****************************************************************"
        "\n";

        string memory cutAction = "ADD";
        uint8 a = uint8(cut.action);
        if (a == 1) cutAction = "REPLACE";
        if (a == 2) cutAction = "REMOVE";
        cutAction = string.concat(START, cutAction, "-FACET", END);

        r = string.concat(r, cutAction, " ", d().fileInfo[idx]);
        r = string.concat(r, " (#", mvm.toString(idx), ")", "\n");

        r = string.concat(
            r,
            "[ADDRESS] ",
            mvm.toString(cut.facetAddress),
            "\n"
        );
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
                mvm.toString(abi.encodePacked(sels[i])),
                i == len - 1 ? END : ","
            );
        }
        return string.concat("(", mvm.toString(len), ") -> ", r);
    }

    function clgSkippedDiamondCuts() internal view {
        Log.clg("\n- - - - - - SKIPS - - - - - -");

        if (d().skipInfo.length != 0) {
            for (uint256 i; i < d().skipInfo.length; i++) {
                Log.clg(
                    string.concat(
                        "\n",
                        d().skipInfo[i],
                        " (SKIP #",
                        mvm.toString(i),
                        ")"
                    )
                );
            }
        } else {
            Log.clg("\n");
            "\n[INFO] No skipped cuts".clg();
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
    bool copyConfig;
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
    return string.concat(loc, " -> ", info);
}

string constant START = "[";
string constant END = "]";
