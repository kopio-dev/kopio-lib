// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Auth} from "../src/utils/Auth.sol";
import {Tested} from "../src/vm/Tested.t.sol";
import {Based} from "../src/vm/Based.s.sol";
import {ShortAssert} from "../src/vm/ShortAssert.t.sol";
import {Log} from "../src/vm/VmLibs.s.sol";
import {TDummy, TFullAuth, Role, Init} from "./AuthImpl.sol";

// solhint-disable

contract AuthTest is Tested, Based {
    using ShortAssert for *;
    using Log for *;

    TFullAuth internal tAuth;
    TDummy internal tDummy;

    address deployer = makeAddr("deployer");

    address operator = makeAddr("operator");
    address keeper = makeAddr("keeper");
    address owner = makeAddr("owner");

    address user = makeAddr("user");

    Init init = Init({operator: operator, keeper: keeper, owner: owner});

    function setUp() public pranked(deployer) {
        syncTime();
        tAuth = new TFullAuth(init);
        tDummy = new TDummy(address(tAuth));
    }

    function testAuthSetup() public {
        tAuth.hasRole(deployer, Auth.SUDO).yes("deployer-sudo");
        tAuth.hasRole(deployer, address(tAuth)).yes("contract-role");

        tAuth.isRoleAdmin(deployer, Role.OPERATOR).yes("op-admin");
        tAuth.isRoleAdmin(deployer, Role.KEEPERS).no("keeper-admin");

        tAuth.hasRole(init.operator, Role.OPERATOR).yes("op-role");
        tAuth.hasRole(init.keeper, Role.KEEPERS).yes("op-role");
        tAuth.isRoleAdmin(init.operator, Role.KEEPERS).yes("op-keeper");

        tAuth.getRole(Role.OPERATOR).count.eq(1, "op-count");
        tAuth.getRole(Role.KEEPERS).count.eq(1, "keeper-count");
        tAuth.getRole(Auth.SUDO).count.eq(1, "sudo-count");
        tAuth.getRole(address(tAuth)).count.eq(1, "contract-count");
        tAuth.totalRoles().eq(4, "total-roles");

        tAuth.owner().eq(init.owner, "owner");
        tAuth.keeper().eq(init.keeper, "keeper");
    }

    function testRoleAdmin() public {
        address dummyAddr = address(tDummy);
        bytes32 newRole = "foo";

        prank(deployer);
        tAuth.grantRole(owner, Auth.SUDO);
        tAuth.grantRole(dummyAddr, newRole);

        prank(operator);
        tAuth.grantRole(user, Role.KEEPERS);
        vm.expectRevert(Unauthorized(operator, Auth.SUDO));
        tAuth.grantRole(user, dummyAddr);
        vm.expectRevert(Unauthorized(operator, Auth.SUDO));
        tAuth.grantRole(user, Role.OPERATOR);

        prank(deployer);
        vm.expectRevert(RoleFull(Role.OPERATOR, 1));
        tAuth.grantRole(user, Role.OPERATOR);

        tAuth.totalRoles().eq(5);
        tAuth.transferRole(newRole, dummyAddr, operator, block.timestamp);
        tAuth.revokeRole(operator, Role.OPERATOR);
        tAuth.totalRoles().eq(4);

        tAuth.grantRole(deployer, Role.OPERATOR);
        tAuth.transferRole(Role.OPERATOR, deployer, user, block.timestamp);
        tAuth.revokeRole(operator, newRole);

        prank(operator);
        vm.expectRevert(Locked(0, block.timestamp));
        tAuth.claimRole(newRole);

        prank(user);
        tAuth.claimRole(Role.OPERATOR);

        tAuth.isRoleAdmin(operator, Role.KEEPERS).no("op-keepers");
        tAuth.isRoleAdmin(user, Role.KEEPERS).yes("user-keepers");

        tAuth.hasRole(operator, newRole).no("op-newrole");
        tAuth.hasRole(dummyAddr, newRole).yes("dummy-newrole");
    }

    function testRoleHeld() public {
        prank(operator);
        vm.expectRevert(Unauthorized(operator, Role.OPERATOR));
        tAuth.setKeeper(user);
        skip(59);
        vm.expectRevert(Unauthorized(operator, Role.OPERATOR));
        tAuth.setKeeper(user);
        skip(1);
        tAuth.setKeeper(user);
        tAuth.keeper().eq(user, "keeper");
        tAuth.grantRole(user, Role.KEEPERS, block.timestamp + 1 seconds);

        prank(user);
        vm.expectRevert(Unauthorized(user, Role.KEEPERS));
        tAuth.setKeeperValue(1);
        skip(1);
        tAuth.setKeeperValue(2);
        tAuth.keeperValue().eq(2, "keeper-value");
    }

    function testRoleTransfer() public {
        uint256 roleCount = tAuth.totalRoles();
        prank(user);
        vm.expectRevert(Unauthorized(user, Auth.SUDO));
        tAuth.transferRole(Role.OPERATOR, operator, user, block.timestamp - 1);

        prank(operator);
        vm.expectRevert(Unauthorized(operator, Auth.SUDO));
        tAuth.transferRole(Auth.SUDO, deployer, operator, block.timestamp - 1);

        tAuth.transferRole(Role.OPERATOR, operator, user, block.timestamp);
        tAuth.totalRoles().eq(roleCount, "role-count");
        tAuth.hasRole(operator, Role.OPERATOR).yes("op-role");
        tAuth.hasRole(user, Role.OPERATOR).no("user-role");

        prank(user);
        vm.expectRevert(Unauthorized(user, Role.OPERATOR));
        tAuth.transferRole(Role.OPERATOR, user, operator, block.timestamp - 1);

        tAuth.claimRole(Role.OPERATOR);
        tAuth.hasRole(operator, Role.OPERATOR).no("op");
        tAuth.hasRole(user, Role.OPERATOR).yes("user");

        tAuth.transferRole(Role.OPERATOR, user, operator, block.timestamp - 1);
        tAuth.hasRole(operator, Role.OPERATOR).yes("op-op");
        tAuth.hasRole(user, Role.OPERATOR).no("user-op");

        prank(operator);
        tAuth.transferRole(Role.OPERATOR, operator, user, block.timestamp + 1);
        tAuth.transferRole(Role.OPERATOR, operator, user, block.timestamp + 10);
        tAuth.revokeRole(operator, Role.OPERATOR);

        skip(1);

        prank(user);
        tAuth.hasPendingRole(user, Role.OPERATOR).yes("user-pending");
        vm.expectRevert(Unauthorized(operator, Role.OPERATOR));
        tAuth.claimRole(Role.OPERATOR);
        tAuth.revokeRole(user, Role.OPERATOR);
        tAuth.hasPendingRole(user, Role.OPERATOR).no("user-pending");

        prank(deployer);
        tAuth.transferRole(
            address(tAuth),
            deployer,
            owner,
            block.timestamp - 1
        );
        tAuth.hasRole(deployer, address(tAuth)).no("contract-depl");
        tAuth.hasRole(owner, address(tAuth)).yes("owner-contract");
    }

    function testAccessControl() public {
        prank(keeper);
        tAuth.setKeeperValue(1);

        prank(user);
        vm.expectRevert(Unauthorized(user, Role.KEEPERS));
        tAuth.setKeeperValue(2);

        prank(deployer);
        vm.expectRevert(Unauthorized(deployer, Role.KEEPERS));
        tAuth.setKeeperValue(3);

        prank(owner);
        vm.expectRevert(Unauthorized(owner, Role.KEEPERS));
        tAuth.setKeeperValue(4);

        prank(operator);
        vm.expectRevert(Unauthorized(operator, Role.KEEPERS));
        tAuth.setKeeperValue(5);

        prank(user);
        tAuth.setValue(user, 1);
        vm.expectRevert(Unauthorized(user, Role.KEEPERS));
        tAuth.setValue(deployer, 2);
        vm.expectRevert(Unauthorized(user, Auth.SUDO));
        tAuth.setValueAuth(deployer, 2);

        prank(keeper);
        tAuth.setValue(deployer, 1);
        vm.expectRevert(Unauthorized(keeper, Auth.SUDO));
        tAuth.setValueAuth(deployer, 2);

        prank(operator);
        tAuth.setValueAuth(deployer, 0);
        vm.expectRevert(Unauthorized(operator, Role.KEEPERS));
        tAuth.setValue(deployer, 1);
    }

    function testRoleAddr() public {
        prank(user);
        vm.expectRevert(Unauthorized(user, bytes32(bytes20(address(tDummy)))));
        tDummy.setValue(user, 1);

        prank(deployer);
        tAuth.grantRole(user, address(tDummy));
        vm.expectRevert(Unauthorized(deployer, Auth.toRole(address(tDummy))));
        tDummy.setValue(user, 1);

        prank(user);
        tDummy.setValue(user, 1);
        vm.expectRevert(Unauthorized(user, Auth.toRole(address(tAuth))));
        bytes memory data = abi.encodeCall(tDummy.setValue, (user, 10));
        tAuth.delegate(address(tDummy), data);

        prank(deployer);
        vm.expectRevert(Unauthorized(deployer, Auth.toRole(address(tDummy))));
        tAuth.delegate(address(tDummy), data);

        tAuth.grantRole(deployer, address(tDummy));
        tAuth.delegate(address(tDummy), data);
        tAuth.values(user).eq(10, "user-value");
    }

    function testRoleValidFrom() public {
        prank(operator);
        tAuth.setRoleValidFrom(Role.KEEPERS, block.timestamp + 1);
        tAuth.hasRole(keeper, Role.KEEPERS).no("keeper-keepers");
        tAuth.setRoleValidFrom(Role.KEEPERS, block.timestamp);
        tAuth.hasRole(keeper, Role.KEEPERS).yes("keeper-keepers");

        prank(deployer);
        tAuth.setRoleValidFrom(Auth.SUDO, block.timestamp + 1);
        tAuth.hasRole(deployer, Auth.SUDO).no("deployer-sudo");

        vm.expectRevert(RoleDisabled(Auth.SUDO));
        tAuth.setRoleValidFrom(Auth.SUDO, block.timestamp);
        skip(1);
        tAuth.hasRole(deployer, Auth.SUDO).yes("deployer-sudo");
    }

    function testDisabled() public {
        prank(deployer);
        tAuth.setRoleValidFrom(Role.OPERATOR, type(uint256).max);
        tAuth.setRoleValidFrom(Role.KEEPERS, type(uint256).max);
        tAuth.getRole(Role.OPERATOR).validFrom.eq(
            type(uint128).max,
            "op-disabled"
        );
        tAuth.getRole(Role.KEEPERS).validFrom.eq(
            type(uint128).max,
            "keep-disabled"
        );
        tAuth.grantRole(user, Role.KEEPERS);
        tAuth.revokeRole(user, Role.KEEPERS);
        tAuth.grantRole(user, Role.KEEPERS);
        vm.expectRevert(RoleDisabled(Role.KEEPERS));
        tAuth.transferRole(Role.KEEPERS, user, operator, block.timestamp - 1);

        tAuth.hasRole(user, Role.KEEPERS).no("user-keepers");

        vm.expectRevert(RoleDisabled(Role.OPERATOR));
        tAuth.setOperatorValue(2);

        prank(operator);
        vm.expectRevert(RoleDisabled(Role.OPERATOR));
        tAuth.setOperatorValue(1);
        vm.expectRevert(Unauthorized(operator, Auth.SUDO));
        tAuth.grantRole(user, Role.KEEPERS);

        vm.expectRevert(RoleDisabled(Role.OPERATOR));
        tAuth.transferRole(Role.OPERATOR, operator, user, block.timestamp);
        vm.expectRevert(RoleDisabled(Role.OPERATOR));
        tAuth.transferRole(Role.OPERATOR, operator, user, block.timestamp - 1);
        tAuth.revokeRole(operator, Role.OPERATOR);
        tAuth.hasRole(user, Role.OPERATOR).no("user-op");

        prank(deployer);

        tAuth.setRoleValidFrom(Role.KEEPERS, block.timestamp);
        tAuth.hasRole(user, Role.KEEPERS).yes("user-keepers");
        tAuth.hasRole(user, Role.OPERATOR).no("user-op");

        tAuth.getRole(Role.OPERATOR).count.eq(0, "op-count");
        tAuth.grantRole(user, Role.OPERATOR);

        tAuth.setRoleValidFrom(Role.OPERATOR, block.timestamp);
        tAuth.hasRole(user, Role.OPERATOR).yes("user-op");
    }
}

function RoleDisabled(bytes32 role) pure returns (bytes memory) {
    return abi.encodeWithSelector(Auth.RoleDisabled.selector, role);
}

function Locked(uint256 until, uint256 at) pure returns (bytes memory) {
    return abi.encodeWithSelector(Auth.Locked.selector, until, at);
}

function RoleFull(bytes32 role, uint256 max) pure returns (bytes memory) {
    return abi.encodeWithSelector(Auth.RoleFull.selector, role, max);
}

function Unauthorized(
    address sender,
    bytes32 role
) pure returns (bytes memory) {
    return abi.encodeWithSelector(Auth.Unauthorized.selector, sender, role);
}
