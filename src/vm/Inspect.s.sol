// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IData} from "../core/IData.sol";
import {Log} from "./VmLibs.s.sol";
import {IKopioProtocol, Asset, Oracle, RawPrice} from "../IKopioProtocol.sol";
import {IERC20} from "../token/IERC20.sol";
import {PythView} from "../vendor/Pyth.sol";
import {ArbDeploy} from "../info/ArbDeploy.sol";
import {Utils} from "../utils/Libs.sol";

// solhint-disable

abstract contract Inspector is ArbDeploy {
    using Log for *;
    using Utils for *;

    IData internal constant data = IData(dataAddr);
    IKopioProtocol internal constant protocol = IKopioProtocol(protocolAddr);
    address[] extTokens = [usdtAddr];
    function peekAccount(
        address account,
        PythView memory pythView
    ) public view {
        IData.A memory acc = data.getAccount(pythView, account, extTokens);
        Log.sr();
        account.clg("Account");
        Log.hr();
        acc.icdp.totals.cr.plg("ICDP CR");
        acc.icdp.totals.valColl.dlg("ICDP Collateral", 8);
        acc.icdp.totals.valDebt.dlg("ICDP Debt", 8);

        Log.hr();
        _logAccICDP(account, pythView);
        uint256 totalVal = _logAccSCDPDeposits(acc) + acc.icdp.totals.valColl;
        Log.sr();
        _logAccBals(account, pythView);
        Log.sr();
        _logCollections(account, pythView);
        Log.hr();
        totalVal.dlg("Total Protocol Value", 8);

        Log.sr();
    }

    function _logCollections(
        address account,
        PythView memory pythView
    ) internal view {
        IData.A memory acc = data.getAccount(pythView, account, extTokens);
        for (uint256 i; i < acc.collections.length; i++) {
            acc.collections[i].name.clg("Collection");
            for (uint256 j; j < acc.collections[i].items.length; j++) {
                uint256 bal = acc.collections[i].items[j].balance;
                if (bal == 0) continue;
                ("NFT ID: ").cc(j.str(), " Balance: ", bal.str()).clg();
            }
        }
    }

    function _logAccICDP(
        address account,
        PythView memory pythView
    ) internal view {
        IData.A memory acc = data.getAccount(pythView, account, extTokens);
        for (uint256 i; i < acc.icdp.deposits.length; i++) {
            acc.icdp.deposits[i].symbol.clg("Deposits");
            acc.icdp.deposits[i].amount.dlg(
                "Amount",
                acc.icdp.deposits[i].config.decimals
            );
            acc.icdp.deposits[i].val.dlg("Value", 8);
        }

        for (uint256 i; i < acc.icdp.debts.length; i++) {
            acc.icdp.debts[i].symbol.clg("Debt");
            acc.icdp.debts[i].amount.dlg("Amount");
            acc.icdp.debts[i].val.dlg("Value", 8);
        }
    }

    function _logAccSCDPDeposits(
        IData.A memory acc
    ) internal pure returns (uint256 totalVal) {
        for (uint256 i; i < acc.scdp.deposits.length; i++) {
            acc.scdp.deposits[i].symbol.clg("SCDP Deposits");
            acc.scdp.deposits[i].amount.dlg(
                "Amount",
                acc.scdp.deposits[i].config.decimals
            );
            acc.scdp.deposits[i].val.dlg("Value", 8);
            totalVal += acc.scdp.deposits[i].val;
            Log.hr();
        }
    }

    function _logAccBals(
        address account,
        PythView memory pythView
    ) internal view {
        IData.A memory acc = data.getAccount(pythView, account, extTokens);
        uint256 totalVal;
        for (uint256 i; i < acc.tokens.length; i++) {
            acc.tokens[i].symbol.clg("Wallet Balance");
            acc.tokens[i].amount.dlg("Amount", acc.tokens[i].decimals);
            acc.tokens[i].val.dlg("Value", acc.tokens[i].oracleDec);
            totalVal += acc.tokens[i].val;
            Log.hr();
        }

        totalVal.dlg("Total Wallet Value", 8);
        account.balance.dlg("ETH Balance");
    }

    function peekAsset(address asset) internal view {
        Asset memory config = protocol.getAsset(asset);
        IERC20 token = IERC20(asset);
        ("Protocol Asset").h1();
        token.symbol().clg("Symbol");
        asset.clg("Address");
        config.decimals.clg("Decimals");
        {
            uint256 tSupply = token.totalSupply();
            tSupply.dlg("Total Supply", config.decimals);
            protocol.getValue(asset, tSupply).dlg("Market Cap", 8);
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
            Oracle memory primaryOracle = protocol.getOracleOfTicker(
                config.ticker,
                config.oracles[0]
            );
            uint256 price1 = protocol.getPrice(asset);
            price1.dlg("Primary Price", 8);
            primaryOracle.staleTime.clg("Staletime (s)");
            primaryOracle.invertPyth.clg("Inverted Price: ");
            primaryOracle.pythId.blg();
            Log.hr();
            Oracle memory secondaryOracle = protocol.getOracleOfTicker(
                config.ticker,
                config.oracles[1]
            );
            RawPrice memory secondaryPrice = protocol.getPushPrice(asset);
            uint256 price2 = uint256(secondaryPrice.answer);
            price2.dlg("Secondary Price", 8);
            secondaryPrice.staleTime.clg("Staletime (s): ");
            secondaryOracle.feed.clg("Feed: ");
            (block.timestamp - secondaryPrice.timestamp).clg(
                "Seconds since update: "
            );
            Log.hr();
            uint256 deviation = protocol.getOracleDeviationPct();
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
        peekSCDPAsset(asset);
        config.dFactor.plg("dFactor");
        config.factor.plg("cFactor");
        Log.hr();
        config.depositLimitSCDP.dlg("SCDP Deposit Limit", config.decimals);
        protocol.getValue(asset, config.depositLimitSCDP).dlg("Value", 8);
        config.mintLimit.dlg("ICDP Mint Limit", config.decimals);
        protocol.getValue(asset, config.mintLimit).dlg("Value", 8);
        config.mintLimitSCDP.dlg("SCDP Mint Limit", config.decimals);
        protocol.getValue(asset, config.mintLimitSCDP).dlg("Value", 8);
        ("Config").h2();
        config.liqIncentiveSCDP.plg("SCDP Liquidation Incentive");
        config.liqIncentive.plg("ICDP Liquidation Incentive");
        config.openFee.plg("ICDP Open Fee");
        config.closeFee.plg("ICDP Close Fee");
        config.swapInFee.plg("SCDP Swap In Fee");
        config.swapOutFee.plg("SCDP Swap Out Fee");
        config.protocolFeeShareSCDP.plg("SCDP Protocol Fee");
    }

    function peekSCDPAsset(address asset) internal view {
        Asset memory config = protocol.getAsset(asset);
        Log.hr();
        uint256 totalColl = protocol.getTotalCollateralValueSCDP(false);
        uint256 totalDebt = protocol.getEffectiveSDIDebtUSD();

        uint256 debt = protocol.getDebtSCDP(asset);
        uint256 debtVal = protocol.getValue(asset, debt);

        debt.dlg("SCDP Debt", config.decimals);
        debtVal.dlg("Value", 8);
        debtVal.pdiv(totalDebt).plg("% of total debt");

        uint256 deposits = protocol.getDepositsSCDP(asset);
        uint256 depositVal = protocol.getValue(asset, deposits);

        deposits.dlg("SCDP Deposits", config.decimals);
        depositVal.dlg("Value", 8);
        depositVal.pdiv(totalColl).plg("% of total collateral");
        Log.hr();
    }
}
