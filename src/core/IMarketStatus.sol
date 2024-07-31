// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarketStatus {
    function allowed(address) external view returns (bool);

    function exchanges(bytes32) external view returns (bytes32);

    function status(bytes32 _exchange) external view returns (uint256);

    function setStatus(
        bytes32[] calldata _exchanges,
        bool[] calldata _statuses
    ) external;

    function setTickers(
        bytes32[] calldata _tickers,
        bytes32[] calldata _exchanges
    ) external;

    function setAllowed(address, bool) external;

    function getExchangeStatus(bytes32 _exchange) external view returns (bool);

    function getExchangeStatuses(
        bytes32[] calldata _exchanges
    ) external view returns (bool[] memory);

    function getExchange(bytes32) external view returns (bytes32);

    function getTickerStatus(
        bytes32 _ticker
    ) external view returns (bool status);

    function getTickerExchange(
        bytes32 _ticker
    ) external view returns (bytes32 exchange);

    function getTickerStatuses(
        bytes32[] calldata _tickers
    ) external view returns (bool[] memory statuses);

    function owner() external view returns (address);
}
