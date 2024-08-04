// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable

import {IExtendedDiamondCutFacet, IDiamondLoupeFacet, FacetCut, FacetCutAction, Initializer} from "../IKopioCore.sol";

interface IDiamond is IExtendedDiamondCutFacet, IDiamondLoupeFacet {}
