import { encodeAbiParameters, parseAbiParameter } from 'viem'
import type { SuccessOutput } from './types'

export const getPath = (path: string) => `${process.cwd()}${path}`
export const broadcastLocation = getPath('/**/broadcast')
export const signaturesPath = getPath('/temp/sign/')

export const getArg = <T>(arg?: T) => {
	if (!arg) arg = process.argv[3] as T
	if (!arg) throw new Error('No argument provided')
	return arg
}

function out(str: SuccessOutput, err?: boolean): never {
	const exitCode = err ? 1 : 0
	if (!str.length) {
		process.exit(exitCode)
	}

	if (Array.isArray(str)) {
		process.stdout.write(str.join('\n'))
	} else {
		process.stdout.write(str)
	}

	process.exit(exitCode)
}

export function success(str: SuccessOutput): never {
	out(str)
}

export function error(str: string): never {
	out(encodeAbiParameters([parseAbiParameter('string')], [`(ffi) ${str}`]), true)
}

export const fetchJSON = async <T = any>(input: RequestInfo | URL, init?: RequestInit | undefined): Promise<T> => {
	try {
		const response = await fetch(input, init)
		return (await response.json()) as T
	} catch (e: any) {
		throw new Error(e.message)
	}
}
