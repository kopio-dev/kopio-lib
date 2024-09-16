// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Tested} from "./Tested.t.sol";
import {ArbDeploy} from "../info/ArbDeploy.sol";
import {IERC20} from "../token/IERC20.sol";
import {BurnArgs, ICDPAccount, MintArgs, SwapArgs} from "../IKopioCore.sol";
import {Log, Utils, VmHelp} from "./VmLibs.s.sol";
import {Revert} from "../utils/Funcs.sol";
import {IKopio} from "../IKopio.sol";
import {Connected} from "./Connected.s.sol";

abstract contract TestedArb is Tested, Connected, ArbDeploy {
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

    function connect(uint256 blockNr) internal {
        connect("MNEMONIC_KOPIO", "arbitrum", blockNr);
        updatePythSync();
    }

    function connect() internal {
        connect("MNEMONIC_KOPIO", "arbitrum");
        updatePyth();
    }

    function toAmount(
        uint256 value,
        address token
    ) internal view returns (uint256) {
        return value.wdiv(core.getPrice(token)).fromWad(token);
    }

    function convert(
        uint256 amount,
        address from,
        address to
    ) internal view returns (uint256) {
        return toAmount(core.getValue(from, amount), to);
    }

    function dealAsset(
        uint256 value,
        address asset
    ) internal returns (uint256 amount) {
        dealAsset(asset, amount = toAmount(value, asset));
    }

    function dealAsset(address asset, uint256 amount) internal {
        dealAsset(msgSender(), asset, amount);
    }

    function dealAsset(address to, address asset, uint256 amount) internal {
        if (core.getAsset(asset).dFactor != 0) {
            dealKopio(asset, to, amount);
        } else {
            deal(asset, to, amount);
        }
    }

    function dealONE(
        uint256 value,
        address to
    ) internal returns (uint256 amount) {
        return dealONE(to, amount = toAmount(value, oneAddr));
    }

    function dealONE(address to, uint256 amount) internal returns (uint256) {
        return dealONE(usdceAddr, to, amount);
    }

    function dealONE(
        address stable,
        address to,
        uint256 amount
    ) internal repranked(bank) returns (uint256 out) {
        approve(bank, oneAddr, stable);

        (uint256 depositAmount, ) = vault.previewMint(stable, amount);
        deal(stable, bank, depositAmount);

        (out, ) = one.vaultDeposit(stable, depositAmount, bank);
        one.transfer(to, out);
    }

    function dealCollateral(
        uint256 value,
        address to
    ) internal returns (uint256 amount) {
        dealCollateral(to, usdceAddr, amount = toAmount(value, usdceAddr));
    }

    function dealCollateral(
        address token,
        address to,
        uint256 amount
    ) internal repranked(to) {
        approve(to, protocolAddr, token);

        if (token == oneAddr) dealONE(to, amount);
        else deal(token, to, amount);

        core.depositCollateral(to, token, amount);
    }

    function dealKopio(
        uint256 value,
        address kopio
    ) internal returns (uint256 amount) {
        dealKopio(
            kopio,
            msgSender(),
            amount = value.wdiv(core.getPrice(kopio))
        );
    }

    function dealKopio(
        address kopio,
        address to,
        uint256 amount
    ) internal repranked(bank) {
        dealCollateral(core.getValue(kopio, amount) * 2, bank);
        mintKopio(bank, kopio, amount, to);
    }

    function dealLiquidity(
        uint256 valVault,
        uint256 valSCDP,
        uint256 valkETH,
        uint256 valkBTC
    )
        internal
        repranked(bank)
        returns (
            uint256 amtVault,
            uint256 amtSCDP,
            uint256 amtkETH,
            uint256 amtkBTC
        )
    {
        uint256 onePrice = core.getPrice(oneAddr);

        if (valVault != 0) {
            dealONE(bank, amtVault = valVault.wdiv(onePrice));
        }

        if (valSCDP != 0) {
            dealKopio(oneAddr, bank, amtSCDP = valSCDP.wdiv(onePrice));
            approve(bank, protocolAddr, oneAddr);
            core.depositSCDP(bank, oneAddr, amtSCDP);
        }

        if (valkETH != 0) {
            amtkETH = dealkETH(bank, toAmount(valkETH, kETHAddr));
        }

        if (valkBTC != 0) {
            amtkBTC = dealkBTC(bank, toAmount(valkBTC, wbtcAddr));
        }
    }

    function dealYield(uint256 amount) internal repranked(bank) {
        dealONE(bank, amount);
        approve(bank, protocolAddr, oneAddr);
        core.addGlobalIncome(oneAddr, amount);
    }

    function dealFees(
        uint256 txValue
    )
        internal
        repranked(bank)
        returns (uint256 ETH_TO_USDCE, uint256 USDCE_TO_ETH)
    {
        approve(bank, protocolAddr, oneAddr);
        approve(bank, protocolAddr, kETHAddr);

        uint256 amountONE = toAmount(txValue / 2, oneAddr);
        uint256 amountETH = toAmount(txValue / 2, kETHAddr);

        uint256 kETHReceived = swap(
            bank,
            oneAddr,
            kETHAddr,
            dealONE(bank, amountONE)
        );

        (ETH_TO_USDCE, ) = one.vaultRedeem(
            usdceAddr,
            swap(bank, kETHAddr, oneAddr, dealkETH(bank, amountETH)),
            bank,
            bank
        );
        USDCE_TO_ETH = unwrapKopio(kETHAddr, bank, kETHReceived);
    }

    function dealkETH(
        address to,
        uint256 amount
    ) internal virtual repranked(bank) returns (uint256 received) {
        deal(bank, amount);
        return wrapKopio(address(0), to, amount);
    }

    function dealkBTC(
        address to,
        uint256 amount
    ) internal virtual repranked(bank) returns (uint256 received) {
        approve(bank, kBTCAddr, wbtcAddr);
        deal(wbtcAddr, bank, amount);
        return wrapKopio(kBTCAddr, to, amount);
    }

    function wrapKopio(
        address kopio,
        address to,
        uint256 amount
    ) internal returns (uint256 received) {
        bool native = kopio == address(0);
        kopio = native ? kETHAddr : kopio;

        received = i20(kopio).balanceOf(to);

        if (native) {
            (bool s, bytes memory d) = kopio.call{value: amount}("");
            if (!s) Revert(d);
        } else {
            IKopio(kopio).wrap(to, amount);
        }
        return i20(kopio).balanceOf(to) - received;
    }

    function unwrapKopio(
        address kopio,
        address to,
        uint256 amount
    ) internal returns (uint256 received) {
        bool native = kopio == address(0);
        kopio = native ? kETHAddr : kopio;

        uint256 maxIn = i20(kopio).balanceOf(msgSender());
        IERC20 ulying = i20(IKopio(kopio).wraps().underlying);
        uint256 maxOut = native ? kETHAddr.balance : ulying.balanceOf(kopio);

        if (amount > maxOut) amount = maxOut;
        if (amount > maxIn) amount = maxIn;

        received = native ? to.balance : ulying.balanceOf(to);
        IKopio(kopio).unwrap(to, amount, native);

        return (native ? to.balance : ulying.balanceOf(to)) - received;
    }

    function depositCollateral(
        uint256 value,
        address asset
    ) internal virtual returns (uint256 amount) {
        core.depositCollateral(
            msgSender(),
            asset,
            amount = toAmount(value, asset)
        );
    }

    function mintKopio(
        uint256 value,
        address asset
    ) internal virtual returns (uint256 amount) {
        address account = msgSender();
        mintKopio(account, asset, amount = toAmount(value, asset), account);
    }

    function mintKopio(
        address account,
        address asset,
        uint256 amount,
        address receiver
    ) internal virtual {
        core.mintKopio(
            MintArgs({
                account: account,
                kopio: asset,
                amount: amount,
                receiver: receiver
            }),
            noPyth
        );
    }

    function burnKopio(
        address account,
        address kopio,
        uint256 amount,
        address repayee
    ) internal virtual {
        core.burnKopio(
            BurnArgs({
                account: account,
                kopio: kopio,
                amount: amount,
                repayee: repayee
            }),
            noPyth
        );
    }

    function previewSwap(
        uint256 valueIn,
        address assetIn,
        address assetOut
    ) internal view returns (uint256 received) {
        return previewSwap(assetIn, assetOut, toAmount(valueIn, assetIn));
    }

    function previewSwap(
        address assetIn,
        address assetOut,
        uint256 amountIn
    ) internal view returns (uint256 received) {
        (received, , ) = core.previewSwapSCDP(assetIn, assetOut, amountIn);
    }

    function swap(
        uint256 valueIn,
        address assetIn,
        address assetOut
    ) internal virtual returns (uint256 received) {
        return swap(msgSender(), assetIn, assetOut, toAmount(valueIn, assetIn));
    }

    function swap(
        address receiver,
        address assetIn,
        address assetOut,
        uint256 amount
    ) internal virtual returns (uint256 received) {
        IERC20 aOut = i20(assetOut);
        received = aOut.balanceOf(receiver);

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

        return aOut.balanceOf(receiver) - received;
    }

    function approve(
        address owner,
        address spender,
        address token
    ) internal repranked(owner) {
        if (i20(token).allowance(owner, spender) == 0) {
            i20(token).approve(spender, type(uint256).max);
        }
    }

    function getApprovals(address to) internal pranked(to) {
        for (uint256 i; i < allKopios.length; ) _approve(allKopios[i++]);
        for (uint256 i; i < allNonKopios.length; ) _approve(allNonKopios[i++]);

        kETH.approve(kETHAddr, type(uint256).max);
        weth.approve(kETHAddr, type(uint256).max);
        kBTC.approve(kBTCAddr, type(uint256).max);
        wbtc.approve(kBTCAddr, type(uint256).max);
    }

    function _approve(address tkn) private {
        IERC20 token = i20(tkn);
        token.approve(multicallAddr, type(uint256).max);
        token.approve(protocolAddr, type(uint256).max);
        token.approve(oneAddr, type(uint256).max);
        token.approve(vaultAddr, type(uint256).max);
        token.approve(routerv3Addr, type(uint256).max);
    }

    function clgAmt(uint256 amount, address token) internal view {
        Log.clg(amountStr(token, amount));
    }

    function clgAmt(address user, address token) internal view {
        return clgAmt(i20(token).balanceOf(user), token);
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
                "[ICDP] Summary -> Collateral: ",
                summary.totalCollateralValue.vstr(),
                " Debt: ",
                summary.totalDebtValue.vstr(),
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
                "Amount: ",
                amount.dstr(token),
                IERC20(token).symbol(),
                " (",
                core.getValue(token, amount).vstr(),
                ")"
            );
    }
}
