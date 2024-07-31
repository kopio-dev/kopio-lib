// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {IAggregatorV3} from "../vendor/IAggregatorV3.sol";
import {IAPI3} from "../vendor/IAPI3.sol";
import {Utils} from "./Libs.sol";
import {PythView, PriceFeed, IPyth, Price} from "../vendor/Pyth.sol";

using Utils for uint256;
using Utils for int256;

library CL {
    function price(address _feed) internal view returns (uint256) {
        (, int256 answer, , , ) = IAggregatorV3(_feed).latestRoundData();
        return uint256(answer);
    }

    function priceWad(address _feed) internal view returns (uint256) {
        (, int256 answer, , , ) = IAggregatorV3(_feed).latestRoundData();
        return answer.toWad(IAggregatorV3(_feed).decimals());
    }

    function stale(address _feed) internal view returns (bool) {
        (, , , uint256 updatedAt, ) = IAggregatorV3(_feed).latestRoundData();
        return block.timestamp - updatedAt > 1 days;
    }
}

library API3 {
    function price(address _proxy) internal view returns (uint256) {
        (int224 value, ) = IAPI3(_proxy).read();
        return uint256(int256(value));
    }

    function price8(address _proxy) internal view returns (uint256) {
        (int224 value, ) = IAPI3(_proxy).read();
        return uint256(int256(value)) / 1e10;
    }

    function stale(address _proxy) internal view returns (bool) {
        (, uint32 timestamp) = IAPI3(_proxy).read();
        return block.timestamp - timestamp > 1 days;
    }
}

library Pyth {
    function pythPrice(
        bytes32 _id,
        bool _invert,
        uint256 _staleTime
    ) internal view returns (uint256 price, uint8 expo) {
        return
            processPyth(
                getPythEP().getPriceNoOlderThan(_id, _staleTime),
                _invert
            );
    }
    function processPyth(
        Price memory _price,
        bool _invert
    ) internal pure returns (uint256 price, uint8 expo) {
        if (!_invert) {
            (price, expo) = normalizePythPrice(_price, 8);
        } else {
            (price, expo) = invertNormalizePrice(_price, 8);
        }

        if (price == 0 || price > type(uint56).max) {
            revert IPyth.PriceFeedNotFoundWithinRange();
        }
    }

    function normalizePythPrice(
        Price memory _price,
        uint8 toDec
    ) internal pure returns (uint256 price, uint8 expo) {
        price = uint64(_price.price);
        expo = uint8(uint32(-_price.expo));

        return (price.toDec(expo, toDec), toDec);
    }

    function invertNormalizePrice(
        Price memory _price,
        uint8 toDec
    ) internal pure returns (uint256 price, uint8 expo) {
        _price.price = int64(
            uint64(1 * (10 ** uint32(-_price.expo)).wdiv(uint64(_price.price)))
        );
        _price.expo = -18;
        return normalizePythPrice(_price, toDec);
    }
    function getView(
        PriceFeed[] memory feeds
    ) internal pure returns (PythView memory view_) {
        view_.ids = new bytes32[](feeds.length);
        view_.prices = new Price[](feeds.length);
        for (uint256 i; i < feeds.length; i++) {
            view_.ids[i] = feeds[i].id;
            view_.prices[i] = feeds[i].price;
        }
    }
    function getPythEP() internal view returns (IPyth ep) {
        uint256 id = block.chainid;
        if (id == 43114) ep = IPyth(0x4305FB66699C3B2702D4d05CF36551390A4c69C6);
        if (id == 42161) ep = IPyth(0xff1a0f4744e8582DF1aE09D5611b887B6a12925C);
        if (id == 56) ep = IPyth(0x4D7E825f80bDf85e913E0DD2A2D54927e9dE1594);
        if (id == 81457) ep = IPyth(0xA2aa501b19aff244D90cc15a4Cf739D2725B5729);
        if (id == 1) ep = IPyth(0x4305FB66699C3B2702D4d05CF36551390A4c69C6);
        if (id == 10) ep = IPyth(0xff1a0f4744e8582DF1aE09D5611b887B6a12925C);
        if (id == 137) ep = IPyth(0xff1a0f4744e8582DF1aE09D5611b887B6a12925C);
        if (id == 1101) ep = IPyth(0xC5E56d6b40F3e3B5fbfa266bCd35C37426537c65);
    }
}
