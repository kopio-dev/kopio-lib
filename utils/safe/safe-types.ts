import { type Address, type Hex, parseAbiParameters } from 'viem'
import { CHAIN_ID, SAFE_ADDRESS } from './safe-config'
export const txPayloadOutput = parseAbiParameters([
  'Payloads result',
  'struct Payload { address to; uint256 value; bytes data; }',
  'struct PayloadExtra { string name; address contractAddr; string transactionType; string func; string funcSig; string[] args; address[] creations; uint256 gas; }',
  'struct Payloads { Payload[] payloads; PayloadExtra[] extras; uint256 txCount; uint256 creationCount; uint256 totalGas; uint256 safeNonce; string safeVersion; uint256 timestamp; uint256 chainId; }',
])

export const signPayloadInput = parseAbiParameters([
  'Batch batch',
  'struct Batch { address to; uint256 value; bytes data; uint8 operation; uint256 safeTxGas; uint256 baseGas; uint256 gasPrice; address gasToken; address refundReceiver; uint256 nonce; bytes32 txHash; bytes signature; }',
])

export const signatureOutput = parseAbiParameters(['string,bytes,address'])
export const proposeOutput = parseAbiParameters(['string,string'])
export const types = {
  EIP712Domain: [
    { name: 'verifyingContract', type: 'address' },
    { name: 'chainId', type: 'uint256' },
  ],
  SafeTx: [
    { name: 'to', type: 'address' },
    { name: 'value', type: 'uint256' },
    { name: 'data', type: 'bytes' },
    { name: 'operation', type: 'uint8' },
    { name: 'safeTxGas', type: 'uint256' },
    { name: 'baseGas', type: 'uint256' },
    { name: 'gasPrice', type: 'uint256' },
    { name: 'gasToken', type: 'address' },
    { name: 'refundReceiver', type: 'address' },
    { name: 'nonce', type: 'uint256' },
  ],
}

export const typedData = (safe: Address, message: any) => ({
  types,
  domain: {
    verifyingContract: safe,
    chainId: CHAIN_ID,
  },
  primaryType: 'SafeTx' as const,
  message: message,
})

export enum Signer {
  Trezor,
  Frame,
  Ledger,
}

export type Method = 'personal_sign' | 'eth_sign' | 'eth_signTypedData_v4'

export const deleteData = (txHash: Hex) => ({
  types: {
    EIP712Domain: [
      { name: 'name', type: 'string' },
      { name: 'version', type: 'string' },
      { name: 'chainId', type: 'uint256' },
      { name: 'verifyingContract', type: 'address' },
    ],
    DeleteRequest: [
      { name: 'safeTxHash', type: 'bytes32' },
      { name: 'totp', type: 'uint256' },
    ],
  },
  primaryType: 'DeleteRequest',
  domain: {
    name: 'Safe Transaction Service',
    version: '1.0',
    chainId: CHAIN_ID,
    verifyingContract: SAFE_ADDRESS,
  },
  message: {
    safeTxHash: txHash,
    totp: Math.floor(Date.now() / 1000 / 3600),
  },
})
export type SignResult = [signature: Hex, address: Address]
export type SafeInfoResponse = {
  address: Address
  nonce: number
  threshold: number
  owners: Address[]
  masterCopy: Address
  modules: Address[]
  fallbackHandler: Address
  guard: Address
  version: string
}
