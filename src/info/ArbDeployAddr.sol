// SPDX-License-Identifier: MIT
// solhint-disable no-inline-assembly, one-contract-per-file, state-visibility, const-name-snakecase, contract-name-camelcase
pragma solidity ^0.8.0;
import {IWETH9Arb} from "../token/IWETH9.sol";
import {IERC20} from "../token/IERC20.sol";

library addr {
    address constant arb = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address constant usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant usdce = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address constant weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant wsteth = 0x5979D7b546E38E414F7E9822514be443A4800529;
    address constant weeth = 0x35751007a407ca6FEFfE80b3cB397736D2cf4dbe;
    address constant ezeth = 0x2416092f143378750bb29b79eD961ab195CcEea5;
    address constant dai = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant usdt = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant one = 0x10000000001b2cc3aeEfDF01815B5D5FcBaf05Fc;
    address constant binance = 0xB38e8c17e38363aF6EbdCb3dAE12e0243582891D;
    address constant pyth = 0xff1a0f4744e8582DF1aE09D5611b887B6a12925C;
    address constant routerv3 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address constant quoterv2 = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;
    address constant protocol = 0x000000000000dcC1394A66cD4f84Fb38932a0fAB;
    address constant multicall = 0x000000000031188af86eb08b1C25a893B75a9a3B;
    address constant factory = 0x00000000000029398fcE86f09FF8453c8D0Cd60D;
    address constant vault = 0x000000000016777A0173d5d1717897d04485cC50;
    address constant prevData = 0xddDdDddDDd14aC7aB83F957b804e6b714b75179E;
    address constant data = 0xdddDDdddDDb338eB3c0283AD729692Cd39e8e336;
    address constant marketStatus = 0x77777777775c600736D65AD78623c0D563635e02;
    address constant pythUpdater = 0xfeEFeEfeED0bd9Df8d23dC0242FEF943c574468f;
    address constant migration = 0xaaaaaAaAaAa186774266Ea9b3FC0B588B3232795;
    address constant kclv3 = 0x333333333331Bb94E66b5aB3acfa0D30936C028A;
    address constant kETH = 0x6788C6aEd8CB32E166484796C533bF21abfe0354;
    address constant kBTC = 0x3074Bf9512F2d945f2C54A3A5893A1Fda895321A;
    address constant kSOL = 0xe0492d73E8E950616Da6C766E952204aB39455e9;
    address constant kEUR = 0x771C83402cE9Cd7E36e4AC7F2B0eED1Ad595814d;
    address constant kJPY = 0x690F31dca265Ba9Ae926228989AeeC6a822d5904;
    address constant kGBP = 0x41e18889f1e59227fcb4fbbc2A1dAe20eFA1e45F;
    address constant kXAU = 0xa47A706F0f07715760f96C4c2E322D25cDCb0A06;
    address constant kXAG = 0xA40c5780044fa125160770Cd29Bdbb631eA8ed0f;
    address constant kDOGE = 0x9DA7799E7896c542C13aD01Db5A9DC3A95Df193A;
    address constant skETH = 0x2aE27010F340062ceaAB3591B62351737f9E77B4;
    address constant skBTC = 0x8616281a8F9cA1860fbedf096581Db08B02A0297;
    address constant skSOL = 0x34b322DcA665754D5B1B07871aF8Ad2AD021d44D;
    address constant skEUR = 0x2F9727e769f9fB79D427Ca84dB35C366fA49600c;
    address constant skJPY = 0x03eeA39526534210e2471C54398E5Be8473C2c28;
    address constant skGBP = 0x6bA32Fd18d550f8E56ad93887A7f208A7eFB03C3;
    address constant skXAU = 0xd53FD8d8b0bF7116aeA20d8465c9A013002C5b6F;
    address constant skXAG = 0x77606e3670273A489234B11571EfAC4163aC93cD;
    address constant skDOGE = 0x100210d2d6058B9Aee92306aAe144944A756ff26;

    address constant safe = 0xd884451eC95721BcF05948C37a9F939059c87E6a;
}
abstract contract ArbAddr {
    address constant arbAddr = addr.arb;
    address constant usdcAddr = addr.usdc;
    address constant usdceAddr = addr.usdce;
    address constant wbtcAddr = addr.wbtc;
    address constant wethAddr = addr.weth;
    address constant wstethAddr = addr.wsteth;
    address constant weethAddr = addr.weeth;
    address constant ezethAddr = addr.ezeth;
    address constant daiAddr = addr.dai;
    address constant usdtAddr = addr.usdt;

    address constant oneAddr = addr.one;

    address constant binanceAddr = addr.binance;
    address constant pythAddr = addr.pyth;
    address constant routerv3Addr = addr.routerv3;
    address constant quoterV2Addr = addr.quoterv2;
    IWETH9Arb constant weth = IWETH9Arb(wethAddr);
    IERC20 constant usdc = IERC20(usdcAddr);
    IERC20 constant usdce = IERC20(usdceAddr);
    IERC20 constant wbtc = IERC20(wbtcAddr);
    IERC20 constant arb = IERC20(arbAddr);
    IERC20 constant dai = IERC20(daiAddr);
    IERC20 constant usdt = IERC20(usdtAddr);
    IERC20 constant wsteth = IERC20(wstethAddr);
    IERC20 constant weeth = IERC20(weethAddr);
    IERC20 constant ezeth = IERC20(ezethAddr);
}

abstract contract ArbDeployAddr is ArbAddr {
    address constant protocolAddr = addr.protocol;
    address constant multicallAddr = addr.multicall;
    address constant factoryAddr = addr.factory;
    address constant vaultAddr = addr.vault;
    address constant dataAddr = addr.data;
    address constant marketStatusAddr = addr.marketStatus;
    address constant pythUpdaterAddr = addr.pythUpdater;
    address constant migrationAddr = addr.migration;
    address constant kclv3Addr = addr.kclv3;
    address constant kETHAddr = addr.kETH;
    address constant kBTCAddr = addr.kBTC;
    address constant kSOLAddr = addr.kSOL;
    address constant kEURAddr = addr.kEUR;
    address constant kJPYAddr = addr.kJPY;
    address constant kGBPAddr = addr.kGBP;
    address constant kXAUAddr = addr.kXAU;
    address constant kXAGAddr = addr.kXAG;
    address constant kDOGEAddr = addr.kDOGE;

    address constant skETHAddr = addr.skETH;
    address constant skBTCAddr = addr.skBTC;
    address constant skSOLAddr = addr.skSOL;
    address constant skEURAddr = addr.skEUR;
    address constant skJPYAddr = addr.skJPY;
    address constant skGBPAddr = addr.skGBP;
    address constant skXAUAddr = addr.skXAU;
    address constant skXAGAddr = addr.skXAG;
    address constant skDOGEAddr = addr.skDOGE;

    address constant safe = addr.safe;
}
