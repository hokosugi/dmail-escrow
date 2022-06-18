import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";

import Ledger "canister:ledger";

import Account "./Account";
import L "./Ledger";


// 本来なら各アドレスにPrincipal IDを付けてそれぞれでトークン管理するのがよいが
// Principal IDを生成する方法がわからないので、1つの Principal IDですべてのアドレス
// を管理し、引き出しがあったときに"memo"に記載のアドレスで検索してICPを計算し送金する
actor class Dmail (principal_text: Text) {
  let p: Principal = Principal.fromText(principal_text);
  // addressはpublicにして外部canisterから読み取れるようにしておく
  public type Address = Text;
  public type Tokens = { e8s : Nat64 };
  public type Memo = Nat64;
  public type AccountIdentifier = Blob;
  public type SubAccount = Blob;
  public type TimeStamp = { timestamp_nanos : Nat64 };
  
  type Amount = {
    icp: Nat64;
  };
  let fee : Tokens = { e8s = 10_000 };
  public type TransferArgs = { 
    memo: Memo;
    amount: Tokens;
    fee: Tokens;
    from_subaccount: ?SubAccount;
    to: AccountIdentifier;
    created_at_time: ?TimeStamp; 
  };
  // hashMap upgrade対策は後ほど修正する
  let address_amount = Map.HashMap<Address, Amount>(0, Text.equal, Text.hash);

  // 登録
  public func register(address: Address): async Text { 
    switch (address_amount.get(address)){
        case(null) {
            let amount = init_amount();
            address_amount.put(address, amount);
            return "seccess";
        };
        case(_) {
            return "already registered";
        };
    };
    return "something wrong";
  };
  
  // amount update
  public func update(address: Address, icp: Nat64): async Text {
      let get_address = address_amount.get(address);
      switch(get_address){
          case(null) return "not register";
          case(?v){
              let amount_icp: Nat64 = v.icp + icp;
              let amount = make_amount(amount_icp);
              address_amount.put(address, amount);
              return "seccess";
          };
      };
      return "something wrong";
  };

  // 各アドレス毎の残高照会
  func addressBalance(address: Address): ?Amount {
    let balance = address_amount.get(address);
    return balance;
  };

  // init Amount
  func init_amount(): Amount {
      let amount = {
          icp: Nat64 = 0;
      };
      return amount;
  };

  // make amount increasing
  func make_amount(icp: Nat64): Amount {
      let amount = {
          icp = icp;
      };
      return amount;
  };

  public shared ({caller}) func getP(): async Principal {
    return caller;
  };
  // my account
  public func myAccountId() : async Account.AccountIdentifier {
    // Account.accountIdentifier(Principal.fromActor(Dmail), Account.defaultSubaccount())
    let myPrincipal = await getP();
    Account.accountIdentifier(myPrincipal, Account.defaultSubaccount());
  };

  // 送金先account
   func toSendAccountId() : Account.AccountIdentifier {
    Account.accountIdentifier(p, Account.defaultSubaccount())
  };
  // for 外部canister 
  // public query func canisterAccount() : async Account.AccountIdentifier {
  //   myAccountId()
  // };

  // canister全額を知る必要はなし
  // public func canisterBalance() : async Ledger.Tokens {
  //   await Ledger.account_balance({ account = myAccountId() })
  // };

  // canisterBalance()の代わりにアドレス毎の残高を取得する
  public func getAddressBalance(a: Address): async ?Amount {
    return address_amount.get(a);
  };

  // アドレス認証後に呼び出されるtransfer関数
  public func transerEachAddress(account_id: Blob, address: Address): async L.TransferResult {
    let balance = addressBalance(address);
    switch(balance){
      case(null) return #Err(#TxCreatedInFuture);
      case(?v){
          let metadata: TransferArgs = { 
            memo = 0;
            amount = { e8s = v.icp };
            fee = { e8s = 10_000 };
            from_subaccount = null;
            to = toSendAccountId();
            created_at_time = null 
          };
          let res = await Ledger.transfer(metadata);
          return #Ok;
      };
    };
  };
};
