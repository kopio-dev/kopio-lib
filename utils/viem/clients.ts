import { createPublicClient, createWalletClient, http } from 'viem'
import { mnemonicToAccount } from 'viem/accounts'
import { arbitrum, optimism } from 'viem/chains'

export const client = createPublicClient
export const arb = client({ chain: arbitrum, transport: http(process.env.RPC_ARBITRUM_ALCHEMY!) })
export const opt = client({ chain: optimism, transport: http(process.env.RPC_OPTIMISM_ALCHEMY!) })

export const wallet = createWalletClient({
	chain: arbitrum,
	transport: http(process.env.RPC_ARBITRUM_ALCHEMY!),
	account: mnemonicToAccount(process.env.MNEMONIC!),
})
