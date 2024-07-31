// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBatchFacet {
    /**
     * @notice Performs batched calls to the protocol with a single price update.
     * @param calls Calls to perform.
     * @param prices Pyth price data to use for the calls.
     */
    function batchCall(
        bytes[] calldata calls,
        bytes[] calldata prices
    ) external payable;

    /**
     * @notice Performs "static calls" with the update prices through `batchCallToError`, using a try-catch.
     * Refunds the msg.value sent for price update fee.
     * @param calls Calls to perform.
     * @param prices Pyth price update preview with the static calls.
     * @return timestamp Timestamp of the data.
     * @return results Static call results as bytes[]
     */
    function batchStaticCall(
        bytes[] calldata calls,
        bytes[] calldata prices
    ) external payable returns (uint256 timestamp, bytes[] memory results);

    /**
     * @notice Performs supplied calls and reverts a `Errors.BatchResult` containing returned results as bytes[].
     * @param calls Calls to perform.
     * @param prices Pyth price update data to use for the static calls.
     * @return `Errors.BatchResult` which needs to be caught and decoded on-chain (according to the result signature).
     * Use `batchStaticCall` for a direct return.
     */
    function batchCallToError(
        bytes[] calldata calls,
        bytes[] calldata prices
    ) external payable returns (uint256, bytes[] memory);

    /**
     * @notice Used to transform bytes memory -> calldata by external call, then calldata slices the error selector away.
     * @param errData Error data to decode.
     * @return timestamp Timestamp of the data.
     * @return results Static call results as bytes[]
     */
    function decodeErrorData(
        bytes calldata errData
    ) external pure returns (uint256 timestamp, bytes[] memory results);
}
