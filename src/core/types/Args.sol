// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice withdraws any amount and calls onFlashWithdraw.
 * @dev calls onFlashWithdraw on the sender.
 * @dev MCR check must pass after the callback.
 * @param account address to withdraw from.
 * @param asset address of collateral.
 * @param amount amount to withdraw.
 * @param depositIdx index in the deposits array.
 * @param data data forwarded to the callback
 */
struct FlashWithdrawArgs {
    address account;
    address asset;
    uint256 amount;
    uint256 depositIdx;
    bytes data;
}

/**
 * @notice External, used when caling liquidate.
 * @param account account to attempt to liquidate.
 * @param kopio kopio to repay.
 * @param amount amount to repay.
 * @param collateral collateral to seize.
 * @param mintIdx index in the minted kopios
 * @param depositIdx index in the deposited collaterals
 * @param prices price data for pyth.
 */
struct LiquidationArgs {
    address account;
    address kopio;
    uint256 amount;
    address collateral;
    uint256 mintIdx;
    uint256 depositIdx;
    bytes[] prices;
}

/**
 * @notice adjusts all deposits if global deposits wont cover the amount.
 * @param repayKopio kopio to repay
 * @param amount amount to repay.
 * @param collateral collateral to seize.
 * @param prices price data for pyth.
 */
struct SCDPLiquidationArgs {
    address repayKopio;
    uint256 amount;
    address collateral;
}

/**
 * @param kopio kopio repaid.
 * @param amount amount of kopio to repay
 * @param collateral collateral to seize.
 * @param prices price data for pyth.
 */
struct SCDPRepayArgs {
    address kopio;
    uint256 amount;
    address collateral;
    bytes[] prices;
}

/**
 * @param account account to withdraw from.
 * @param collateral collateral to withdraw.
 * @param amount amount to withdraw.
 * @param receiver receives the withdraw, address(0) fallbacks to account.
 */
struct SCDPWithdrawArgs {
    address account;
    address collateral;
    uint256 amount;
    address receiver;
}

/**
 * @param account receiver of amount out.
 * @param assetIn asset to sell.
 * @param assetOut asset to buy.
 * @param amountIn amount given.
 * @param minOut minimum amount to receive
 * @param prices price data for pyth.
 */
struct SwapArgs {
    address receiver;
    address assetIn;
    address assetOut;
    uint256 amountIn;
    uint256 amountOutMin;
    bytes[] prices;
}

/**
 * @param account address to mint from
 * @param kopio address of the kopio.
 * @param amount amount of kopio to mint.
 * @param receiver receives the kopios.
 */
struct MintArgs {
    address account;
    address kopio;
    uint256 amount;
    address receiver;
}

/**
 * @param account account to burn from
 * @param kopio kopio to burn.
 * @param amount amount to burn.
 * @param mintIdx index in the minted kopios
 * @param repayee address to burn from.
 */
struct BurnArgs {
    address account;
    address kopio;
    uint256 amount;
    uint256 mintIdx;
    address repayee;
}

/**
 * @param account address to withdraw assets for.
 * @param asset address of the collateral.
 * @param amount amount of the collateral to withdraw.
 * @param depositIdx index in the deposited collaterals
 * @param receiver receives the withdraw - address(0) fallbacks to account.
 */
struct WithdrawArgs {
    address account;
    address asset;
    uint256 amount;
    uint256 depositIdx;
    address receiver;
}
