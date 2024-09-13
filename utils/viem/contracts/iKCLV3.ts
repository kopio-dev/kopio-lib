import { addr } from '.'

export const iKCLV3ABI = [
	{
		type: 'function',
		name: 'ETH_FEED',
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
		name: 'PRICE_DEC',
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
		name: 'RATIO_DEC',
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
		name: 'STALE_TIME',
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
		name: 'getAnswer',
		inputs: [
			{
				name: 'priceFeed',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Answer',
				components: [
					{
						name: 'answer',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getAnswer',
		inputs: [
			{
				name: 'priceFeed',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'expectedDec',
				type: 'uint8',
				internalType: 'uint8',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Answer',
				components: [
					{
						name: 'answer',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getAnswer',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Answer',
				components: [
					{
						name: 'answer',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getDerivedAnswer',
		inputs: [
			{
				name: 'priceFeeds',
				type: 'address[2]',
				internalType: 'address[2]',
			},
			{
				name: 'ratioFeeds',
				type: 'address[2]',
				internalType: 'address[2]',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Derived',
				components: [
					{
						name: 'price',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'ratio',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'underlyingPrice',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getDerivedAnswer',
		inputs: [
			{
				name: 'priceFeed',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'ratioFeed',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'priceDec',
				type: 'uint8',
				internalType: 'uint8',
			},
			{
				name: 'ratioDec',
				type: 'uint8',
				internalType: 'uint8',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Derived',
				components: [
					{
						name: 'price',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'ratio',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'underlyingPrice',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getDerivedAnswer',
		inputs: [
			{
				name: 'priceFeed',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'ratioFeed',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Derived',
				components: [
					{
						name: 'price',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'ratio',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'underlyingPrice',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getDerivedAnswer',
		inputs: [
			{
				name: 'ratioFeed',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Derived',
				components: [
					{
						name: 'price',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'ratio',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'underlyingPrice',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getRatio',
		inputs: [
			{
				name: 'ratioFeed',
				type: 'address',
				internalType: 'address',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Answer',
				components: [
					{
						name: 'answer',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'getRatio',
		inputs: [
			{
				name: 'ratioFeed',
				type: 'address',
				internalType: 'address',
			},
			{
				name: 'expectedDec',
				type: 'uint8',
				internalType: 'uint8',
			},
		],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct IKopioCLV3.Answer',
				components: [
					{
						name: 'answer',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'age',
						type: 'uint256',
						internalType: 'uint256',
					},
					{
						name: 'updatedAt',
						type: 'uint256',
						internalType: 'uint256',
					},
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'setDecimalConversions',
		inputs: [
			{
				name: '',
				type: 'bool',
				internalType: 'bool',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'error',
		name: 'InvalidAnswer',
		inputs: [
			{
				name: '',
				type: 'int256',
				internalType: 'int256',
			},
			{
				name: '',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
	},
	{
		type: 'error',
		name: 'InvalidDecimals',
		inputs: [
			{
				name: '',
				type: 'uint8',
				internalType: 'uint8',
			},
			{
				name: '',
				type: 'uint8',
				internalType: 'uint8',
			},
		],
	},
	{
		type: 'error',
		name: 'StalePrice',
		inputs: [
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

export const iKCLV3Config = {
	abi: iKCLV3ABI,
	addr: addr.CLV3,
}
