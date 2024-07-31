// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IQuoterV2} from "../vendor/IQuoterV2.sol";
import {ISwapRouter} from "../vendor/ISwapRouter.sol";
import {IUniswapV3Factory} from "../vendor/IUniswapV3Factory.sol";
import {IUniswapV3NFTManager} from "../vendor/IUniswapV3NFTManager.sol";
import {IAggregatorV3} from "../vendor/IAggregatorV3.sol";
import {IERC20} from "../token/IERC20.sol";
import {IAPI3} from "../vendor/IAPI3.sol";
import {IWETH9} from "../token/IWETH9.sol";

library Arb {
    address constant ZERO = address(0);
    address constant OLD_SAFE = 0x266489Bde85ff0dfe1ebF9f0a7e6Fed3a973cEc3;
    address constant NEW_SAFE = 0xd884451eC95721BcF05948C37a9F939059c87E6a;

    address constant gDAI = 0xd85E038593d7A098614721EaE955EC2022B9B91B;
    address constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address constant ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;
    address constant FRAX = 0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant USDCe = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant LINK = 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4;
    address constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
    address constant GNS = 0x18c11FD286C5EC11c3b683Caa813B77f5163A122;
    address constant STETH2 = 0x5979D7b546E38E414F7E9822514be443A4800529;

    address constant V3_Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant V3_Router02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address constant V3_QuoterV2 = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;
    address constant V3_Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address constant V3_NFT = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address constant V3_TickLens = 0xbfd8137f7d1516D3ea5cA83523914859ec47F573;
    address constant V3_NFTPosDescriptor =
        0x91ae842A5Ffd8d12023116943e72A606179294f3;
    address constant V3_NFTDescriptor =
        0x42B24A95702b9986e82d421cC3568932790A48Ec;
    address constant V3_USDCe_USDT_100 =
        0x8c9D230D45d6CfeE39a6680Fb7CB7E8DE7Ea8E71;
    address constant V3_USDCe_USDC_100 =
        0x8e295789c9465487074a65b1ae9Ce0351172393f;
    address constant V3_USDC_WETH_500 =
        0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443;
    address constant V3_DAI_USDCe_100 =
        0xF0428617433652c9dc6D1093A42AdFbF30D29f74;
    address constant V3_WETH_USD_500 =
        0x641C00A822e8b671738d32a431a4Fb6074E5c79d;
    address constant V3_WETH_WBTC_500 =
        0x2f5e87C9312fa29aed5c179E456625D79015299c;
    address constant V3_ARB_USDC_500 =
        0xb0f6cA40411360c03d41C5fFc5F179b8403CdcF8;
    address constant V3_ARB_WETH_500 =
        0xC6F780497A95e246EB9449f5e4770916DCd6396A;
    address constant V3_GMX_WETH_3000 =
        0x1aEEdD3727A6431b8F070C0aFaA81Cc74f273882;
    address constant V3_GMX_WETH_500 =
        0x80A9ae39310abf666A87C743d6ebBD0E8C42158E;

    address constant CL_SEQ_UPTIME = 0xFdB631F5EE196F0ed6FAa767959853A9F217697D;
    address constant CL_ARB = 0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6;
    address constant CL_EUR = 0xA14d53bC1F1c0F31B4aA3BD109344E5009051a84;
    address constant CL_TMCAP = 0x7519bCA20e21725557Bb98d9032124f8885a26C2;
    address constant CL_ETHMCAP = 0xB1f70A229FE7cceD0428245db8B1f6C48c7Ea82a;
    address constant CL_NFTBC = 0x8D0e319eBAA8DF32e088e469062F85abF2eBe599;
    address constant CL_VOLATIVITY = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address constant CL_BUSD = 0x8FCb0F3715A82D83270777b3a5f3a7CF95Ce8Eec;
    address constant CL_CNY = 0xcC3370Bde6AFE51e1205a5038947b9836371eCCb;
    address constant CL_GBP = 0x9C4424Fd84C6661F97D8d6b3fc3C1aAc2BeDd137;
    address constant CL_CBETH_USD = 0xa668682974E3f121185a3cD94f00322beC674275;
    address constant CL_CBETH_ETH = 0x0518673439245BB95A58688Bc31cd513F3D5bDd6;
    address constant CL_STETH_USD = 0x07C5b924399cc23c24a95c8743DE4006a32b7f2a;
    address constant CL_STETH_ETH = 0xded2c52b75B24732e9107377B7Ba93eC1fFa4BAf;
    address constant CL_W_STETH_ETH =
        0xb523AE262D20A936BC152e6023996e46FDC2A95D;
    address constant CL_RETH_ETH = 0xD6aB2298946840262FcC278fF31516D39fF611eF;
    address constant CL_AAPL = 0x8d0CC5f38f9E802475f2CFf4F9fc7000C2E1557c;
    address constant CL_AMZN = 0xd6a77691f071E98Df7217BED98f38ae6d2313EBA;
    address constant CL_META = 0xcd1bd86fDc33080DCF1b5715B6FCe04eC6F85845;
    address constant CL_TSLA = 0x3609baAa0a9b1f0FE4d6CC01884585d0e191C3E3;
    address constant CL_MSFT = 0xDde33fb9F21739602806580bdd73BAd831DcA867;
    address constant CL_SPY = 0x46306F3795342117721D8DEd50fbcF6DF2b3cc10;
    address constant CL_GOOGL = 0x1D1a83331e9D255EB1Aaf75026B60dFD00A252ba;
    address constant CL_BTC = 0x6ce185860a4963106506C203335A2910413708e9;
    address constant CL_WBTC = 0xd0C7101eACbB49F3deCcCc166d238410D6D46d57;
    address constant CL_WBTC_BTC = 0x0017abAc5b6f291F9164e35B1234CA1D697f9CF4;
    address constant CL_DAI = 0xc5C8E77B397E531B8EC06BFb0048328B30E9eCfB;
    address constant CL_FRAX = 0x0809E3d38d1B4214958faf06D8b1B1a2b73f2ab8;
    address constant CL_ETH = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    address constant CL_LINK = 0x86E53CF1B870786351Da77A57575e79CB55812CB;
    address constant CL_JPY = 0x3dD6e51CB9caE717d5a8778CF79A04029f9cFDF8;
    address constant CL_KRW = 0x85bb02E0Ae286600d1c68Bb6Ce22Cc998d411916;
    address constant CL_SGD = 0xF0d38324d1F86a176aC727A4b0c43c9F9d9c5EB1;
    address constant CL_USDT = 0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7;
    address constant CL_USDC = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address constant CL_XAU = 0x1F954Dc24a49708C26E0C1777f16750B5C6d5a2c;
    address constant CL_XAG = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address constant CL_WTI = 0x594b919AD828e693B935705c3F816221729E7AE8;
    address constant CL_EURC = 0xDdE3523b6654F4fE9Ce890A660b6f9679D5Ee6eA;
    address constant CL_LDO = 0xA43A34030088E6510FecCFb77E88ee5e7ed0fE64;

    address constant API3_EUR = 0xA37F6f5a04b7D5eB8DF71799e09D683f8CeC22F3;
    address constant API3_ARB = 0x0cB281EC7DFB8497d07196Dc0f86D2eFD21066A5;
    address constant API3_BTC = 0xe5Cf15fED24942E656dBF75165aF1851C89F21B5;
    address constant API3_ETH = 0x26690F9f17FdC26D419371315bc17950a0FC90eD;
    address constant API3_CNY = 0xb0C30FD871b54eFfdD9e0158EfD086fe6472cF75;
    address constant API3_GBP = 0x2760445db099427F9A394fb1365e1Aa08Ed1f84d;

    address constant ARB_GAS_INFO = 0x000000000000000000000000000000000000006C;
    address constant ARB_STATISTICS =
        0x000000000000000000000000000000000000006F;
    address constant ARB_L1_GOERLI_BRIDGE =
        0x6BEbC4925716945D46F0Ec336D5C2564F419682C;
    address constant ARB_L1_MAINNET_BRIDGE =
        0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f;
    address constant ARB_L1_MAINNET_BRIDGE_NOVA =
        0xc4448b71118c9071Bcb9734A0EAc55D18A153949;

    address constant DAI_L1 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant DAI_L1_GATEWAY =
        0xD3B5b60020504bc3489D6949d545893982BA3011;
    address constant DAI_L1_ESCROW = 0xA10c7CE4b876998858b1a9E12b10092229539400;
    address constant DAI_L2_GATEWAY =
        0x467194771dAe2967Aef3ECbEDD3Bf9a310C76C65;
}

