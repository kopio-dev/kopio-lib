// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Tested} from "./Tested.t.sol";
import {ArbDeploy} from "../info/ArbDeploy.sol";
import {IERC20} from "../token/IERC20.sol";
import {ICDPAccount, SwapArgs} from "../IKopioCore.sol";
import {Log, Utils, VmHelp} from "./VmLibs.s.sol";

abstract contract TestedArb is Tested, ArbDeploy {
    using Utils for *;
    using VmHelp for *;
    bytes[] noPyth;

    address[] allKopios = [
        kETHAddr,
        kBTCAddr,
        kSOLAddr,
        kDOGEAddr,
        kXAUAddr,
        kXAGAddr,
        kEURAddr,
        kGBPAddr,
        kJPYAddr,
        oneAddr
    ];
    address[] allNonKopios = [
        usdceAddr,
        usdcAddr,
        wbtcAddr,
        arbAddr,
        vaultAddr,
        usdtAddr,
        wethAddr,
        wstethAddr,
        weethAddr,
        ezethAddr
    ];

    constructor() {
        bank = makePayable("bank");
        user0 = makePayable("user0");
        user1 = makePayable("user1");
        user2 = makePayable("user2");
    }

    function dealONE(address to, uint256 amount) internal repranked(bank) {
        return dealONE(to, amount, usdceAddr);
    }

    function dealONE(
        address to,
        uint256 amount,
        address fromStable
    ) internal repranked(bank) {
        (uint256 depositAmount, ) = vault.previewMint(fromStable, amount);
        deal(bank, fromStable, depositAmount);
        one.vaultDeposit(fromStable, depositAmount, to);
    }

    function dealCollateral(address to, uint256 amount) internal repranked(to) {
        return dealCollateral(to, usdceAddr, amount);
    }

    function dealCollateral(
        address to,
        address token,
        uint256 amount
    ) internal repranked(to) {
        if (token == oneAddr) dealONE(to, amount);
        else deal(to, token, amount);
        approve(to, protocolAddr, token);
        core.depositCollateral(to, token, amount);
    }

    function dealLiquidity(
        address fromStable,
        uint256 amountVault,
        uint256 amountSCDP
    ) internal repranked(bank) {
        dealONE(bank, amountVault + amountSCDP, fromStable);
        approve(bank, protocolAddr, oneAddr);
        if (amountSCDP != 0) core.depositSCDP(bank, oneAddr, amountSCDP);
    }

    function dealYield(uint256 amount) internal repranked(bank) {
        dealONE(bank, amount);
        approve(bank, protocolAddr, oneAddr);
        core.addGlobalIncome(oneAddr, amount);
    }

    function swap(
        address receiver,
        address assetIn,
        address assetOut,
        uint256 amount
    ) internal {
        core.swapSCDP(
            SwapArgs({
                receiver: receiver,
                assetIn: assetIn,
                assetOut: assetOut,
                amountIn: amount,
                amountOutMin: 0,
                prices: noPyth
            })
        );
    }

    function approve(
        address owner,
        address spender,
        address token
    ) internal repranked(owner) {
        if (IERC20(token).allowance(owner, spender) == 0) {
            IERC20(token).approve(spender, type(uint256).max);
        }
    }

    function getApprovals(address to) internal pranked(to) {
        for (uint256 i; i < allKopios.length; i++) {
            _approveMax(allKopios[i]);
        }
        for (uint256 i; i < allNonKopios.length; i++) {
            _approveMax(allNonKopios[i]);
        }

        kETH.approve(kETHAddr, type(uint256).max);
        weth.approve(kETHAddr, type(uint256).max);
        kBTC.approve(kBTCAddr, type(uint256).max);
        wbtc.approve(kBTCAddr, type(uint256).max);
    }

    function _approveMax(address tkn) private {
        IERC20 token = IERC20(tkn);
        token.approve(multicallAddr, type(uint256).max);
        token.approve(protocolAddr, type(uint256).max);
        token.approve(oneAddr, type(uint256).max);
        token.approve(vaultAddr, type(uint256).max);
        token.approve(routerv3Addr, type(uint256).max);
    }

    function clgCoreUser(address addr) internal view {
        Log.h1(string.concat("User -> ", addr.txt()));

        address[] memory collaterals = core.getAccountCollateralAssets(addr);
        for (uint256 i; i < collaterals.length; i++) {
            Log.clg(
                string.concat(
                    "[ICDP] Deposit -> ",
                    amountStr(
                        collaterals[i],
                        core.getAccountCollateralAmount(addr, collaterals[i])
                    )
                )
            );
        }

        address[] memory debts = core.getAccountMintedAssets(addr);

        for (uint256 i; i < debts.length; i++) {
            Log.clg(
                string.concat(
                    "[ICDP] Debt -> ",
                    amountStr(
                        debts[i],
                        core.getAccountDebtAmount(addr, debts[i])
                    )
                )
            );
        }

        ICDPAccount memory summary = core.getAccountState(addr);

        Log.clg(
            string.concat(
                "[ICDP] Summary -> Collateral: $",
                summary.totalCollateralValue.dstr(8),
                " Debt: $",
                summary.totalDebtValue.dstr(8),
                " CR: ",
                summary.collateralRatio.dstr(2),
                "%"
            )
        );

        uint256 scdpDeposit = core.getAccountDepositSCDP(addr, oneAddr);

        Log.clg(
            string.concat("[SCDP] Deposit -> ", amountStr(oneAddr, scdpDeposit))
        );
    }

    function amountStr(
        address token,
        uint256 amount
    ) internal view returns (string memory) {
        return
            string.concat(
                amount.dstr(IERC20(token).decimals()),
                IERC20(token).symbol(),
                " ($",
                core.getValue(token, amount).dstr(8),
                ")"
            );
    }
}
