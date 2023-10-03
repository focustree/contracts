use debug::PrintTrait;
use starknet::{
    ContractAddress,
    testing::{set_contract_address, set_caller_address, set_account_contract_address}
};
use openzeppelin::tests::utils::{constants::{OWNER, OTHER,}, deploy};
use focustree::account::{
    account::FocusAccount, interface::{FocusAccountABIDispatcher, FocusAccountABIDispatcherTrait}
};
use focustree::tests::mocks::toto::{Toto, ITotoDispatcher, ITotoDispatcherTrait};

const PUBLIC_KEY: felt252 = 'PUBLIC_KEY';

//
// Setup
//

fn deploy_account() -> FocusAccountABIDispatcher {
    let calldata: Array<felt252> = array![PUBLIC_KEY];
    let address: ContractAddress = deploy(FocusAccount::TEST_CLASS_HASH, calldata);
    set_contract_address(address); // Simulate executing tx from this account
    FocusAccountABIDispatcher { contract_address: address }
}

//
// Tests
//

#[test]
#[available_gas(2000000)]
fn test_new_selector_after_upgrade() {
    let v1 = deploy_account();

    v1.upgrade(Toto::TEST_CLASS_HASH.try_into().unwrap());
    let v2 = ITotoDispatcher { contract_address: v1.contract_address };

    assert(v2.toto() == 'toto', 'Not equal to \'toto\'');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Account: unauthorized', 'ENTRYPOINT_FAILED',))]
fn test_upgrade_from_not_account() {
    let v1 = deploy_account();

    let not_account_address: felt252 = v1.contract_address.into() + 1;
    set_contract_address(not_account_address.try_into().unwrap());

    v1.upgrade(Toto::TEST_CLASS_HASH.try_into().unwrap());
}
