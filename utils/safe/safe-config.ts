if (!process.env.SAFE_ADDRESS) throw new Error('SAFE_ADDRESS not set')
if (!process.env.SAFE_CHAIN_ID) throw new Error('CHAIN_ID not set')

export const SAFE_API_V1 = {
  1: 'https://safe-transaction-mainnet.safe.global/api/v1',
  10: 'https://safe-transaction-optimism.safe.global/api/v1',
  56: 'https://safe-transaction-bsc.safe.global/api/v1',
  100: 'https://safe-transaction-gnosis-chain.safe.global/api/v1',
  137: 'https://safe-transaction-polygon.safe.global/api/v1',
  324: 'https://safe-transaction-zksync.safe.global/api/v1',
  1101: 'https://safe-transaction-zkevm.safe.global/api/v1',
  42161: 'https://safe-transaction-arbitrum.safe.global/api/v1',
  42220: 'https://safe-transaction-celo.safe.global/api/v1',
  11155111: 'https://safe-transaction-sepolia.safe.global/api/v1',
  1313161554: 'https://safe-transaction-aurora.safe.global/api/v1',
} as const

export const SAFE_ADDRESS = process.env.SAFE_ADDRESS
export const CHAIN_ID = process.env.SAFE_CHAIN_ID as unknown as keyof typeof SAFE_API_V1
export const SAFE_API = SAFE_API_V1[CHAIN_ID]
