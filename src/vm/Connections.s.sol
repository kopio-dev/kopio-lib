// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {mvm} from "./MinVm.s.sol";
import {PLog} from "./PLog.s.sol";

type Connection is uint256;

using Connections for Connection global;

library Connections {
    struct State {
        mapping(string network => Connection[]) networks;
        Info[] pool;
    }

    bytes32 private constant SLOT = keccak256("connections.slot");

    struct Info {
        uint256 id;
        string network;
        string rpc;
        uint256 chainId;
        uint256 blockStart;
        uint256 blockNow;
        address sender;
    }

    error NoConnections(string);
    error NoConnection(string, uint256, uint256);

    function reconnect(string memory _network) internal {
        reconnect(_network, _s().networks[_network].length);
    }

    function reconnect(string memory _network, uint256 _at) internal {
        use(_s().networks[_network][_at]);
    }

    function use(Connection _c) internal returns (Connection c_) {
        mvm.selectFork(info((c_ = _c)).id);
    }

    function roll(Connection _c) internal {
        Info storage _info = info(_c);
        mvm.rollFork(_info.id, 0);
        _info.blockNow = 0;
    }
    function roll(Connection _c, uint256 _toBlock) internal {
        Info storage _info = info(_c);
        mvm.rollFork(_info.id, _toBlock);
        _info.blockNow = _toBlock;
    }

    function send(Connection _c, bytes32 _tx) internal returns (Connection) {
        Info storage _info = info(_c);
        mvm.transact(_info.id, _tx);
        return _c;
    }

    function reset(Connection _c) internal returns (Connection) {
        Info storage _info = info(_c);
        mvm.rollFork(_info.id, _info.blockStart);
        _info.blockNow = _info.blockStart;
        return _c;
    }

    function next(Connection c) internal pure returns (Connection) {
        return Connection.wrap(Connection.unwrap(c) + 1);
    }

    function prev(Connection c) internal pure returns (Connection) {
        return Connection.wrap(Connection.unwrap(c) - 1);
    }

    function create(
        uint256 forkId,
        string memory _network,
        string memory _rpc,
        uint256 _blockNr,
        address sender
    ) internal returns (Connection c_) {
        Info[] storage pool = _s().pool;
        pool.push(
            Info(
                forkId,
                _network,
                _rpc,
                block.chainid,
                _blockNr,
                _blockNr,
                sender
            )
        );
        _s().networks[_network].push((c_ = Connection.wrap(pool.length)));
    }

    function info() internal view returns (Info storage) {
        return info(getConnection());
    }

    function info(Connection _c) internal view returns (Info storage) {
        return _s().pool[Connection.unwrap(_c) - 1];
    }

    function count() internal view returns (uint256) {
        return _s().pool.length;
    }

    function connections(
        string memory _network
    ) internal view returns (uint256) {
        return _s().networks[_network].length;
    }

    function getConnection() internal view returns (Connection c_) {
        Info[] storage pool = _s().pool;
        if (pool.length == 0) revert Connections.NoConnections("");

        try mvm.activeFork() returns (uint256 activeId) {
            for (uint256 i; i < pool.length; i++) {
                if (pool[i].id == activeId) return Connection.wrap(i + 1);
            }
        } catch {
            return Connection.wrap(pool.length);
        }
    }

    function getConnection(
        string memory _network
    ) internal view returns (Connection) {
        return getConnection(_network, _s().networks[_network].length);
    }

    function getConnection(
        string memory _network,
        uint256 _at
    ) internal view returns (Connection) {
        uint256 len = connections(_network);
        if (len < _at) revert Connections.NoConnection(_network, _at, len);
        return _s().networks[_network][_at - 1];
    }

    function clg(Connection _c) internal {
        Info memory _info = info(_c);

        PLog.clg(
            "*** Connection ->",
            string.concat(
                mvm.toString(block.chainid),
                " - ",
                _info.network,
                " - ",
                _info.rpc,
                "@",
                _blockStr(_info.blockStart),
                "/",
                _blockStr(_info.blockNow),
                " - ",
                mvm.toString(
                    (((mvm.unixTime() / 1000) - block.timestamp) / 60)
                ),
                "m ago"
            )
        );
    }

    function _blockStr(uint256 blockNr) private pure returns (string memory) {
        return blockNr == 0 ? "latest" : mvm.toString(blockNr);
    }

    function _s() private pure returns (State storage s) {
        bytes32 slot = SLOT;
        assembly {
            s.slot := slot
        }
    }
}
