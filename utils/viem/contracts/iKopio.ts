import { addr } from '.'

export const iKopioABI = [
	{
		type: 'function',
		name: 'DOMAIN_SEPARATOR',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'bytes32',
				internalType: 'bytes32',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'allowance',
		inputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'approve',
		inputs: [
			{
				name: 'spender',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'balanceOf',
		inputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'burn',
		inputs: [
			{
				name: 'from',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'decimals',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'uint8',
				internalType: 'uint8',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'enableNative',
		inputs: [
			{
				name: 'enabled',
				type: 'bool',
				internalType: 'bool',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'getRoleAdmin',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
		],
		outputs: [
			{
				name: '',
				type: 'bytes32',
				internalType: 'bytes32',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getRoleMember',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
			{
				name: 'index',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getRoleMemberCount',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
		],
		outputs: [
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'grantRole',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
			{
				name: 'account',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'hasRole',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
			{
				name: 'account',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'isRebased',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'mint',
		inputs: [
			{
				name: 'to',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'name',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'string',
				internalType: 'string',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'nonces',
		inputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'pause',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'permit',
		inputs: [
			{
				name: 'owner',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'spender',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'value',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'deadline',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'v',
				type: 'uint8',
				internalType: 'uint8',
			},
			{
				name: 'r',
				type: 'bytes32',
				internalType: 'bytes32',
			},
			{
				name: 's',
				type: 'bytes32',
				internalType: 'bytes32',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'protocol',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'rebase',
		inputs: [
			{
				name: 'denominator',
				type: 'uint248',
				internalType: 'uint248',
			},
			{
				name: 'positive',
				type: 'bool',
				internalType: 'bool',
			},
			{
				name: 'afterRebase',
				type: 'bytes',
				internalType: 'bytes',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'rebaseInfo',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopio.Rebase',
				components: [
					{
						name: 'denominator',
						type: 'uint248',
						internalType: 'uint248',
					},
					{
						name: 'positive',
						type: 'bool',
						internalType: 'bool',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'reinitializeERC20',
		inputs: [
			{
				name: '_name',
				type: 'string',
				internalType: 'string',
			},
			{
				name: '_symbol',
				type: 'string',
				internalType: 'string',
			},
			{
				name: '_version',
				type: 'uint8',
				internalType: 'uint8',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'renounceRole',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
			{
				name: 'callerConfirmation',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'revokeRole',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				internalType: 'bytes32',
			},
			{
				name: 'account',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'setCloseFee',
		inputs: [
			{
				name: 'newCloseFee',
				type: 'uint40',
				internalType: 'uint40',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'setFeeRecipient',
		inputs: [
			{
				name: 'newRecipient',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'setOpenFee',
		inputs: [
			{
				name: 'newOpenFee',
				type: 'uint48',
				internalType: 'uint48',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'setShare',
		inputs: [
			{
				name: 'addr',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'setUnderlying',
		inputs: [
			{
				name: 'underlyingAddr',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'share',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'supportsInterface',
		inputs: [
			{
				name: 'interfaceId',
				type: 'bytes4',
				internalType: 'bytes4',
			},
		],
		outputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'symbol',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'string',
				internalType: 'string',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'totalSupply',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'transfer',
		inputs: [
			{
				name: 'to',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'transferFrom',
		inputs: [
			{
				name: 'from',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'to',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'unpause',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'unwrap',
		inputs: [
			{
				name: 'to',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'toNative',
				type: 'bool',
				internalType: 'bool',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'wrap',
		inputs: [
			{
				name: 'to',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'wraps',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopio.Wraps',
				components: [
					{
						name: 'underlying',
						type: 'address',
						internalType: 'address',
					},
					{
						name: 'underlyingDec',
						type: 'uint8',
						internalType: 'uint8',
					},
					{
						name: 'openFee',
						type: 'uint48',
						internalType: 'uint48',
					},
					{
						name: 'closeFee',
						type: 'uint40',
						internalType: 'uint40',
					},
					{
						name: 'native',
						type: 'bool',
						internalType: 'bool',
					},
					{
						name: 'feeRecipient',
						type: 'address',
						internalType: 'address payable',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'event',
		name: 'Approval',
		inputs: [
			{
				name: 'owner',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'spender',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'RoleAdminChanged',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				indexed: true,
				internalType: 'bytes32',
			},
			{
				name: 'previousAdminRole',
				type: 'bytes32',
				indexed: true,
				internalType: 'bytes32',
			},
			{
				name: 'newAdminRole',
				type: 'bytes32',
				indexed: true,
				internalType: 'bytes32',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'RoleGranted',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				indexed: true,
				internalType: 'bytes32',
			},
			{
				name: 'account',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'sender',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'RoleRevoked',
		inputs: [
			{
				name: 'role',
				type: 'bytes32',
				indexed: true,
				internalType: 'bytes32',
			},
			{
				name: 'account',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'sender',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Transfer',
		inputs: [
			{
				name: 'from',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'to',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Unwrap',
		inputs: [
			{
				name: 'asset',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'underlying',
				type: 'address',
				indexed: false,
				internalType: 'address',
			},
			{
				name: 'to',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
		],
		anonymous: false,
	},
	{
		type: 'event',
		name: 'Wrap',
		inputs: [
			{
				name: 'asset',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'underlying',
				type: 'address',
				indexed: false,
				internalType: 'address',
			},
			{
				name: 'to',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: 'amount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
		],
		anonymous: false,
	},
	{
		type: 'error',
		name: 'AccessControlBadConfirmation',
		inputs: [],
	},
	{
		type: 'error',
		name: 'AccessControlUnauthorizedAccount',
		inputs: [
			{
				name: 'account',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'neededRole',
				type: 'bytes32',
				internalType: 'bytes32',
			},
		],
	},
	{
		type: 'error',
		name: 'INVALID_SIGNER',
		inputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
		],
	},
	{
		type: 'error',
		name: 'PERMIT_DEADLINE_EXPIRED',
		inputs: [
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
	},
] as const

export const kopioConfig = (symbol: keyof typeof addr) => {
	return {
		abi: iKopioABI,
		addr: addr[symbol],
	}
}
