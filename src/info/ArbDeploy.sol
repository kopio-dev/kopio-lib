// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {addr, ArbDeployAddr} from "./ArbDeployAddr.sol";
import {ILZ1155} from "../token/ILZ1155.sol";
import {IProxyFactory} from "../IProxyFactory.sol";
import {ISwapRouter} from "../vendor/ISwapRouter.sol";
import {IQuoterV2} from "../vendor/IQuoterV2.sol";
import {IKopioCore, IMarketStatus} from "../IKopioCore.sol";
import {IKopio} from "../IKopio.sol";
import {IKopioShare} from "../IKopioShare.sol";
import {IPyth} from "../vendor/Pyth.sol";
import {IONE, IVault} from "../IONE.sol";
import {IKopioMulticall} from "../IKopioMulticall.sol";
import {Meta} from "../utils/Libs.sol";
import {IData} from "../support/IData.sol";

IPyth constant iPythUpdater = IPyth(addr.pythUpdater);
IKopioCore constant iCore = IKopioCore(addr.protocol);
IProxyFactory constant iFactory = IProxyFactory(payable(addr.factory));
IKopioMulticall constant iMulticall = IKopioMulticall(addr.multicall);
IData constant iData = IData(addr.data);
IVault constant iVault = IVault(addr.vault);
IONE constant iONE = IONE(addr.one);

abstract contract ArbDeploy is ArbDeployAddr {
    IONE constant one = iONE;
    IVault constant vault = iVault;
    IKopioCore constant core = iCore;
    IKopioMulticall constant koMulticall = iMulticall;
    IProxyFactory constant factory = iFactory;
    IData constant dataV3 = iData;

    IKopio constant kETH = IKopio(kETHAddr);
    IKopio constant kBTC = IKopio(kBTCAddr);
    IKopio constant kSOL = IKopio(kSOLAddr);
    IKopio constant kEUR = IKopio(kEURAddr);
    IKopio constant kJPY = IKopio(kJPYAddr);
    IKopio constant kGBP = IKopio(kGBPAddr);
    IKopio constant kXAU = IKopio(kXAUAddr);
    IKopio constant kXAG = IKopio(kXAGAddr);
    IKopio constant kDOGE = IKopio(kDOGEAddr);
    IKopio constant kBNB = IKopio(kBNBAddr);

    IKopioShare constant skETH = IKopioShare(skETHAddr);
    IKopioShare constant skBTC = IKopioShare(skBTCAddr);
    IKopioShare constant skSOL = IKopioShare(skSOLAddr);
    IKopioShare constant skEUR = IKopioShare(skEURAddr);
    IKopioShare constant skJPY = IKopioShare(skJPYAddr);
    IKopioShare constant skGBP = IKopioShare(skGBPAddr);
    IKopioShare constant skXAU = IKopioShare(skXAUAddr);
    IKopioShare constant skXAG = IKopioShare(skXAGAddr);
    IKopioShare constant skDOGE = IKopioShare(skDOGEAddr);
    IKopioShare constant skBNB = IKopioShare(skBNBAddr);

    IPyth constant pythEP = IPyth(pythAddr);
    IMarketStatus constant marketStatus = IMarketStatus(marketStatusAddr);
    ISwapRouter constant routerV3 = ISwapRouter(routerv3Addr);
    IQuoterV2 constant quoterV2 = IQuoterV2(quoterV2Addr);

    function _create1(bytes memory _code) internal returns (address loc_) {
        assembly {
            loc_ := create(0, add(_code, 0x20), mload(_code))
        }
    }
}

function getKopioAddr(
    string memory _symbol
) view returns (Meta.SaltResult memory) {
    return Meta.kopioAddr(addr.factory, _symbol);
}
