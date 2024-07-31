// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;

import {ArbDeployAddr} from "./ArbDeployAddr.sol";
import {ILZ1155} from "../token/ILZ1155.sol";
import {IONE} from "../core/IONE.sol";
import {IKopio, IFixedKopio} from "../core/IKopio.sol";
import {IKopioVault} from "../core/IKopioVault.sol";
import {IPyth} from "../vendor/Pyth.sol";
import {IMarketStatus} from "../core/IMarketStatus.sol";
import {IDeploymentFactory} from "../core/IDeploymentFactory.sol";
import {ISwapRouter} from "../vendor/ISwapRouter.sol";
import {IQuoterV2} from "../vendor/IQuoterV2.sol";

abstract contract ArbDeploy is ArbDeployAddr {
    IKopioVault constant vault = IKopioVault(vaultAddr);
    IONE constant one = IONE(kissAddr);
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

    IFixedKopio constant fkETH = IFixedKopio(fkETHAddr);
    IFixedKopio constant fkBTC = IFixedKopio(fkBTCAddr);
    IFixedKopio constant fkSOL = IFixedKopio(fkSOLAddr);
    IFixedKopio constant fkEUR = IFixedKopio(fkEURAddr);
    IFixedKopio constant fkJPY = IFixedKopio(fkJPYAddr);
    IFixedKopio constant fkGBP = IFixedKopio(fkGBPAddr);
    IFixedKopio constant fkXAU = IFixedKopio(fkXAUAddr);
    IFixedKopio constant fkXAG = IFixedKopio(fkXAGAddr);
    IFixedKopio constant fkDOGE = IFixedKopio(fkDOGEAddr);

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
