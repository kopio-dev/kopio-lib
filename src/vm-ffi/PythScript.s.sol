// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// solhint-disable

import {IPyth, Price, PriceFeed, PythEPs, PythView} from "../vendor/Pyth.sol";
import {execFFI, vmFFI, getFFIPath} from "../vm/Base.s.sol";

contract PythScript {
    string private _PYTH_FFI_SCRIPT;
    string[] private ffiArgs = ["bun", "run"];
    PythEPs internal pyth;

    constructor() {
        pyth.tickers = "BTC,ETH,USDC,ARB,SOL,GBP,EUR,JPY,XAU,XAG,DOGE";
        _PYTH_FFI_SCRIPT = getFFIPath("ffi-pyth.ts");
        ffiArgs.push(_PYTH_FFI_SCRIPT);

        pyth.avax = IPyth(0x4305FB66699C3B2702D4d05CF36551390A4c69C6);
        pyth.arbitrum = IPyth(0xff1a0f4744e8582DF1aE09D5611b887B6a12925C);
        pyth.bsc = IPyth(0x4D7E825f80bDf85e913E0DD2A2D54927e9dE1594);
        pyth.blast = IPyth(0xA2aa501b19aff244D90cc15a4Cf739D2725B5729);
        pyth.mainnet = IPyth(0x4305FB66699C3B2702D4d05CF36551390A4c69C6);
        pyth.optimism = IPyth(0xff1a0f4744e8582DF1aE09D5611b887B6a12925C);
        pyth.polygon = IPyth(0xff1a0f4744e8582DF1aE09D5611b887B6a12925C);
        pyth.polygonzkevm = IPyth(0xC5E56d6b40F3e3B5fbfa266bCd35C37426537c65);
        pyth.get[43114] = pyth.avax;
        pyth.get[42161] = pyth.arbitrum;
        pyth.get[56] = pyth.bsc;
        pyth.get[81457] = pyth.blast;
        pyth.get[1] = pyth.mainnet;
        pyth.get[10] = pyth.optimism;
        pyth.get[137] = pyth.polygon;
        pyth.get[1101] = pyth.polygonzkevm;
    }

    function updatePyth() internal {
        fetchPyth(pyth.tickers, true);
        pyth.get[block.chainid].updatePriceFeeds{value: pyth.cost}(pyth.update);
    }
    function updatePyth(bytes[] memory _payload, uint256 _cost) internal {
        pyth.get[block.chainid].updatePriceFeeds{value: _cost}(_payload);
    }

    function fetchPyth() internal {
        fetchPyth(pyth.tickers, true);
    }

    function fetchPyth(string memory _tickerOrIds, bool _getCost) internal {
        delete pyth.viewData;
        (bytes[] memory update, PriceFeed[] memory values) = getPythData(
            _tickerOrIds
        );
        pyth.update = update;
        pyth.cost = _getCost
            ? pyth.get[block.chainid].getUpdateFee(pyth.update)
            : values.length;
        for (uint256 i; i < values.length; i++) {
            pyth.viewData.ids.push(values[i].id);
            pyth.viewData.prices.push(values[i].price);
        }
    }

    function getPythData(
        string memory _tickers
    ) public returns (bytes[] memory payload, PriceFeed[] memory priceData) {
        ffiArgs.push(_tickers);
        return _exec();
    }

    function getPythData(
        bytes32[] memory _ids
    ) public returns (bytes[] memory payload, PriceFeed[] memory priceData) {
        string memory arg;
        for (uint256 i; i < _ids.length; i++) {
            arg = string.concat(
                arg,
                i == 0 ? "" : ",",
                vmFFI.toString(_ids[i])
            );
        }
        ffiArgs.push(arg);
        return _exec();
    }

    /**
     * @notice Get the price for a given Pyth ID
     * @param _id Pyth ID to get the price for
     * @return price Price data returned from the hermes endpoint
     */
    function getPrice(bytes32 _id) public returns (Price memory) {
        bytes32[] memory ids = new bytes32[](1);
        ids[0] = _id;
        (, PriceFeed[] memory priceData) = getPythData(ids);
        return priceData[0].price;
    }

    /**
     * @notice Get the price for a given ticker
     * @param _ticker Ticker to get the price for
     * @return price Price data returned from the hermes endpoint
     */
    function getTickerPrice(
        string memory _ticker
    ) public returns (Price memory) {
        (, PriceFeed[] memory priceData) = getPythData(_ticker);
        return priceData[0].price;
    }

    function _exec()
        private
        returns (bytes[] memory payload, PriceFeed[] memory data)
    {
        bytes memory res = execFFI(ffiArgs);
        ffiArgs = ["bun", "run", _PYTH_FFI_SCRIPT];

        return abi.decode(res, (bytes[], PriceFeed[]));
    }

    function getMockPayload(
        PythView memory _viewData
    ) internal returns (bytes[] memory _updateData) {
        _updateData = new bytes[](1);
        _updateData[0] = abi.encode(_viewData);
        pyth.update = _updateData;
        pyth.cost = _viewData.ids.length;
    }
}
