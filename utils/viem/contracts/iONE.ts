import { addr } from '.'

export const iONEABI = [
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
		name: 'convertManyToAssets',
		inputs: [
			{
				name: 'shares',
				type: 'uint256[]',
				internalType: 'uint256[]',
			},
		],
		outputs: [
			{
				name: 'assets',
				type: 'uint256[]',
				internalType: 'uint256[]',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'convertManyToShares',
		inputs: [
			{
				name: 'assets',
				type: 'uint256[]',
				internalType: 'uint256[]',
			},
		],
		outputs: [
			{
				name: 'shares',
				type: 'uint256[]',
				internalType: 'uint256[]',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'convertToAssets',
		inputs: [
			{
				name: 'shares',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [
			{
				name: 'assets',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'convertToShares',
		inputs: [
			{
				name: 'assets',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [
			{
				name: 'shares',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
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
		name: 'deposit',
		inputs: [
			{
				name: '_shares',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '_receiver',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'destroy',
		inputs: [
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'from',
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
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'exchangeRate',
		inputs: [],
		outputs: [
			{
				name: 'rate',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'issue',
		inputs: [
			{
				name: 'amount',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'to',
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
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'maxRedeem',
		inputs: [
			{
				name: 'assetAddr',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'owner',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: 'max',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'fee',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'view',
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
		name: 'onVaultFlash',
		inputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IVaultFlash.Flash',
				components: [
					{
						name: 'asset',
						type: 'address',
						internalType: 'address',
					},
					{
						name: 'assets',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'shares',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'receiver',
						type: 'address',
						internalType: 'address',
					},
					{
						name: 'kind',
						type: 'uint8',
						internalType: 'enum IVaultFlash.FlashKind',
					},
				],
			},
			{
				name: '',
				type: 'bytes',
				internalType: 'bytes',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
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
		name: 'vault',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'contract IVault',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'vaultDeposit',
		inputs: [
			{
				name: '_assetAddr',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_assets',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '_receiver',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: 'sharesOut',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'assetFee',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'vaultMint',
		inputs: [
			{
				name: '_assetAddr',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_shares',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '_receiver',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: 'assetsIn',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'assetFee',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'vaultRedeem',
		inputs: [
			{
				name: '_assetAddr',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_shares',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '_receiver',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_owner',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: 'assetsOut',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'assetFee',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'vaultWithdraw',
		inputs: [
			{
				name: '_assetAddr',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_assets',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '_receiver',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_owner',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: 'sharesIn',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'assetFee',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'withdraw',
		inputs: [
			{
				name: '_amount',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: '_receiver',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'withdrawFrom',
		inputs: [
			{
				name: '_from',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_to',
				type: 'address',
				internalType: 'address',
			},
			{
				name: '_amount',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
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
		name: 'Deposit',
		inputs: [
			{
				name: '_from',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: '_to',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: '_amount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
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
		name: 'Withdraw',
		inputs: [
			{
				name: '_from',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: '_to',
				type: 'address',
				indexed: true,
				internalType: 'address',
			},
			{
				name: '_amount',
				type: 'uint256',
				indexed: false,
				internalType: 'uint256',
			},
		],
		anonymous: false,
	},
	{
		type: 'error',
		name: 'FLASH_KIND_NOT_SUPPORTED',
		inputs: [
			{
				name: '',
				type: 'uint8',
				internalType: 'enum IVaultFlash.FlashKind',
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

export const iONEConfig = {
	abi: iONEABI,
	addr: addr.ONE,
}
