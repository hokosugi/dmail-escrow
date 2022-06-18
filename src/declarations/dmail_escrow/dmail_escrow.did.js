export const idlFactory = ({ IDL }) => {
  const Address = IDL.Text;
  const Amount = IDL.Record({ 'icp' : IDL.Nat64 });
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
  const Tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const BlockIndex = IDL.Nat64;
  const TransferError = IDL.Variant({
    'TxTooOld' : IDL.Record({ 'allowed_window_nanos' : IDL.Nat64 }),
    'BadFee' : IDL.Record({ 'expected_fee' : Tokens }),
    'TxDuplicate' : IDL.Record({ 'duplicate_of' : BlockIndex }),
    'TxCreatedInFuture' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Tokens }),
  });
  const TransferResult = IDL.Variant({
    'Ok' : IDL.Null,
    'Err' : TransferError,
  });
  const Dmail = IDL.Service({
    'getAddressBalance' : IDL.Func([Address], [IDL.Opt(Amount)], []),
    'getP' : IDL.Func([], [IDL.Principal], []),
    'myAccountId' : IDL.Func([], [AccountIdentifier], []),
    'register' : IDL.Func([Address], [IDL.Text], []),
    'transerEachAddress' : IDL.Func(
        [IDL.Vec(IDL.Nat8), Address],
        [TransferResult],
        [],
      ),
    'update' : IDL.Func([Address, IDL.Nat64], [IDL.Text], []),
  });
  return Dmail;
};
export const init = ({ IDL }) => { return [IDL.Text]; };
