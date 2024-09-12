// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
import {IAggregatorV3} from "../vendor/IAggregatorV3.sol";

contract MockOracle is IAggregatorV3 {
    uint8 public decimals = 8;
    string public override description;
    uint256 public override version = 1;
    int256 public initialAnswer;
    uint256 internal _updatedAt;

    constructor(
        string memory _description,
        uint256 _initialAnswer,
        uint8 _decimals
    ) {
        description = _description;
        initialAnswer = int256(_initialAnswer);
        decimals = _decimals;
    }

    function latestTimestamp() public view returns (uint256) {
        return _updatedAt == 0 ? block.timestamp : _updatedAt;
    }

    function setUpdatedAt(uint256 val) external {
        _updatedAt = val;
    }

    function setPrice(uint256 _answer) external {
        initialAnswer = int256(_answer);
    }

    function setDecimals(uint8 _decimals) external {
        decimals = _decimals;
    }

    function setPrice(int256 _answer) external {
        initialAnswer = int256(_answer);
    }

    function price() external view returns (uint256) {
        return uint256(initialAnswer);
    }

    function latestAnswer() external view returns (int256) {
        return initialAnswer;
    }

    function getRoundData(
        uint80
    )
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (1, initialAnswer, block.timestamp, latestTimestamp(), roundId);
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (1, initialAnswer, block.timestamp, latestTimestamp(), roundId);
    }
}
