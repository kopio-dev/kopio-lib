import { $ } from 'bun'
import * as path from 'node:path'
import type { Address, Hex } from 'viem'
import { existsSync, mkdirSync } from 'node:fs'

type AbiItem = {
	type: 'function' | 'event' | 'constructor' | 'fallback' | 'error' | 'receive'
	name: string
	inputs: any[]
	outputs: any[]
	stateMutability?: 'view' | 'pure' | 'nonpayable' | 'payable'
}

type Artifact = {
	abi: AbiItem[]
	bytecode: {
		object: Hex
		sourceMap: any
		linkReferences: any
	}
	deployedBytecode: {
		object: Hex
		sourceMap: any
		linkReferences: any
	}
	methodIdentifiers: {
		[name: string]: string
	}
}

const buildDir = path.join(process.cwd(), 'build')
const lib = path.join(process.cwd(), 'lib', 'kopio-lib', 'src', 'info')
const addresses = (await Bun.file(`${lib}/ArbDeployAddr.sol`).text())
	.split('\n')
	.filter(l => l.match(/.*?0x[0-9a-fA-F]{40}/g))
	.map(l =>
		l
			.replace('address constant', '')
			.replace(/['";]/g, '')
			.replace('Addr', '')
			.split('=')
			.map(s => s.trim()),
	)

const outfile = (name: string) => {
	const dir = path.join(process.cwd(), 'out', 'abi')
	if (!existsSync(dir)) mkdirSync(dir, { recursive: true })
	return path.join(dir, name)
}

const write = async (name: string, contents: string) => {
	const fileName = outfile(name)
	await Bun.write(fileName, contents)
	await $`prettier --write ${fileName} --no-semi`
}

const [names, addrIds] = process.argv.slice(2) as [string, string, AbiItem['type'][]]

const namesArr = names.split(',')
const addressIds = addrIds.split(',')
const files = Array.from(new Bun.Glob(`${buildDir}/*/{${names}}.json`).scanSync())

const allAddresses = {} as Record<string, Address>
const allErrorsEvents = [] as AbiItem[]

for (let i = 0; i < files.length; i++) {
	const file = files[i]
	console.log(file)
	console.log(namesArr)
	const name = namesArr.find(item => {
		return file.split('/').pop()!.includes(item)
	}) as string

	allAddresses[name] = addresses.find(([n]) => n === addressIds[i])?.[1] as Address

	const artifact = JSON.parse(await Bun.file(file).text()) as Artifact
	const functions = artifact.abi.filter(item => item.type === 'function')

	allErrorsEvents.push(...artifact.abi.filter(item => item.type === 'error' || item.type === 'event'))

	await write(
		`${name}.abi.ts`,
		`import { addr } from './addr'\n\nexport const ${name.toLowerCase()}Config = {\n  address: addr.${name},\n  abi: ${JSON.stringify(functions, null, 2)}} as const`,
	)
}

const uniqueErrorsEvents = allErrorsEvents.filter(
	(item, index, self) => self.findIndex(i => i.name === item.name && i.type === item.type) === index,
)
await write(
	'errors.abi.ts',
	`export const errorsAbi = ${JSON.stringify(
		uniqueErrorsEvents.filter(i => i.type === 'error'),
		null,
		2,
	)} as const`,
)
await write(
	'events.abi.ts',
	`export const eventsAbi = ${JSON.stringify(
		uniqueErrorsEvents.filter(i => i.type === 'event'),
		null,
		2,
	)} as const`,
)
await write('addr.ts', `export const addr = ${JSON.stringify(allAddresses, null, 2)} as const`)
