// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Scripted} from "./Scripted.s.sol";
import {PLog} from "./PLog.s.sol";
import {PythScript} from "../vm-ffi/PythScript.s.sol";
import {File} from "./Files.s.sol";
import {Connections, Connection} from "./Connections.s.sol";

contract Connected is PythScript, Scripted {
    File internal _file;

    modifier useFile(string memory _loc) virtual {
        _file = fileAt(_loc);
        _;
    }

    modifier usePythSync() virtual {
        syncTime();
        updatePyth();
        _;
    }

    modifier ConnectM(string memory _mnemonic, string memory _network) virtual {
        connect(_mnemonic, _network, 0);
        _;
    }

    modifier ConnectMAt(
        string memory _mnemonic,
        string memory _network,
        uint256 _blockNr
    ) virtual {
        connect(_mnemonic, _network, _blockNr);
        _;
    }

    modifier ConnectWith(string[2] memory _wallets, string memory _network)
        virtual {
        connect(_wallets, _network, 0);
        _;
    }

    modifier ConnectWithAt(
        string[2] memory _wallets,
        string memory _network,
        uint256 _blockNr
    ) virtual {
        connect(_wallets, _network, _blockNr);
        _;
    }

    modifier Reconnect(string memory _network) virtual {
        Connections.reconnect(_network);
        _;
    }

    modifier Connect(string memory _network) virtual {
        connect(_network);
        _;
    }

    modifier Fork(string memory _network) virtual {
        connect(_network);
        _;
    }

    modifier ConnectAt(string memory _network, uint256 _blockNr) virtual {
        connect(_network, _blockNr);
        _;
    }

    modifier ForkAt(string memory _network, uint256 _blockNr) virtual {
        connect(_network, _blockNr);
        _;
    }

    modifier highlight() virtual {
        PLog.clg(
            "***************************************************************"
        );
        _;
        PLog.clg(
            "***************************************************************\n"
        );
    }

    function connect(
        string memory _mnemonic,
        string memory _network,
        uint256 _blockNr
    ) internal virtual highlight returns (Connection) {
        wallet(_mnemonic);
        return connect(_network, _blockNr);
    }

    function connect(
        string[2] memory _wallets,
        string memory _network,
        uint256 _blockNr
    ) internal virtual highlight returns (Connection) {
        wallet(_wallets);
        return connect(_network, _blockNr);
    }

    function connect(
        string memory _mnemonic,
        string memory _network
    ) internal virtual returns (Connection) {
        return connect(_mnemonic, _network, 0);
    }

    function connect(
        string[2] memory _wallets,
        string memory _network
    ) internal virtual returns (Connection) {
        return connect(_wallets, _network, 0);
    }

    function wallet(
        string memory _mnemonic
    ) internal virtual returns (address payable) {
        return getSenderOr(_setMnemonic(_mnemonic));
    }

    function wallet(
        string[2] memory _wallets
    ) internal virtual returns (address payable) {
        (, address pkaddr) = _setWallets(_wallets);
        return getSenderOr(pkaddr);
    }

    function getSenderOr(
        address _newSender
    ) internal virtual returns (address payable) {
        PLog.clg(super.senderOr(_newSender), "sender:");
        return sender;
    }

    function connect(
        string memory _network
    ) internal virtual returns (Connection) {
        return connect(_network, 0);
    }

    function connect(
        string memory _network,
        uint256 _blockNr
    ) internal virtual returns (Connection c_) {
        string memory rpc = getRPC(_network);
        uint256 forkId = _blockNr != 0
            ? vm.createSelectFork(rpc, _blockNr)
            : vm.createSelectFork(rpc);
        rpc = vm.rpcUrl(rpc);

        Connections.clg(
            c_ = Connections.create(forkId, _network, rpc, _blockNr, sender)
        );
    }

    function connect(Connection _c) internal virtual returns (Connection) {
        return Connections.use(_c);
    }

    function getConnection() internal view virtual returns (Connection) {
        return Connections.getConnection();
    }

    function connection()
        internal
        view
        virtual
        returns (Connections.Info storage)
    {
        return Connections.info();
    }
}
