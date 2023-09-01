use starknet::{ContractAddress};
use openzeppelin::tests::utils::{deploy};
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
