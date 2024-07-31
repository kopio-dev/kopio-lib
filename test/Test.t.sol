// solhint-disable
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {Tested} from "../src/vm/Tested.t.sol";
import {VmCaller, VmHelp, Log} from "../src/vm/VmLibs.s.sol";
import {ShortAssert} from "../src/vm/ShortAssert.t.sol";
import {PLog, logp} from "../src/vm/PLog.s.sol";
import {Utils} from "../src/utils/Libs.sol";
import {__revert, split} from "../src/utils/Funcs.sol";
import {MockPyth} from "../src/mocks/MockPyth.sol";
import {Based} from "../src/vm/Based.s.sol";

contract TTest is Tested, Based {
    TestContract internal thing;
    using VmCaller for *;
    using VmHelp for *;
    using Log for *;
    using Utils for *;
    using ShortAssert for *;

    function setUp() public {
        useMnemonic("MNEMONIC");
        emit log_string("setUp");
        thing = new TestContract();
    }

    function testBase() public forked("RPC_ARBITRUM_ALCHEMY", 200000000) {
        base("MNEMONIC", "arbitrum");
        base("MNEMONIC", "RPC_ARBITRUM_ALCHEMY");
        address(0x64).link("link-addr");
        address(0x64).link20("link-tkn");
        bytes32(hex"64").link("link-tx");
        block.number.link("link-block");
    }

    function testDlg() public {
        uint256 valA = 12.5e8;
        Log.id("ABC");
        valA.dlg("valA", 8);

        bytes memory bts = bytes("hello");
        bytes32 bts32 = bytes32("val");

        bts.blg("bts");
        bts32.blg("bts32");
        bts32.blgstr("bts32str");
        bts.blgstr("btsstr");

        uint256 pctVal = 105e2;

        pctVal.plg("pct");

        ("h1").h1();
        Log.ctx("testDlg");

        "Hash: ".cc("kek").clg();
    }

    function testStrings() public {
        bytes32 val = "foo";
        bytes(val.txt()).length.eq(66, "str");
        bytes(val.str()).length.eq(3, "txt");

        10.1 ether.dstr().eq("10.10", "dec-0");
        12.5e8.dstr(8).eq("12.50", "dec-1");
        2524e8.dstr(8).eq("2524.00", "dec-2");
        5000.01e8.dstr(8).eq("5000.01", "dec-3");

        0.0005e8.dstr(8).eq("0.0005", "dec-4");
        0.1e2.dstr(2).eq("0.10", "dec-5");
        1 ether.dstr(18).eq("1.00", "dec-6");

        100.10101 ether.dstr(18).eq("100.10101", "dec-7");
        10101010.10101010 ether.dstr(18).eq("10101010.1010101", "dec-8");

        10101010.1 ether.dstr(18).eq("10101010.10", "dec-9");
        10101010.01 ether.dstr(18).eq("10101010.01", "dec-10");
        10101010.000 ether.dstr(18).eq("10101010.00", "dec-11");
        10101010.0001 ether.dstr(18).eq("10101010.0001", "dec-12");

        PLog.clg("s1", address(0x64), 100e4);
        PLog.clg("s2", "s3");
        string memory r;
        PLog.clg(bytes(r).length, "empty-len");
        this.testStrings.selector.blg(4);
        this.testStrings.selector.txt(4).eq(
            bytes4(keccak256("testStrings()")).txt(
                this.testStrings.selector.length
            ),
            "sel"
        );
    }

    function testDecimals() public {
        uint256 wad = 1e18;
        uint256 ray = 1e27;

        wad.toDec(18, 27).eq(ray, "wad-ray");
        ray.toDec(27, 18).eq(wad, "ray-wad");

        1.29e18.toDec(18, 1).eq(12, "a-b");
    }
    function testLink() public {}

    function testBytes() public {
        bytes32 val = bytes32(abi.encodePacked(uint192(192), uint64(64)));
        (uint192 a, uint64 b) = abi.decode(split(val, 192), (uint192, uint64));
        a.eq(192, "a");
        b.eq(64, "b");
    }

    function testRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                TestContract2.TestError.selector,
                "nope",
                1 ether,
                TestContract2.Structy("hello", 1 ether)
            )
        );
        thing.nope();
    }

    function testLogs() public {
        vm.startBroadcast(address(5));
        broadcastWith(address(2));
        prank(address(5));
        Log.ctx("testLogs");
        thing.func();
        uint16 a = 150e2;
        a.plg("pct1");

        uint32 b = 152e2;
        b.plg("pct2");

        uint256 c = 153.33e2;
        c.plg("pct3");

        string memory s = "hello";
        bytes memory bts = bytes(s);
        bytes32 bts32 = bytes32("val");
        s.clg();
        s.blg(bts);
        bts.blg();
        bts32.blg(s);
    }

    function testBroadcasts() public {
        address first = getAddr(0);
        address second = getAddr(1);
        address third = getAddr(2);
        vm.startBroadcast(first);
        vmSender().eq(first);

        broadcastWith(second);
        vmSender().eq(second);

        broadcastWith(first);
        _broadcastRestored().eq(second);

        vmSender().eq(first);
        thing.addr().eq(second);

        broadcastWith(third);
        _unbroadcastedRestored().eq(msg.sender);
        vmSender().eq(third);
        vm.stopBroadcast();

        _unbroadcastedRestored();
    }

    function _broadcastRestored()
        internal
        rebroadcasted(getAddr(1))
        returns (address)
    {
        thing.save();
        return vmSender();
    }

    function _unbroadcastedRestored()
        internal
        reclearCallers
        returns (address)
    {
        thing.save();
        return vmSender();
    }

    function testPranks() public {
        address first = getAddr(0);
        address second = getAddr(1);
        address third = getAddr(2);
        vm.startPrank(first);
        vmSender().eq(first);

        prank(second);
        vmSender().eq(second);

        prank(first);
        _prankRestored().eq(second);
        vmSender().eq(first);
        thing.addr().eq(second);

        prank(third);
        _unprankRestored().eq(msg.sender);
        vmSender().eq(third);
    }
    function _prankRestored() internal repranked(getAddr(1)) returns (address) {
        thing.save();
        return vmSender();
    }

    function _unprankRestored() internal reclearCallers returns (address) {
        thing.save();
        return vmSender();
    }

    function testMinLog() public pure {
        logp(abi.encodeWithSignature("log(string,uint256)", "hello", 1 ether));
    }
}

contract TestContract {
    using Log for *;
    using VmCaller for *;
    using VmHelp for *;
    address public addr;

    TestContract2 public thing2;

    constructor() {
        thing2 = new TestContract2();
    }

    function save() public {
        addr = msg.sender;
    }

    function func() public {
        Log.clg("TestContract");
        uint256[] memory nums = new uint256[](3);

        nums[0] = 1 ether;
        nums[1] = 100 ether;
        nums[2] = 0 ether;

        Log.ctx("func()");
    }

    function nope() public view {
        (, bytes memory data) = address(thing2).staticcall(
            abi.encodeWithSelector(thing2.nope.selector)
        );
        __revert(data);
    }
}

contract TestContract2 {
    struct Structy {
        string mesg;
        uint256 val;
    }
    error TestError(string mesg, uint256 val, Structy _struct);

    function nope() public pure {
        revert TestError("nope", 1 ether, Structy("hello", 1 ether));
    }
}
