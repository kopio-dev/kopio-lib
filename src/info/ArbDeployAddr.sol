// SPDX-License-Identifier: MIT
// solhint-disable no-inline-assembly, one-contract-per-file, state-visibility, const-name-snakecase
pragma solidity ^0.8.0;
import {IWETH9Arb} from "../token/IWETH9.sol";
import {IERC20} from "../token/IERC20.sol";
import {Meta} from "../utils/Libs.sol";

abstract contract ArbAddr {
    address constant arbAddr = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address constant usdcAddr = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant usdceAddr = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant wbtcAddr = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address constant wethAddr = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant daiAddr = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant usdtAddr = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant kissAddr = 0x6A1D6D2f4aF6915e6bBa8F2db46F442d18dB5C9b;

    address constant binanceAddr = 0xB38e8c17e38363aF6EbdCb3dAE12e0243582891D;
    address constant pythAddr = 0xff1a0f4744e8582DF1aE09D5611b887B6a12925C;
    address constant routerv3Addr = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address constant quoterV2Addr = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;

    IWETH9Arb constant weth = IWETH9Arb(wethAddr);
    IERC20 constant usdc = IERC20(usdcAddr);
    IERC20 constant usdce = IERC20(usdceAddr);
    IERC20 constant wbtc = IERC20(wbtcAddr);
    IERC20 constant arb = IERC20(arbAddr);
    IERC20 constant dai = IERC20(daiAddr);
    IERC20 constant usdt = IERC20(usdtAddr);
}

abstract contract ArbDeployAddr is ArbAddr {
    address constant protocolAddr = 0x0000000000177abD99485DCaea3eFaa91db3fe72;
    address constant multicallAddr = 0xC35A7648B434f0A161c12BD144866bdf93c4a4FC;
    address constant factoryAddr = 0x000000000070AB95211e32fdA3B706589D3482D5;
    address constant vaultAddr = 0x2dF01c1e472eaF880e3520C456b9078A5658b04c;
    address constant dataAddr = 0xef5196c4bDd74356943dcC20A7d27eAdD0F9b9D7;
    address constant marketStatusAddr =
        0xf6188e085ebEB716a730F8ecd342513e72C8AD04;

    address constant kETHAddr = 0x24dDC92AA342e92f26b4A676568D04d2E3Ea0abc;
    address constant kBTCAddr = 0x11EF4EcF3ff1c8dB291bc3259f3A4aAC6e4d2325;
    address constant kSOLAddr = 0x96084d2E3389B85f2Dc89E321Aaa3692Aed05eD2;
    address constant kEURAddr = 0x83BB68a7437b02ebBe1ab2A0E8B464CC5510Aafe;
    address constant kJPYAddr = 0xc4fEE1b0483eF73352447b1357adD351Bfddae77;
    address constant kGBPAddr = 0xdb274afDfA7f395ef73ab98C18cDf3D9C03b538C;
    address constant kXAUAddr = 0xe0A49C9215206f9cfb79981901bDF1f2716d3215;
    address constant kXAGAddr = 0x1d6A65BBfbbc995a19Fc19cB17FA135f9EdB6A24;
    address constant kDOGEAddr = 0x4a719F02aF3f0FFf15447B6824464857ADB5210D;

    address constant fkETHAddr = 0x3103570A28ca026e818c79608F1FF804F4Bde284;
    address constant fkBTCAddr = 0xc67a33599f73928D24D32fC0015e187157233410;
    address constant fkSOLAddr = 0x362cB60d235Cf8258042DAfB2a3Cdb14302D9D0f;
    address constant fkEURAddr = 0xBb6053898C5f6e536405fA324839141aA102b6D9;
    address constant fkJPYAddr = 0x3438Eb57e5b0f1CbEca257Aea9644B26b1B61EaC;
    address constant fkGBPAddr = 0x37BddA32281c15716D35f901b8141f7F382220C1;
    address constant fkXAUAddr = 0x3A1ffd3426916B16878AAa072B74DdaEC3e31007;
    address constant fkXAGAddr = 0x4d516E2049542B350368A44cBE71F3bbc00000D6;
    address constant fkDOGEAddr = 0x44217deFe47C3F5D03471d59723CF437efBfb871;

    address constant safe = 0x266489Bde85ff0dfe1ebF9f0a7e6Fed3a973cEc3;
    address constant nftMultisig = 0x389297F0d8C489954D65e04ff0690FC54E57Dad6;

    function getKopioAddr(
        string memory _symbol
    ) public view returns (Meta.SaltResult memory) {
        return Meta.kopioAddr(factoryAddr, _symbol);
    }
}
