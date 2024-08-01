// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {ArbDeployAddr} from "./ArbDeployAddr.sol";
import {ILZ1155} from "../token/ILZ1155.sol";
import {IDeploymentFactory} from "../core/IDeploymentFactory.sol";
import {ISwapRouter} from "../vendor/ISwapRouter.sol";
import {IQuoterV2} from "../vendor/IQuoterV2.sol";
import {IMarketStatus, IKopio, IKopioShare} from "../IKopioProtocol.sol";
import {IPyth} from "../vendor/Pyth.sol";
import {IONE, IVault} from "../IONE.sol";

abstract contract ArbDeploy is ArbDeployAddr {
    IVault constant vault = IVault(vaultAddr);
    IONE constant one = IONE(oneAddr);
    IDeploymentFactory constant factory = IDeploymentFactory(factoryAddr);

    IKopio constant kETH = IKopio(kETHAddr);
    IKopio constant kBTC = IKopio(kBTCAddr);
    IKopio constant kSOL = IKopio(kSOLAddr);
    IKopio constant kEUR = IKopio(kEURAddr);
    IKopio constant kJPY = IKopio(kJPYAddr);
    IKopio constant kGBP = IKopio(kGBPAddr);
    IKopio constant kXAU = IKopio(kXAUAddr);
    IKopio constant kXAG = IKopio(kXAGAddr);
    IKopio constant kDOGE = IKopio(kDOGEAddr);

    IKopioShare constant fkETH = IKopioShare(fkETHAddr);
    IKopioShare constant fkBTC = IKopioShare(fkBTCAddr);
    IKopioShare constant fkSOL = IKopioShare(fkSOLAddr);
    IKopioShare constant fkEUR = IKopioShare(fkEURAddr);
    IKopioShare constant fkJPY = IKopioShare(fkJPYAddr);
    IKopioShare constant fkGBP = IKopioShare(fkGBPAddr);
    IKopioShare constant fkXAU = IKopioShare(fkXAUAddr);
    IKopioShare constant fkXAG = IKopioShare(fkXAGAddr);
    IKopioShare constant fkDOGE = IKopioShare(fkDOGEAddr);

    IPyth constant pythEP = IPyth(pythAddr);
    IMarketStatus constant marketStatus = IMarketStatus(marketStatusAddr);
    ISwapRouter constant routerV3 = ISwapRouter(routerv3Addr);
    IQuoterV2 constant quoterV2 = IQuoterV2(quoterV2Addr);

    CreateMode internal createMode;

    enum CreateMode {
        Create1,
        Create2,
        Create3
    }

    function _create1(bytes memory _code) internal returns (address loc_) {
        assembly {
            loc_ := create(0, add(_code, 0x20), mload(_code))
        }
    }
}
