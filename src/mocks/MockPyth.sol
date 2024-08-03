// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {IPyth, PythView, Price, PriceFeed} from "../vendor/Pyth.sol";
import {Utils} from "../utils/Libs.sol";

contract MockPyth is IPyth {
    using Utils for *;
    mapping(bytes32 => Price) internal prices;

    constructor(bytes[] memory _updateData) {
        updatePriceFeeds(_updateData);
    }

    function getPriceNoOlderThan(
        bytes32 id,
        uint256 maxAge
    ) external view override returns (Price memory) {
        if (prices[id].publishTime >= block.timestamp - maxAge) {
            return prices[id];
        }
        revert(
            string.concat(
                "Price too old: ",
                uint256(prices[id].publishTime).str(),
                "current: ",
                uint256(block.timestamp).str()
            )
        );
    }

    function getPriceUnsafe(
        bytes32 id
    ) external view override returns (Price memory) {
        return prices[id];
    }

    function getUpdateFee(
        bytes[] memory update
    ) external pure override returns (uint256) {
        if (update.length == 0) return 0;
        return abi.decode(update[0], (PythView)).ids.length;
    }

    function updatePriceFeeds(bytes[] memory update) public payable {
        if (update.length == 0) return;
        PythView memory data = abi.decode(update[0], (PythView));
        for (uint256 i; i < data.ids.length; i++) {
            _set(data.ids[i], data.prices[i]);
        }
    }

    function updatePriceFeedsIfNecessary(
        bytes[] memory update,
        bytes32[] memory ids,
        uint64[] memory publishTimes
    ) external payable override {
        if (update.length == 0) return;
        PythView memory data = abi.decode(update[0], (PythView));
        for (uint256 i; i < ids.length; i++) {
            if (prices[ids[i]].publishTime < publishTimes[i]) {
                _set(data.ids[i], data.prices[i]);
            }
        }
    }

    function queryPriceFeed(
        bytes32 id
    ) external view override returns (PriceFeed memory) {
        return PriceFeed(id, prices[id], prices[id]);
    }

    function getPrice(
        bytes32 id
    ) external view override returns (Price memory) {
        return prices[id];
    }

    function priceFeedExists(bytes32 id) external view override returns (bool) {
        return prices[id].publishTime != 0;
    }

    function parsePriceFeedUpdates(
        bytes[] calldata,
        bytes32[] calldata,
        uint64,
        uint64
    ) external payable override returns (PriceFeed[] memory) {
        revert("Not implemented");
    }

    function _set(bytes32 id, Price memory _price) internal {
        prices[id] = _price;
    }
}

function createMockPyth(PythView memory _viewData) returns (MockPyth) {
    bytes[] memory _updateData = new bytes[](1);
    _updateData[0] = abi.encode(_viewData);

    return new MockPyth(_updateData);
}
