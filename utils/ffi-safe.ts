import type { Hex } from 'viem'
import { deleteBatch, getSafePayloads, proposeBatch, safeSign, signBatch } from './safe/safe'
import { signData, signHash, signMessage } from './safe/signers'
import { error, success } from './shared'

export const commands = {
	// -> getSafePayloads SCRIPT_DRY_BROADCAST_ID CHAIN_ID SAFE_ADDRESS
	getSafePayloads,
	// -> proposeBatch FILENAME
	proposeBatch,
	// -> signBatch SAFE_ADDRESS CHAIN_ID DATA
	signBatch,
	safeSign,
	signData,
	signHash,
	signMessage,
	deleteBatch,
}
export type Commands = keyof typeof commands
const command = process.argv[2] as Commands

if (!command) {
	error('No command provided')
}

if (command in commands) {
	try {
		let result = commands[command]()
		if (result instanceof Promise) {
			// @ts-expect-error
			result = await result
		}
		result ? success(result as unknown as string | Hex[] | Hex) : error(`No result for command ${command}`)
	} catch (e: unknown) {
		error(`${command} -> ${e}`)
	}
} else {
	error(`Unknown command: ${command}`)
}
