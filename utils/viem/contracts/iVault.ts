import { addr } from '.'

export const iVaultABI = [
  {
    type: 'function',
    name: 'acceptGovernance',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'addAsset',
    inputs: [
      {
        name: 'assetConfig',
        type: 'tuple',
        internalType: 'struct VaultAsset',
        components: [
          {
            name: 'token',
            type: 'address',
            internalType: 'contract IERC20',
          },
          {
            name: 'feed',
            type: 'address',
            internalType: 'contract IAggregatorV3',
          },
          {
            name: 'staleTime',
            type: 'uint24',
            internalType: 'uint24',
          },
          {
            name: 'decimals',
            type: 'uint8',
            internalType: 'uint8',
          },
          {
            name: 'depositFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'withdrawFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'maxDeposits',
            type: 'uint248',
            internalType: 'uint248',
          },
          {
            name: 'enabled',
            type: 'bool',
            internalType: 'bool',
          },
        ],
      },
    ],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct VaultAsset',
        components: [
          {
            name: 'token',
            type: 'address',
            internalType: 'contract IERC20',
          },
          {
            name: 'feed',
            type: 'address',
            internalType: 'contract IAggregatorV3',
          },
          {
            name: 'staleTime',
            type: 'uint24',
            internalType: 'uint24',
          },
          {
            name: 'decimals',
            type: 'uint8',
            internalType: 'uint8',
          },
          {
            name: 'depositFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'withdrawFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'maxDeposits',
            type: 'uint248',
            internalType: 'uint248',
          },
          {
            name: 'enabled',
            type: 'bool',
            internalType: 'bool',
          },
        ],
      },
    ],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'allAssets',
    inputs: [],
    outputs: [
      {
        name: 'assets',
        type: 'tuple[]',
        internalType: 'struct VaultAsset[]',
        components: [
          {
            name: 'token',
            type: 'address',
            internalType: 'contract IERC20',
          },
          {
            name: 'feed',
            type: 'address',
            internalType: 'contract IAggregatorV3',
          },
          {
            name: 'staleTime',
            type: 'uint24',
            internalType: 'uint24',
          },
          {
            name: 'decimals',
            type: 'uint8',
            internalType: 'uint8',
          },
          {
            name: 'depositFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'withdrawFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'maxDeposits',
            type: 'uint248',
            internalType: 'uint248',
          },
          {
            name: 'enabled',
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
    name: 'assetList',
    inputs: [
      {
        name: 'index',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    outputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'assetPrice',
    inputs: [
      {
        name: 'assetAddr',
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
    name: 'assets',
    inputs: [
      {
        name: '',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [
      {
        name: 'asset',
        type: 'tuple',
        internalType: 'struct VaultAsset',
        components: [
          {
            name: 'token',
            type: 'address',
            internalType: 'contract IERC20',
          },
          {
            name: 'feed',
            type: 'address',
            internalType: 'contract IAggregatorV3',
          },
          {
            name: 'staleTime',
            type: 'uint24',
            internalType: 'uint24',
          },
          {
            name: 'decimals',
            type: 'uint8',
            internalType: 'uint8',
          },
          {
            name: 'depositFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'withdrawFee',
            type: 'uint32',
            internalType: 'uint32',
          },
          {
            name: 'maxDeposits',
            type: 'uint248',
            internalType: 'uint248',
          },
          {
            name: 'enabled',
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
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'assetsIn',
        type: 'uint256',
        internalType: 'uint256',
      },
      {
        name: 'receiver',
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
    name: 'getConfig',
    inputs: [],
    outputs: [
      {
        name: 'config',
        type: 'tuple',
        internalType: 'struct VaultConfiguration',
        components: [
          {
            name: 'sequencerUptimeFeed',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'sequencerGracePeriodTime',
            type: 'uint96',
            internalType: 'uint96',
          },
          {
            name: 'governance',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'pendingGovernance',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'feeRecipient',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'oracleDecimals',
            type: 'uint8',
            internalType: 'uint8',
          },
        ],
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'maxDeposit',
    inputs: [
      {
        name: 'assetAddr',
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
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'maxMint',
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
        name: 'sharesOut',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    stateMutability: 'view',
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
        name: 'sharesIn',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'maxWithdraw',
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
        name: 'amountOut',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'mint',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'sharesOut',
        type: 'uint256',
        internalType: 'uint256',
      },
      {
        name: 'receiver',
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
    name: 'previewDeposit',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'assetsIn',
        type: 'uint256',
        internalType: 'uint256',
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
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'previewMint',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'sharesOut',
        type: 'uint256',
        internalType: 'uint256',
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
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'previewRedeem',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'sharesIn',
        type: 'uint256',
        internalType: 'uint256',
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
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'previewWithdraw',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'assetsOut',
        type: 'uint256',
        internalType: 'uint256',
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
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'redeem',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'sharesIn',
        type: 'uint256',
        internalType: 'uint256',
      },
      {
        name: 'receiver',
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
    name: 'removeAsset',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setAssetEnabled',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'isEnabled',
        type: 'bool',
        internalType: 'bool',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setAssetFeed',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'feedAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'newStaleTime',
        type: 'uint24',
        internalType: 'uint24',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setDepositFee',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'newDepositFee',
        type: 'uint16',
        internalType: 'uint16',
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
        name: 'newFeeRecipient',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setFeedPricePrecision',
    inputs: [
      {
        name: 'newDecimals',
        type: 'uint8',
        internalType: 'uint8',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setGovernance',
    inputs: [
      {
        name: 'newGovernance',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setMaxDeposits',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'newMaxDeposits',
        type: 'uint248',
        internalType: 'uint248',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setWithdrawFee',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'newWithdrawFee',
        type: 'uint16',
        internalType: 'uint16',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
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
    name: 'totalAssets',
    inputs: [],
    outputs: [
      {
        name: 'result',
        type: 'uint256',
        internalType: 'uint256',
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
    name: 'withdraw',
    inputs: [
      {
        name: 'assetAddr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'assetsOut',
        type: 'uint256',
        internalType: 'uint256',
      },
      {
        name: 'receiver',
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
] as const
export const iVaultConfig = {
  abi: iVaultABI,
  addr: addr.Vault,
}
