// SPDX-License-Identifier: MIT
// solhint-disable
pragma solidity ^0.8.0;
import {IKreditsDiamond} from "../support/IKreditsDiamond.sol";
import {EnumerableSet, RoleData, SCDPAccountIndexes, SCDPAssetData, SCDPAssetIndexes, SCDPSeizeData} from "../IKopioCore.sol";

IKreditsDiamond constant kredits = IKreditsDiamond(Kresko.kreditsAddr);

library Kresko {
    address constant kissAddr = 0x6A1D6D2f4aF6915e6bBa8F2db46F442d18dB5C9b;
    address constant kreskoAddr = 0x0000000000177abD99485DCaea3eFaa91db3fe72;
    address constant kreditsAddr = 0x8E84a3B8e0b074c149b8277c753Dc6396bB95F48;
    address constant multicallAddr = 0xC35A7648B434f0A161c12BD144866bdf93c4a4FC;
    address constant factoryAddr = 0x000000000070AB95211e32fdA3B706589D3482D5;
    address constant vaultAddr = 0x2dF01c1e472eaF880e3520C456b9078A5658b04c;
    address constant dataAddr = 0xef5196c4bDd74356943dcC20A7d27eAdD0F9b9D7;
    address constant marketStatusAddr =
        0xf6188e085ebEB716a730F8ecd342513e72C8AD04;

    address constant krETHAddr = 0x24dDC92AA342e92f26b4A676568D04d2E3Ea0abc;
    address constant krBTCAddr = 0x11EF4EcF3ff1c8dB291bc3259f3A4aAC6e4d2325;
    address constant krSOLAddr = 0x96084d2E3389B85f2Dc89E321Aaa3692Aed05eD2;
    address constant krEURAddr = 0x83BB68a7437b02ebBe1ab2A0E8B464CC5510Aafe;
    address constant krJPYAddr = 0xc4fEE1b0483eF73352447b1357adD351Bfddae77;
    address constant krGBPAddr = 0xdb274afDfA7f395ef73ab98C18cDf3D9C03b538C;
    address constant krXAUAddr = 0xe0A49C9215206f9cfb79981901bDF1f2716d3215;
    address constant krXAGAddr = 0x1d6A65BBfbbc995a19Fc19cB17FA135f9EdB6A24;
    address constant krDOGEAddr = 0x4a719F02aF3f0FFf15447B6824464857ADB5210D;

    address constant akrETHAddr = 0x3103570A28ca026e818c79608F1FF804F4Bde284;
    address constant akrBTCAddr = 0xc67a33599f73928D24D32fC0015e187157233410;
    address constant akrSOLAddr = 0x362cB60d235Cf8258042DAfB2a3Cdb14302D9D0f;
    address constant akrEURAddr = 0xBb6053898C5f6e536405fA324839141aA102b6D9;
    address constant akrJPYAddr = 0x3438Eb57e5b0f1CbEca257Aea9644B26b1B61EaC;
    address constant akrGBPAddr = 0x37BddA32281c15716D35f901b8141f7F382220C1;
    address constant akrXAUAddr = 0x3A1ffd3426916B16878AAa072B74DdaEC3e31007;
    address constant akrXAGAddr = 0x4d516E2049542B350368A44cBE71F3bbc00000D6;
    address constant akrDOGEAddr = 0x44217deFe47C3F5D03471d59723CF437efBfb871;

    address constant safe = 0x266489Bde85ff0dfe1ebF9f0a7e6Fed3a973cEc3;
    address constant nftMultisig = 0x389297F0d8C489954D65e04ff0690FC54E57Dad6;
    address constant kreskianAddr = 0xAbDb949a18d27367118573A217E5353EDe5A0f1E;
    address constant questAddr = 0x1C04925779805f2dF7BbD0433ABE92Ea74829bF6;

    bytes32 constant MINTER_STORAGE_POSITION =
        keccak256("kresko.minter.storage");

    function ms() internal pure returns (MinterState storage state) {
        bytes32 position = MINTER_STORAGE_POSITION;
        assembly {
            state.slot := position
        }
    }

    function cs() internal pure returns (CommonState storage state) {
        bytes32 position = bytes32(COMMON_STORAGE_POSITION);
        assembly {
            state.slot := position
        }
    }

    struct SCDPState {
        address[] collaterals;
        address[] krAssets;
        mapping(address => mapping(address => bool)) isRoute;
        mapping(address => bool) isEnabled;
        mapping(address => SCDPAssetData) assetData;
        mapping(address => mapping(address => uint256)) deposits;
        mapping(address => mapping(address => uint256)) depositsPrincipal;
        mapping(address => SCDPAssetIndexes) assetIndexes;
        mapping(address => mapping(address => SCDPAccountIndexes)) accountIndexes;
        mapping(address => mapping(uint256 => SCDPSeizeData)) seizeEvents;
        address feeAsset;
        uint32 minCollateralRatio;
        uint32 liquidationThreshold;
        uint32 maxLiquidationRatio;
    }

    struct SDIState {
        uint256 totalDebt;
        uint256 totalCover;
        address coverRecipient;
        uint48 coverThreshold;
        uint48 coverIncentive;
        address[] coverAssets;
    }

    bytes32 constant SCDP_STORAGE_POSITION = keccak256("kresko.scdp.storage");
    bytes32 constant SDI_STORAGE_POSITION =
        keccak256("kresko.scdp.sdi.storage");

    function scdp() internal pure returns (SCDPState storage state) {
        bytes32 position = SCDP_STORAGE_POSITION;
        assembly {
            state.slot := position
        }
    }

    function sdi() internal pure returns (SDIState storage state) {
        bytes32 position = SDI_STORAGE_POSITION;
        assembly {
            state.slot := position
        }
    }

    struct Asset {
        bytes32 ticker;
        address anchor;
        uint8[2] oracles;
        uint16 factor;
        uint16 kFactor;
        uint16 openFee;
        uint16 closeFee;
        uint16 liqIncentive;
        uint256 maxDebtMinter;
        uint256 maxDebtSCDP;
        uint256 depositLimitSCDP;
        uint16 swapInFeeSCDP;
        uint16 swapOutFeeSCDP;
        uint16 protocolFeeShareSCDP;
        uint16 liqIncentiveSCDP;
        uint8 decimals;
        bool isMinterCollateral;
        bool isMinterMintable;
        bool isSharedCollateral;
        bool isSwapMintable;
        bool isSharedOrSwappedCollateral;
        bool isCoverAsset;
    }

    struct Oracle {
        address feed;
        bytes32 pythId;
        uint256 staleTime;
        bool invertPyth;
        bool isClosing;
    }

    struct Pause {
        bool enabled;
        uint256 timestamp0;
        uint256 timestamp1;
    }

    struct SafetyState {
        Pause pause;
    }

    struct CommonState {
        mapping(address => Asset) assets;
        mapping(bytes32 => mapping(uint8 => Oracle)) oracles;
        mapping(address => mapping(uint8 => SafetyState)) safetyState;
        address feeRecipient;
        address pythEp;
        address sequencerUptimeFeed;
        uint32 sequencerGracePeriodTime;
        uint16 maxPriceDeviationPct;
        uint8 oracleDecimals;
        bool safetyStateSet;
        uint256 entered;
        mapping(bytes32 role => RoleData data) _roles;
        mapping(bytes32 role => EnumerableSet.AddressSet member) _roleMembers;
    }

    bytes32 constant COMMON_STORAGE_POSITION =
        keccak256("kresko.common.storage");

    struct MinterState {
        mapping(address => address[]) depositedCollateralAssets;
        mapping(address => mapping(address => uint256)) collateralDeposits;
        mapping(address => mapping(address => uint256)) kreskoAssetDebt;
        mapping(address => address[]) mintedKreskoAssets;
        address[] krAssets;
        address[] collaterals;
        address feeRecipient;
        uint32 maxLiquidationRatio;
        uint32 minCollateralRatio;
        uint32 liquidationThreshold;
        uint256 minDebtValue;
    }
}
