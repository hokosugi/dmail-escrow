import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = Array<number>;
export type Address = string;
export interface Amount { 'icp' : bigint }
export type BlockIndex = bigint;
export interface Dmail {
  'getAddressBalance' : (arg_0: Address) => Promise<[] | [Amount]>,
  'getP' : () => Promise<Principal>,
  'myAccountId' : () => Promise<AccountIdentifier>,
  'register' : (arg_0: Address) => Promise<string>,
  'transerEachAddress' : (arg_0: Array<number>, arg_1: Address) => Promise<
      TransferResult
    >,
  'update' : (arg_0: Address, arg_1: bigint) => Promise<string>,
}
export interface Tokens { 'e8s' : bigint }
export type TransferError = {
    'TxTooOld' : { 'allowed_window_nanos' : bigint }
  } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'TxDuplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TxCreatedInFuture' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type TransferResult = { 'Ok' : null } |
  { 'Err' : TransferError };
export interface _SERVICE extends Dmail {}
