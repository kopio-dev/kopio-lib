// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;
import {IERC165} from "./IERC165.sol";

struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}

struct FacetAddressAndPosition {
    address facetAddress;
    // position in facetFunctionSelectors.functionSelectors array
    uint96 functionSelectorPosition;
}

struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    // position of facetAddress in facetAddresses array
    uint256 facetAddressPosition;
}

/// @dev  Add=0, Replace=1, Remove=2
enum FacetCutAction {
    Add,
    Replace,
    Remove
}

struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
}

struct Initializer {
    address initContract;
    bytes initData;
}

interface IDiamondCutFacet {
    function diamondCut(FacetCut[] calldata, address, bytes calldata) external;
}

interface IDiamondLoupeFacet {
    function facets() external view returns (Facet[] memory);

    function facetFunctionSelectors(
        address
    ) external view returns (bytes4[] memory);

    function facetAddresses() external view returns (address[] memory);

    function facetAddress(bytes4) external view returns (address);
}

interface IExtendedDiamondCutFacet is IDiamondCutFacet {
    function executeInitializer(address, bytes calldata) external;
    function executeInitializers(Initializer[] calldata) external;
    function executeInitializer(Initializer calldata) external;
}

interface IDiamond is IExtendedDiamondCutFacet, IDiamondLoupeFacet, IERC165 {
    function setERC165(
        bytes4[] calldata add,
        bytes4[] calldata remove
    ) external;
}
