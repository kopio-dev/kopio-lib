import { existsSync, mkdirSync, writeFileSync } from 'node:fs'
import { glob } from 'glob'
import {
  type Address,
  type Hex,
  checksumAddress,
  decodeAbiParameters,
  encodeAbiParameters,
  toFunctionSelector,
  zeroAddress,
} from 'viem'
import { broadcastLocation, getArg, signaturesPath } from '../shared'
import type { BroadcastJSON } from '../types'
import { SAFE_API } from './safe-config'
import {
  type SafeInfoResponse,
  deleteData,
  proposeOutput,
  signPayloadInput,
  signatureOutput,
  txPayloadOutput,
  typedData,
} from './safe-types'
import { signData, signHash } from './signers'

export async function getSafePayloads() {
  const name = process.argv[3]
  const chainId = process.argv[4]
  const safeAddr = process.argv[5] as Address
  const nonce = process.argv[6] as string | undefined
  const payloads = await parseBroadcast(name, Number(chainId), safeAddr, nonce ? Number(nonce) : undefined)

  if (!payloads.length) {
    throw new Error(`No payloads found for ${name} on chain ${chainId}`)
  }
  return payloads
}

export async function signBatch() {
  const timestamp = Math.floor(Date.now() / 1000)

  const safe = process.argv[3] as Address
  const chainId = process.argv[4]
  const data = process.argv[5] as Hex
  if (!existsSync(signaturesPath)) mkdirSync(signaturesPath, { recursive: true })

  const file = (suffix: string) => `${signaturesPath}${timestamp}-${chainId}-${suffix}.json`

  const [decoded] = decodeAbiParameters(signPayloadInput, data)
  const typed = typedData(safe, {
    to: decoded.to,
    value: Number(decoded.value),
    data: decoded.data,
    operation: Number(decoded.operation),
    safeTxGas: Number(decoded.safeTxGas),
    baseGas: Number(decoded.baseGas),
    gasPrice: Number(decoded.gasPrice),
    gasToken: decoded.gasToken,
    refundReceiver: decoded.refundReceiver,
    nonce: Number(decoded.nonce),
  })

  const [signature, signer] = await safeSign(decoded.txHash)
  const fileName = file('signed-batch')
  writeFileSync(
    fileName,
    JSON.stringify({
      ...typed.message,
      safe,
      sender: signer,
      signature,
      contractTransactionHash: decoded.txHash,
    }),
  )

  return encodeAbiParameters(signatureOutput, [fileName, signature, signer])
}

export async function proposeBatch(filename?: string) {
  const isCLI = process.argv[4] != null
  const file = getArg(filename)
  const results = !file.startsWith(process.cwd()) ? glob.sync(`${signaturesPath}${file}.json`) : [file]

  if (!results.length) {
    if (isCLI) {
      console.error(`No batch found with ${file}. Did you sign it?`)
    } else {
      throw new Error(`No batch found with ${file}. Did you simulate it?`)
    }
  }

  if (results.length !== 1) {
    const err = `Expected 1 file, got ${results.length} for ${file}. Ensure the function executed is unique.`
    if (isCLI) return err
    throw new Error(err)
  }

  const tx = require(results[0])

  const response = await fetch(`${SAFE_API}/safes/${checksumAddress(tx.safe)}/multisig-transactions/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(tx),
  })
  const json = await response.json()

  if (isCLI) return tx.contractTransactionHash as Hex
  return encodeAbiParameters(proposeOutput, [`${response.status}: ${response.statusText}`, json])
}

export async function deleteBatch(txHash?: Hex) {
  const safeTxHash = getArg(txHash)
  const [signature] = await signData(deleteData(safeTxHash))
  const response = await fetch(`${SAFE_API}/multisig-transactions/${safeTxHash}/`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ signature, safeTxHash }),
  })
  if (!response.ok) throw new Error(await response.text())
  return response.statusText
}

export async function safeSign(txHash?: Hex): Promise<[Hex, Address]> {
  const [signature, signer] = await signHash(txHash)
  const v1 = parseInt(signature.slice(-2), 16) + 4
  return [`${signature.slice(0, -2)}${v1.toString(16)}` as Hex, signer]
}

async function parseBroadcast(name: string, chainId: number, safeAddr: Address, nonce?: number) {
  const files = glob.sync(`${broadcastLocation}/*/${chainId}/dry-run/${name}-latest.json`)

  if (!files.length) {
    throw new Error(`No transactions found with ${name}(). Did you forget to broadcast?`)
  }
  if (files.length > 1)
    throw new Error(
      `Expected 1 file, got ${files.length}. Did you execute multiple different script with function ${name}()?`,
    )
  const data: BroadcastJSON = require(files[0])

  const transactions = data.transactions.filter(tx => tx.transaction.from.toLowerCase() === safeAddr.toLowerCase())
  if (!transactions.length) {
    throw new Error(
      `No transactions found in ${name}() execution. Did you forget to broadcast with SAFE_ADDRESS? (SAFE_ADDRESS: ${safeAddr}, chainId: ${chainId})`,
    )
  }

  const safeInfo: SafeInfoResponse = await fetch(`${SAFE_API}/safes/${checksumAddress(safeAddr)}`).then(res =>
    res.json(),
  )

  const result = transactions.map(tx => {
    const to = tx.transaction.to
    const value = tx.transaction.value
    const gas = tx.transaction.gas
    const data = tx.transaction.input
    return {
      payload: {
        to: checksumAddress(to ?? zeroAddress),
        value: BigInt(value),
        data,
      },
      payloadInfo: {
        name,
        transactionType: tx.transactionType,
        contractAddr: checksumAddress(tx.contractAddress ?? zeroAddress),
        func: tx.function ?? '',
        funcSig: tx.function ? toFunctionSelector(tx.function) : '0x',
        args: tx.arguments ?? [],
        creations: tx.additionalContracts.map(c => checksumAddress(c.address)),
        gas: BigInt(gas),
      },
    }
  })

  const metadata = {
    payloads: result.map(r => r.payload),
    extras: result.map(r => r.payloadInfo),
    txCount: BigInt(transactions.length),
    creationCount: BigInt(transactions.reduce((res, tx) => res + tx.additionalContracts.length, 0)),
    totalGas: BigInt(transactions.reduce((res, tx) => res + Number(tx.transaction.gas), 0)),
    safeNonce: BigInt(nonce ? nonce : safeInfo.nonce),
    safeVersion: safeInfo.version,
    timestamp: BigInt(data.timestamp),
    chainId: BigInt(data.chain),
  }
  return encodeAbiParameters(txPayloadOutput, [metadata])
}
