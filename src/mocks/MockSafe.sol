// SPDX-License-Identifier: MIT
// solhint-disable

pragma solidity ^0.8.0;

contract GnosisSafeL2Mock {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function setup(
        address[] memory _owners,
        uint256 _threshold,
        address _to,
        bytes memory _data,
        address _fallbackHandler,
        address _paymentToken,
        uint256 _payment
    ) public {}

    function isOwner(address who) external view returns (bool) {
        return who == owner;
    }

    function setOwner(address who) external {
        require(msg.sender == owner, "mso");
        owner = who;
    }

    function getOwners() external view returns (address[] memory) {
        address[] memory owners = new address[](6);
        owners[0] = address(owner);
        owners[1] = address(0x011);
        owners[2] = address(0x022);
        owners[3] = address(0x033);
        owners[4] = address(0x044);
        owners[5] = address(0x055);
        return owners;
    }
}

library LibSafe {
    address public constant USER1 = address(0x011);
    address public constant USER2 = address(0x022);
    address public constant USER3 = address(0x033);
    address public constant USER4 = address(0x044);

    function createSafe(address admin) internal returns (GnosisSafeL2Mock) {
        return new GnosisSafeL2Mock(admin);
    }
}
