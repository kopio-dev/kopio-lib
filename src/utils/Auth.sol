// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Auth {
    using Auth for *;

    struct Role {
        bytes32 parent;
        uint256 count;
        uint128 max;
        uint128 validFrom;
    }

    struct Transfer {
        address from;
        uint96 at;
    }

    struct State {
        mapping(address user => mapping(bytes32 role => uint256 validFrom)) users;
        mapping(address to => mapping(bytes32 role => Transfer)) transfers;
        mapping(bytes32 => Role) role;
        uint256 roles;
        address owner;
    }

    function initialize(address sudo) internal returns (State storage s) {
        if ((s = state()).roles != 0) revert Initialized();
        _grant(sudo, Auth.SUDO, block.timestamp);
        s.owner = sudo;
    }

    function setParent(bytes32 role, bytes32 parent) internal {
        msg.sender.ensureAdmin(role).parent = parent;
    }

    function setLimit(bytes32 role, uint256 max) internal {
        msg.sender.ensureAdmin(role).max = uint128(max);
    }

    function setRoleValidFrom(bytes32 role, uint256 timestamp) internal {
        msg.sender.ensureAdmin(role).validFrom = uint128(timestamp);
    }

    function ensure(address user, bytes32 role) internal view {
        ensure(user, role, block.timestamp);
    }

    function ensure(address user, address addr) internal view {
        ensure(user, addr, block.timestamp);
    }
    function ensure(address user, address addr, uint256 at) internal view {
        ensure(user, toRole(addr), at);
    }

    function ensure(address user, bytes32 role, uint256 at) internal view {
        if (!enabled(role)) revert RoleDisabled(role);
        if (!user.hasRole(role, at)) revert Unauthorized(user, role);
    }

    function ensureAdmin(
        address user,
        bytes32 role
    ) internal view returns (Role storage cfg) {
        cfg = role.info();
        if (!user.hasRole(cfg.parent) || !enabled(cfg.parent)) {
            ensure(user, Auth.SUDO);
        }
    }

    function isAdmin(address user, bytes32 role) internal view returns (bool) {
        return user.hasRole(role.info().parent);
    }

    function grant(address to, bytes32 role) internal returns (uint256) {
        return grant(to, role, block.timestamp);
    }

    function grant(
        address to,
        bytes32 role,
        uint256 at
    ) internal nonzero(to) returns (uint256) {
        msg.sender.ensureAdmin(role);
        if (to.hasOrPending(role)) revert Noop();
        return _grant(to, role, at);
    }

    function grant(address to, address addr) internal returns (uint256) {
        return grant(to, addr, block.timestamp);
    }

    function grant(
        address to,
        address addr,
        uint256 at
    ) internal returns (uint256) {
        return grant(to, toRole(addr), at);
    }

    function revoke(address from, address addr) internal returns (uint256) {
        return revoke(from, toRole(addr));
    }

    function revoke(
        address user,
        bytes32 role
    ) internal returns (uint256 count) {
        if (!user.hasOrPending(role)) revert Noop();

        if (msg.sender != user) msg.sender.ensureAdmin(role);

        State storage s = state();
        Role storage meta = s.role[role];
        if (!_hasRole(user, role, block.timestamp)) {
            delete s.transfers[user][role];
            return meta.count;
        }

        s.users[user][role] = 0;
        if ((count = --meta.count) == 0) --s.roles;
    }

    function transferRole(
        bytes32 role,
        address from,
        address to,
        uint256 at
    ) internal nonzero(to) {
        if (from != msg.sender) msg.sender.ensureAdmin(role);

        if (at < block.timestamp) {
            _transfer(role, from, to);
            return;
        }

        from.ensure(role);
        state().transfers[to][role] = Transfer(from, uint96(at));
    }

    function transferAddr(
        address addr,
        address from,
        address to,
        uint256 at
    ) internal {
        transferRole(toRole(addr), from, to, at);
    }

    function claimAddr(address addr) internal returns (address, address) {
        return claimRole(toRole(addr));
    }

    function claimRole(
        bytes32 role
    ) internal returns (address from, address to) {
        Transfer storage transfer = state().transfers[msg.sender][role];

        if (transfer.at < block.timestamp)
            revert Locked(transfer.at, block.timestamp);

        return _transfer(role, transfer.from, msg.sender);
    }

    function hasRole(address user, address addr) internal view returns (bool) {
        return hasRole(user, addr, block.timestamp);
    }

    function hasRole(
        address user,
        address addr,
        uint256 at
    ) internal view returns (bool) {
        return hasRole(user, toRole(addr), at);
    }

    function hasRole(address user, bytes32 role) internal view returns (bool) {
        return user.hasRole(role, block.timestamp);
    }

    function hasRole(
        address user,
        bytes32 role,
        uint256 at
    ) internal view returns (bool) {
        if (role.info().validFrom > at) return false;
        return _hasRole(user, role, at);
    }

    function _hasRole(
        address user,
        bytes32 role,
        uint256 at
    ) private view returns (bool) {
        uint256 validFrom = user.get(role);
        return validFrom != 0 && validFrom <= at;
    }

    function get(address user, bytes32 role) internal view returns (uint256) {
        return state().users[user][role];
    }

    function hasOrPending(
        address user,
        bytes32 role
    ) internal view returns (bool) {
        State storage s = state();
        return s.users[user][role] != 0 || s.transfers[user][role].at != 0;
    }

    function pendingRole(
        address user,
        bytes32 role
    ) internal view returns (Transfer storage) {
        return state().transfers[user][role];
    }

    function totalRoles() public view returns (uint256) {
        return state().roles;
    }

    function info(bytes32 role) internal view returns (Role storage) {
        return state().role[role];
    }

    function info(address addr) internal view returns (Role storage) {
        return info(toRole(addr));
    }

    function enabled(bytes32 role) internal view returns (bool) {
        return info(role).validFrom <= block.timestamp;
    }

    function enabled(address addr) internal view returns (bool) {
        return enabled(toRole(addr));
    }

    function owner() internal view returns (address) {
        return state().owner;
    }

    function toRole(address addr) internal pure returns (bytes32) {
        return bytes20(addr);
    }

    function setOwner(
        address to
    ) internal returns (address prev, address next) {
        msg.sender.ensureAdmin(Auth.SUDO);
        State storage s = state();

        prev = s.owner;
        next = (state().owner = to);
    }

    function state() private pure returns (State storage s) {
        bytes32 slot = SLOT;
        assembly {
            s.slot := slot
        }
    }

    function _grant(
        address user,
        bytes32 role,
        uint256 at
    ) private returns (uint256 count) {
        State storage s = state();
        Role storage meta = s.role[role];
        if ((count = ++meta.count) == 1) s.roles++;

        if (meta.max != 0 && count > meta.max) {
            revert RoleFull(role, meta.max);
        }

        s.users[user][role] = at;
    }

    function _transfer(
        bytes32 role,
        address from,
        address to
    ) private returns (address, address) {
        from.ensure(role);
        if (_hasRole(to, role, type(uint128).max)) revert Noop();

        Auth.State storage s = state();

        s.users[from][role] = 0;
        s.users[to][role] = block.timestamp;

        if (s.transfers[to][role].at != 0) {
            delete s.transfers[to][role];
        }

        return (from, to);
    }

    error Unauthorized(address who, bytes32);
    error NotNextSudo(address who);
    error Locked(uint256 unlock, uint256 time);
    error ZeroAddress();
    error AlreadyGranted(address to, bytes32 role);
    error Noop();
    error Initialized();
    error RoleDisabled(bytes32 role);
    error RoleFull(bytes32, uint256 max);

    event RoleGranted(address indexed to, bytes32 role);
    event RoleRevoked(address indexed from, bytes32 role);
    event OwnershipTransferred(address indexed prev, address indexed now);

    modifier nonzero(address addr) {
        if (addr == address(0)) revert ZeroAddress();
        _;
    }

    bytes32 private constant SLOT =
        keccak256(abi.encode(uint256(keccak256("auth.storage.slot")) - 1)) &
            ~bytes32(uint256(0xff));

    bytes32 internal constant SUDO = 0;
}
