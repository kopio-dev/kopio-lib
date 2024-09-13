// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IKopioCLV3 {
    struct Derived {
        uint256 price;
        uint256 ratio;
        uint256 underlyingPrice;
        uint256 age;
        uint256 updatedAt;
    }

    struct Answer {
        uint256 answer;
        uint256 age;
        uint256 updatedAt;
    }

    error StalePrice(uint256, uint256);
    error InvalidAnswer(int256, uint256);
    error InvalidDecimals(uint8, uint8);

    function setDecimalConversions(bool) external;

    function ETH_FEED() external view returns (address);

    function STALE_TIME() external view returns (uint256);

    function PRICE_DEC() external view returns (uint8);

    function RATIO_DEC() external view returns (uint8);

    function getAnswer() external view returns (Answer memory);

    function getAnswer(address priceFeed) external view returns (Answer memory);

    function getAnswer(
        address priceFeed,
        uint8 pdec
    ) external view returns (Answer memory);

    function getRatio(address ratioFeed) external view returns (Answer memory);

    function getRatio(
        address ratioFeed,
        uint8 rdec
    ) external view returns (Answer memory);

    function getDerivedAnswer(
        address ratioFeed
    ) external view returns (Derived memory);

    function getDerivedAnswer(
        address priceFeed,
        address ratioFeed
    ) external view returns (Derived memory);

    function getDerivedAnswer(
        address priceFeed,
        address ratioFeed,
        uint8 pdec,
        uint8 rdec
    ) external view returns (Derived memory);

    function getDerivedAnswer(
        address[2] calldata priceFeeds,
        address[2] calldata ratioFeeds
    ) external view returns (Derived memory);
}
