// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IData} from "../support/IData.sol";
import {Log, VmHelp} from "../vm/VmLibs.s.sol";
import {Asset, ICDPAccount, Oracle, RawPrice, TData} from "../IKopioCore.sol";
import {IERC20} from "../token/IERC20.sol";
import {PythView} from "../vendor/Pyth.sol";
import {addr, iData, iCore} from "./ArbDeploy.sol";
import {Utils} from "../utils/Libs.sol";

// solhint-disable

library Peek {
    using Log for *;
    using Utils for *;
    using VmHelp for *;

    function maxMint(
        address account,
        address kopio
    ) internal view returns (uint256) {
        Log.sr();
        account.clg("ICDP Account: ");
        Log.hr();

        ICDPAccount memory state = iCore.getAccountState(account);
        uint256 collValue = state.totalCollateralValue.pdiv(iCore.getMCR());

        if (state.totalDebtValue >= collValue) return 0;

        Asset memory asset = iCore.getAsset(kopio);
        return
            iCore.getPrice(kopio).pmul(asset.dFactor).wdiv(
                collValue - state.totalDebtValue
            );
    }

    function accountState(
        address account,
        PythView memory pythView
    ) internal view {
        Log.sr();
        account.clg("Account");
        Log.hr();

        IData.A memory acc = iData.getAccount(pythView, account, _extAssets());
        string
            .concat(
                "ICDP Collateral: ",
                acc.icdp.totals.valColl.dstr(8),
                " ICDP Debt: ",
                acc.icdp.totals.valDebt.dstr(8),
                " ICDP CR: ",
                acc.icdp.totals.cr.dstr(2),
                "%"
            )
            .clg();

        accountICDP(account, pythView);
        uint256 totalVal = accountSCDP(acc) + acc.icdp.totals.valColl;

        accountBalances(account, pythView);
        collections(account, pythView);
        Log.hr();
        totalVal.dlg("Total Protocol Value", 8);
        Log.sr();
    }

    function collections(
        address account,
        PythView memory pythView
    ) internal view {
        Log.h1("Collections");
        IData.A memory acc = iData.getAccount(pythView, account, _extAssets());
        for (uint256 i; i < acc.collections.length; i++) {
            acc.collections[i].name.clg("Collection");
            for (uint256 j; j < acc.collections[i].items.length; j++) {
                uint256 bal = acc.collections[i].items[j].balance;
                if (bal == 0) continue;
                ("NFT ID: ").cc(j.str(), " Balance: ", bal.str()).clg();
            }
        }
    }

    function accountICDP(
        address account,
        PythView memory pythView
    ) internal view {
        IData.A memory acc = iData.getAccount(pythView, account, _extAssets());
        Log.h1(string.concat("ICDP Account: ", acc.addr.txt()));

        for (uint256 i; i < acc.icdp.deposits.length; i++) {
            TData.TPos memory pos = acc.icdp.deposits[i];
            str("ICDP Deposit:", pos.symbol, pos.amount, dec(pos.addr), pos.val)
                .clg();
            Log.hr();
        }

        for (uint256 i; i < acc.icdp.debts.length; i++) {
            TData.TPos memory debt = acc.icdp.debts[i];
            str("ICDP Debt:", debt.symbol, debt.amount, 18, debt.val).clg();
            Log.hr();
        }
    }

    function accountICDP(address account) internal view {
        Log.h1(string.concat("ICDP Account: ", account.txt()));

        ICDPAccount memory acc = iCore.getAccountState(account);
        string
            .concat(
                " Collateral: ",
                acc.totalCollateralValue.dstr(8),
                " Debt: ",
                acc.totalDebtValue.dstr(8),
                " CR: ",
                acc.collateralRatio.dstr(2),
                "%"
            )
            .clg();
    }

    function accountSCDP(
        IData.A memory acc
    ) internal view returns (uint256 totalVal) {
        Log.h1(string.concat("SCDP Deposits: ", acc.addr.txt()));
        for (uint256 i; i < acc.scdp.deposits.length; i++) {
            TData.SDepositUser memory d = acc.scdp.deposits[i];
            totalVal += d.val;

            Log.clg(
                str("SCDP Deposit:", d.symbol, d.amount, dec(d.addr), d.val)
            );
            Log.hr();
        }
    }
    function str(
        string memory pre,
        address _asset,
        uint256 amount,
        uint256 val
    ) internal view returns (string memory) {
        return str(pre, symbol(_asset), amount, dec(_asset), val);
    }
    function str(
        string memory pre,
        string memory _symbol,
        uint256 amount,
        uint256 _dec,
        uint256 val
    ) private pure returns (string memory) {
        return
            string.concat(
                pre,
                " ",
                _symbol,
                " ",
                amount.dstr(_dec),
                " / ",
                "$",
                val.dstr(8)
            );
    }

    function accountBalances(
        address account,
        PythView memory pythView
    ) internal view {
        Log.h1(string.concat("Balances: ", account.txt()));
        uint256 totalVal;

        IData.A memory acc = iData.getAccount(pythView, account, _extAssets());
        for (uint256 i; i < acc.tokens.length; i++) {
            IData.Tkn memory tkn = acc.tokens[i];
            totalVal += tkn.val;
            str("Token:", tkn.addr, tkn.amount, tkn.val).clg();
            Log.hr();
        }

        string memory summary = string.concat(
            "Total Wallet Value: $",
            totalVal.dstr(8),
            "  ETH Balance: ",
            account.balance.dstr()
        );
        summary.clg();
    }

    function protocolAsset(address asset) internal view {
        Asset memory config = iCore.getAsset(asset);
        IERC20 token = IERC20(asset);
        ("Protocol Asset").h1();
        token.symbol().clg("Symbol");
        asset.clg("Address");
        config.decimals.clg("Decimals");
        {
            uint256 tSupply = token.totalSupply();
            tSupply.dlg("Total Supply", config.decimals);
            iCore.getValue(asset, tSupply).dlg("Market Cap", 8);
        }
        if (config.share != address(0)) {
            address(config.share).clg("Share");
            IERC20(config.share).symbol().clg("Share Symbol");
            IERC20(config.share).totalSupply().dlg("Share Total Supply");
        } else {
            ("No Share").clg();
        }
        ("Oracle").h2();
        config.ticker.str().clg("Ticker");
        uint8(config.oracles[0]).clg("Primary Oracle: ");
        uint8(config.oracles[1]).clg("Secondary Oracle: ");
        Log.hr();
        {
            Oracle memory primaryOracle = iCore.getOracleOfTicker(
                config.ticker,
                config.oracles[0]
            );
            uint256 price1 = iCore.getPrice(asset);
            price1.dlg("Primary Price", 8);
            primaryOracle.staleTime.clg("Staletime (s)");
            primaryOracle.invertPyth.clg("Inverted Price: ");
            primaryOracle.pythId.blg();
            Log.hr();
            Oracle memory secondaryOracle = iCore.getOracleOfTicker(
                config.ticker,
                config.oracles[1]
            );
            RawPrice memory secondaryPrice = iCore.getPushPrice(asset);
            uint256 price2 = uint256(secondaryPrice.answer);
            price2.dlg("Secondary Price", 8);
            secondaryPrice.staleTime.clg("Staletime (s): ");
            secondaryOracle.feed.clg("Feed: ");
            (block.timestamp - secondaryPrice.timestamp).clg(
                "Seconds since update: "
            );
            Log.hr();
            uint256 deviation = iCore.getOracleDeviationPct();
            (price2.pmul(1e4 - deviation)).dlg("Min Dev", 8);
            (price2.pmul(1e4 + deviation)).dlg("Max Dev", 8);
            ((price1 * 1e8) / price2).dlg("Ratio", 8);
        }
        ("Types").h2();
        config.isKopio.clg("ICDP Mintable");
        config.isCollateral.clg("ICDP Collateral");
        config.isSwapMintable.clg("SCDP Swappable");
        config.isGlobalDepositable.clg("SCDP Depositable");
        config.isCoverAsset.clg("SCDP Cover");
        scdpAsset(asset);
        config.dFactor.plg("dFactor");
        config.factor.plg("cFactor");
        Log.hr();
        config.depositLimitSCDP.dlg("SCDP Deposit Limit", config.decimals);
        iCore.getValue(asset, config.depositLimitSCDP).dlg("Value", 8);
        config.mintLimit.dlg("ICDP Mint Limit", config.decimals);
        iCore.getValue(asset, config.mintLimit).dlg("Value", 8);
        config.mintLimitSCDP.dlg("SCDP Mint Limit", config.decimals);
        iCore.getValue(asset, config.mintLimitSCDP).dlg("Value", 8);
        ("Config").h2();
        config.liqIncentiveSCDP.plg("SCDP Liquidation Incentive");
        config.liqIncentive.plg("ICDP Liquidation Incentive");
        config.openFee.plg("ICDP Open Fee");
        config.closeFee.plg("ICDP Close Fee");
        config.swapInFee.plg("SCDP Swap In Fee");
        config.swapOutFee.plg("SCDP Swap Out Fee");
        config.protocolFeeShareSCDP.plg("SCDP Protocol Fee");
    }

    function scdpAsset(address asset) internal view {
        Asset memory config = iCore.getAsset(asset);
        Log.hr();
        uint256 totalColl = iCore.getTotalCollateralValueSCDP(false);
        uint256 totalDebt = iCore.getEffectiveSDIDebtUSD();

        uint256 debt = iCore.getDebtSCDP(asset);
        uint256 debtVal = iCore.getValue(asset, debt);

        str("SCDP Debt:", symbol(asset), debt, config.decimals, debtVal).clg();
        debtVal.pdiv(totalDebt).plg("% of total debt");

        uint256 deposits = iCore.getDepositsSCDP(asset);
        uint256 depositVal = iCore.getValue(asset, deposits);

        str(
            "SCDP Deposits:",
            symbol(asset),
            deposits,
            config.decimals,
            depositVal
        ).clg();
        depositVal.pdiv(totalColl).plg("% of total collateral");
        Log.hr();
    }

    function symbol(address token) internal view returns (string memory) {
        return IERC20(token).symbol();
    }
    function dec(address token) internal view returns (uint8) {
        return IERC20(token).decimals();
    }
    function _extAssets() private pure returns (address[] memory extTokens) {
        extTokens = new address[](1);
        extTokens[0] = addr.usdt;
    }
}