library ArbToken {
    IWETH9 constant WETH = IWETH9(Arb.WETH);
    IERC20 constant gDAI = IERC20(Arb.gDAI);
    IERC20 constant ARB = IERC20(Arb.ARB);
    IERC20 constant FRAX = IERC20(Arb.FRAX);
    IERC20 constant DAI = IERC20(Arb.DAI);
    IERC20 constant USDC = IERC20(Arb.USDC);
    IERC20 constant USDCe = IERC20(Arb.USDCe);
    IERC20 constant LINK = IERC20(Arb.LINK);
    IERC20 constant WBTC = IERC20(Arb.WBTC);
    IERC20 constant STETH2 = IWETH9(Arb.STETH2);
    IERC20 constant USDT = IERC20(Arb.USDT);
    IERC20 constant GMX = IERC20(Arb.GMX);
    IERC20 constant GNS = IERC20(Arb.GNS);
}

interface IArbitrumBridge {
    function depositEth() external payable;
}

interface L2DaiGateway {
    function outboundTransfer(
        address l1Token,
        address to,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes memory);

    function counterpartGateway() external view returns (address);
}

interface L1DaiGateway {
    function outboundTransfer(
        address l1Token,
        address to,
        uint256 amount,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (bytes memory);

    function calculateL2TokenAddress(
        address l1Token
    ) external view returns (address);

    function counterpartGateway() external view returns (address);
}

library ArbBridge {
    L1DaiGateway constant DAI_L1_GATEWAY = L1DaiGateway(Arb.DAI_L1_GATEWAY);
    L2DaiGateway constant DAI_L2_GATEWAY = L2DaiGateway(Arb.DAI_L2_GATEWAY);
    IArbitrumBridge constant ARB_L1_GOERLI =
        IArbitrumBridge(Arb.ARB_L1_GOERLI_BRIDGE);
    IArbitrumBridge constant ARB_L1_MAINNET =
        IArbitrumBridge(Arb.ARB_L1_MAINNET_BRIDGE);
    IArbitrumBridge constant ARB_L1_MAINNET_NOVA =
        IArbitrumBridge(Arb.ARB_L1_MAINNET_BRIDGE_NOVA);
}

library ArbUniV3 {
    uint24 constant defaultFee = 3000;
    ISwapRouter constant Router02 = ISwapRouter(Arb.V3_Router02);
    IQuoterV2 constant QuoterV2 = IQuoterV2(Arb.V3_QuoterV2);
    IUniswapV3NFTManager constant NFT = IUniswapV3NFTManager(Arb.V3_NFT);
    IUniswapV3Factory constant V3Factory = IUniswapV3Factory(Arb.V3_Factory);
}

library ArbAPI3 {
    IAPI3 constant ARB = IAPI3(Arb.API3_ARB);
    IAPI3 constant EUR = IAPI3(Arb.API3_EUR);
    IAPI3 constant BTC = IAPI3(Arb.API3_BTC);
    IAPI3 constant ETH = IAPI3(Arb.API3_ETH);
    IAPI3 constant CNY = IAPI3(Arb.API3_CNY);
    IAPI3 constant GBP = IAPI3(Arb.API3_GBP);
}

library ArbCL {
    IAggregatorV3 constant BTC = IAggregatorV3(Arb.CL_BTC);
    IAggregatorV3 constant DAI = IAggregatorV3(Arb.CL_DAI);
    IAggregatorV3 constant ETH = IAggregatorV3(Arb.CL_ETH);
    IAggregatorV3 constant JPY = IAggregatorV3(Arb.CL_JPY);
    IAggregatorV3 constant USDT = IAggregatorV3(Arb.CL_USDT);
    IAggregatorV3 constant USDC = IAggregatorV3(Arb.CL_USDC);
    IAggregatorV3 constant SEQ_UPTIME = IAggregatorV3(Arb.CL_SEQ_UPTIME);
    IAggregatorV3 constant EUR = IAggregatorV3(Arb.CL_EUR);
    IAggregatorV3 constant ARB = IAggregatorV3(Arb.CL_ARB);
    IAggregatorV3 constant FRAX = IAggregatorV3(Arb.CL_FRAX);
    IAggregatorV3 constant LINK = IAggregatorV3(Arb.CL_LINK);
    IAggregatorV3 constant KRW = IAggregatorV3(Arb.CL_KRW);
    IAggregatorV3 constant SGD = IAggregatorV3(Arb.CL_SGD);
    IAggregatorV3 constant WBTC = IAggregatorV3(Arb.CL_WBTC);
    IAggregatorV3 constant WETH = IAggregatorV3(Arb.CL_ETH);
    IAggregatorV3 constant WETH_BTC = IAggregatorV3(Arb.CL_WBTC_BTC);
    IAggregatorV3 constant AAPL = IAggregatorV3(Arb.CL_AAPL);
    IAggregatorV3 constant AMZN = IAggregatorV3(Arb.CL_AMZN);
    IAggregatorV3 constant META = IAggregatorV3(Arb.CL_META);
    IAggregatorV3 constant TSLA = IAggregatorV3(Arb.CL_TSLA);
    IAggregatorV3 constant MSFT = IAggregatorV3(Arb.CL_MSFT);
    IAggregatorV3 constant SPY = IAggregatorV3(Arb.CL_SPY);
    IAggregatorV3 constant GOOGL = IAggregatorV3(Arb.CL_GOOGL);
    IAggregatorV3 constant XAU = IAggregatorV3(Arb.CL_XAU);
    IAggregatorV3 constant WTI = IAggregatorV3(Arb.CL_WTI);
    IAggregatorV3 constant CBETH_USD = IAggregatorV3(Arb.CL_CBETH_USD);
}
