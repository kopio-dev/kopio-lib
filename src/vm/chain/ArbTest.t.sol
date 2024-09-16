// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Tested} from "../Tested.t.sol";
import {Utils, VmHelp} from "../VmLibs.s.sol";
import {ArbScript} from "./ArbScript.s.sol";

abstract contract ArbTest is Tested, ArbScript {
    using Utils for *;
    using VmHelp for *;

    constructor() {
        bank = makePayable("bank");
        user0 = makePayable("user0");
        user1 = makePayable("user1");
        user2 = makePayable("user2");
    }

    function dealAsset(
        uint256 value,
        address asset
    ) internal virtual returns (uint256 amount) {
        dealAsset(asset, amount = toAmount(value, asset));
    }

    function dealAsset(address asset, uint256 amount) internal virtual {
        dealAsset(msgSender(), asset, amount);
    }

    function dealAsset(
        address to,
        address asset,
        uint256 amount
    ) internal virtual {
        if (core.getAsset(asset).dFactor != 0) {
            dealKopio(asset, to, amount);
        } else {
            deal(asset, to, amount);
        }
    }

    function dealONE(
        uint256 value,
        address to
    ) internal virtual returns (uint256 amount) {
        return dealONE(to, amount = toAmount(value, oneAddr));
    }

    function dealONE(
        address to,
        uint256 amount
    ) internal virtual returns (uint256) {
        return dealONE(usdceAddr, to, amount);
    }

    function dealONE(
        address stable,
        address to,
        uint256 amount
    ) internal virtual repranked(bank) returns (uint256 out) {
        approve(bank, oneAddr, stable);

        (uint256 depositAmount, ) = vault.previewMint(stable, amount);
        deal(stable, bank, depositAmount);

        (out, ) = one.vaultDeposit(stable, depositAmount, bank);
        one.transfer(to, out);
    }

    function dealCollateral(
        uint256 value,
        address to
    ) internal virtual returns (uint256 amount) {
        dealCollateral(usdceAddr, to, amount = toAmount(value, usdceAddr));
    }

    function dealCollateral(
        address token,
        address to,
        uint256 amount
    ) internal virtual repranked(to) {
        approve(to, protocolAddr, token);

        if (token == oneAddr) dealONE(to, amount);
        else deal(token, to, amount);

        core.depositCollateral(to, token, amount);
    }

    function dealKopio(
        uint256 value,
        address kopio
    ) internal virtual returns (uint256 amount) {
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
    ) internal virtual repranked(bank) {
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
        virtual
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

    function dealYield(uint256 amount) internal virtual repranked(bank) {
        dealONE(bank, amount);
        approve(bank, protocolAddr, oneAddr);
        core.addGlobalIncome(oneAddr, amount);
    }

    function dealFees(
        uint256 txValue
    )
        internal
        virtual
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
}
