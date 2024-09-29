import { type Hex } from 'viem';
import { fetchPythData } from './pyth/pyth-hermes';
import { error } from './shared';

if (process.argv.length < 3) {
	error(
		'Invalid arguments. Example: `bun run lib/kopio-lib/utils/ffi-pyth.ts ETH,BTC` or `bun run lib/kopio-lib/utils/ffi-pyth.ts 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace,0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43`'
	);
}

const items = process.argv[2]?.split(',') ?? [];
if (!items?.length) {
	error('You have to provide feeds as the third argument. Example: `bun run lib/kopio-lib/utils/ffi-pyth.ts ETH,BTC`');
}
try {
	const result = await fetchPythData(items, 'hex');
	success(result);
} catch (e: any) {
	error(e.message);
}

function out(str: Hex, err?: boolean): never {
	const exitCode = err ? 1 : 0;
	if (!str.length) {
		process.exit(exitCode);
	}

	process.stdout.write(str);
	process.exit(exitCode);
}

export function success(str: Hex): never {
	out(str);
}
