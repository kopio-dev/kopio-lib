import { parseAbiParameters } from 'abitype'
import { type Hex, encodeAbiParameters } from 'viem'
import { error } from '../shared'
import { HERMES_URLS, tickers } from './pyth-config'
import { type Pyth, formatPrice, isPythID, isPythTicker } from './pyth-types'

export const hermes = {
	pricesV2: (ids: Pyth.ID[]) =>
		fetchHermes<Pyth.V2Response>(`/v2/updates/price/latest?ids[]=${ids.join('&ids[]=')}&binary=true`),
	sse: (ids: Pyth.ID[], idx = 1) => `${HERMES_URLS[idx]}/v2/updates/price/stream?ids[]=${ids.join('&ids[]=')}`,
}

export async function fetchPythData(): Promise<Hex>
export async function fetchPythData(items?: string[], out?: 'hex'): Promise<Hex>
export async function fetchPythData(items?: string[], out?: 'ts'): Promise<Result<typeof parseResult>>
export async function fetchPythData(items?: string[], out?: string): Promise<Result<typeof parseResult> | Hex> {
	items = items ?? process.argv[3]?.split(',') ?? []
	const pythIds = items
		.map(item => {
			return isPythTicker(item) ? tickers[item] : item
		})
		.filter(isPythID)

	if (!pythIds.length) {
		error(`No valid Pyth IDs found: ${items.join(', ')}`)
	}

	const result = parseResult(await hermes.pricesV2(pythIds))

	if (out === 'hex') return encodeAbiParameters(pythPayloads, [result.payload, result.pythAssets])
	return result
}

function parseResult(result: Pyth.V2Response) {
	const payload = result.binary.data.map<Hex>(d => `0x${d}`)
	const pythAssets = result.parsed.map(({ id, price, ema_price }) => ({
		id: `0x${id}` as const,
		price: formatPrice(price),
		emaPrice: formatPrice(ema_price),
	}))
	const view = {
		ids: pythAssets.map(a => a.id),
		prices: pythAssets.map(a => a.price),
	}
	return { pythAssets, payload, view }
}

export const pythPayloads = parseAbiParameters([
	'bytes[] payload, PriceFeed[] assets',
	'struct PriceFeed { bytes32 id; Price price; Price emaPrice; }',
	'struct Price { int64 price; uint64 conf; int32 expo; uint256 publishTime; }',
])

async function fetchHermes<T = any>(endpoint: string, init?: RequestInit) {
	for (const baseUrl of HERMES_URLS) {
		try {
			const response = await fetch(baseUrl + endpoint, init)
			return (await response.json()) as T
		} catch (e: any) {
			console.info('Failed to fetch from: ', baseUrl + endpoint, 'Error:', e)
		}
	}
	throw new Error(`Failed to fetch from all ${HERMES_URLS.length} endpoints`)
}
