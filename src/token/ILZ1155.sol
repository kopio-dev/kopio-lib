// SPDX-License-Identifier: MIT
// solhint-disable

pragma solidity ^0.8.0;
import {IERC165} from "../vendor/IERC165.sol";

// node_modules/@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Interface of the ONFT Core standard
 */
interface IONFT1155CoreUpgradeable {
    event SendToChain(
        uint16 indexed _dstChainId,
        address indexed _from,
        bytes indexed _toAddress,
        uint _tokenId,
        uint _amount
    );
    event SendBatchToChain(
        uint16 indexed _dstChainId,
        address indexed _from,
        bytes indexed _toAddress,
        uint[] _tokenIds,
        uint[] _amounts
    );
    event ReceiveFromChain(
        uint16 indexed _srcChainId,
        bytes indexed _srcAddress,
        address indexed _toAddress,
        uint _tokenId,
        uint _amount
    );
    event ReceiveBatchFromChain(
        uint16 indexed _srcChainId,
        bytes indexed _srcAddress,
        address indexed _toAddress,
        uint[] _tokenIds,
        uint[] _amounts
    );

    // _from - address where tokens should be deducted from on behalf of
    // _dstChainId - L0 defined chain id to send tokens too
    // _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
    // _tokenId - token Id to transfer
    // _amount - amount of the tokens to transfer
    // _refundAddress - address on src that will receive refund for any overpayment of L0 fees
    // _zroPaymentAddress - if paying in zro, pass the address to use. using 0x0 indicates not paying fees in zro
    // _adapterParams - flexible bytes array to indicate messaging adapter services in L0
    function sendFrom(
        address _from,
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint _tokenId,
        uint _amount,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;

    // _from - address where tokens should be deducted from on behalf of
    // _dstChainId - L0 defined chain id to send tokens too
    // _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
    // _tokenIds - token Ids to transfer
    // _amounts - amounts of the tokens to transfer
    // _refundAddress - address on src that will receive refund for any overpayment of L0 fees
    // _zroPaymentAddress - if paying in zro, pass the address to use. using 0x0 indicates not paying fees in zro
    // _adapterParams - flexible bytes array to indicate messaging adapter services in L0
    function sendBatchFrom(
        address _from,
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint[] calldata _tokenIds,
        uint[] calldata _amounts,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external payable;

    // _dstChainId - L0 defined chain id to send tokens too
    // _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
    // _tokenId - token Id to transfer
    // _amount - amount of the tokens to transfer
    // _useZro - indicates to use zro to pay L0 fees
    // _adapterParams - flexible bytes array to indicate messaging adapter services in L0
    function estimateSendFee(
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint _tokenId,
        uint _amount,
        bool _useZro,
        bytes calldata _adapterParams
    ) external view returns (uint nativeFee, uint zroFee);

    // _dstChainId - L0 defined chain id to send tokens too
    // _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
    // _tokenIds - tokens Id to transfer
    // _amounts - amounts of the tokens to transfer
    // _useZro - indicates to use zro to pay L0 fees
    // _adapterParams - flexible bytes array to indicate messaging adapter services in L0
    function estimateSendBatchFee(
        uint16 _dstChainId,
        bytes calldata _toAddress,
        uint[] calldata _tokenIds,
        uint[] calldata _amounts,
        bool _useZro,
        bytes calldata _adapterParams
    ) external view returns (uint nativeFee, uint zroFee);
}

// node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(
        address account,
        uint256 id
    ) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(
        address account,
        address operator
    ) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// contracts/interfaces/ILZ1155.sol

library Roles {
    bytes32 public constant MINTER_ROLE = keccak256("kopio.roles.minter");
    bytes32 public constant OPERATOR_ROLE = keccak256("kopio.roles.operator");
}

interface ILZ1155 is
    IERC1155Upgradeable,
    IONFT1155CoreUpgradeable,
    IAccessControlUpgradeable
{
    function owner() external view returns (address);

    function contractURI() external view returns (string memory);

    function uri(uint256 _tokenId) external view returns (string memory);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _tokenUri,
        string memory _contractURI
    ) external;

    function afterInitialization(
        address _lzEndpoint,
        address _multisig,
        address _treasury,
        uint96 _feeNumerator
    ) external;

    function setupLZ(address _lzEndpoint) external;

    /**
     * @notice Allows Roles.MINTER_ROLE to mint tokens to a given address
     * @param _to address to mint the NFT to
     * @param _tokenId token id to mint
     * @param _amount amount to mint
     */
    function mint(address _to, uint256 _tokenId, uint256 _amount) external;

    /**
     * @notice Allows Roles.MINTER_ROLE to burn tokens from a given address
     * @param _from address to burn the NFT from
     * @param _id token id to burn
     * @param _amount amount to burn
     */
    function burn(address _from, uint256 _id, uint256 _amount) external;

    /* ------------------------------ Configuration ----------------------------- */

    /// @dev Allows admin to set tokenURI
    /// @param _newURI new uri to set
    function setURI(string calldata _newURI) external;

    /// @dev Allows admin to set the contract URI
    /// @param _contractURI new contract URI to set
    function setContractURI(string calldata _contractURI) external;

    /**
     * @notice Configures the royalties
     * @param _tokenId token id to set the royalty for
     * @param _receiver address of the royalty receiver
     * @param _feeNumerator feeNumerator of the royalty
     * @param _action 0 = reset, 1 = set default, 2 = set tokenId
     */
    function configureRoyalty(
        uint256 _tokenId,
        address _receiver,
        uint96 _feeNumerator,
        uint8 _action
    ) external;

    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    function changeOwner(address _owner) external;

    function storeGetByKey(
        uint256 _tokenId,
        address _account,
        bytes32 _key
    ) external view returns (bytes32[] memory);

    function storeGetByIndex(
        uint256 _tokenId,
        address _account,
        bytes32 _key,
        uint256 _idx
    ) external view returns (bytes32);

    function storeCreateValue(
        uint256 _tokenId,
        address _account,
        bytes32 _key,
        bytes32 _value
    ) external returns (bytes32);

    function storeAppendValue(
        uint256 _tokenId,
        address _account,
        bytes32 _key,
        bytes32 _value
    ) external returns (bytes32);

    function storeUpdateValue(
        uint256 _tokenId,
        address _account,
        bytes32 _key,
        bytes32 _value
    ) external returns (bytes32);

    function storeClearKey(
        uint256 _tokenId,
        address _account,
        bytes32 _key
    ) external returns (bool);

    function storeClearKeys(
        uint256 _tokenId,
        address _account,
        bytes32[] memory _keys
    ) external returns (bool);
}
