// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Scripted} from "../Scripted.s.sol";
import {ArbDeploy} from "../../info/ArbDeploy.sol";
import {Connected} from "../Connected.s.sol";
import {IKopio} from "../../IKopio.sol";
import {Revert} from "../../utils/Funcs.sol";
import {IERC20} from "../../token/IERC20.sol";
import {BurnArgs, ICDPAccount, MintArgs, SwapArgs} from "../../IKopioCore.sol";
import {Log, VmHelp} from "../VmLibs.s.sol";
import {Utils} from "../../utils/Libs.sol";
import {Connection} from "../Connections.s.sol";

contract ArbScript is Connected, ArbDeploy {
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

    function connect(uint256 blockNr) internal virtual returns (Connection c) {
        c = connect("MNEMONIC_KOPIO", "arbitrum", blockNr);
        updatePythSync();
    }

    function connect() internal virtual returns (Connection c) {
        c = connect("MNEMONIC_KOPIO", "arbitrum");
        updatePyth();
    }

    function toAmount(
        uint256 value,
        address token
    ) internal view virtual returns (uint256) {
        return value.wdiv(core.getPrice(token)).fromWad(token);
    }

    function convert(
        uint256 amount,
        address from,
        address to
    ) internal view virtual returns (uint256) {
        return toAmount(core.getValue(from, amount), to);
    }

    function wrapKopio(
        address kopio,
        address to,
        uint256 amount
    ) internal virtual returns (uint256 received) {
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
    ) internal virtual returns (uint256 received) {
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
    ) internal virtual rebroadcasted(owner) {
        if (i20(token).allowance(owner, spender) == 0) {
            i20(token).approve(spender, type(uint256).max);
        }
    }

    function allApprovals(address owner) internal virtual rebroadcasted(owner) {
        for (uint256 i; i < allKopios.length; ) approvals(allKopios[i++]);
        for (uint256 i; i < allNonKopios.length; ) approvals(allNonKopios[i++]);

        kETH.approve(kETHAddr, type(uint256).max);
        weth.approve(kETHAddr, type(uint256).max);
        kBTC.approve(kBTCAddr, type(uint256).max);
        wbtc.approve(kBTCAddr, type(uint256).max);
    }

    function approvals(address tkn) internal virtual {
        IERC20 token = i20(tkn);
        token.approve(multicallAddr, type(uint256).max);
        token.approve(protocolAddr, type(uint256).max);
        token.approve(oneAddr, type(uint256).max);
        token.approve(vaultAddr, type(uint256).max);
        token.approve(routerv3Addr, type(uint256).max);
    }

    function clgAmt(uint256 amount, address token) internal view virtual {
        Log.clg(amountStr(token, amount));
    }

    function clgAmt(address user, address token) internal view virtual {
        return clgAmt(i20(token).balanceOf(user), token);
    }

    function clgCoreUser(address addr) internal view virtual {
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
