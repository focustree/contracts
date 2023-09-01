use starknet::{
    ClassHash, ContractAddress, contract_address_const, get_caller_address,
    testing::{set_account_contract_address, set_contract_address}
};
use openzeppelin::tests::utils::{constants::{OWNER}, deploy};
use focustree::garden::{
    tile::GardenTile, interface::{GardenTileABIDispatcher, GardenTileABIDispatcherTrait}
};
use focustree::tests::mocks::toto::{Toto, ITotoDispatcher, ITotoDispatcherTrait};
use debug::PrintTrait;

//
// Setup
//

fn deploy_garden_tile() -> GardenTileABIDispatcher {
    set_contract_address(OWNER());
    let calldata: Array<felt252> = array![];
    let address: ContractAddress = deploy(GardenTile::TEST_CLASS_HASH, calldata);
    GardenTileABIDispatcher { contract_address: address }
}

//
// Tests
//

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Class hash cannot be zero', 'ENTRYPOINT_FAILED',))]
fn test_upgrade_with_class_hash_zero() {
    let v1 = deploy_garden_tile();
    v1.upgrade(Zeroable::zero());
}

#[test]
#[available_gas(2000000)]
fn test_new_selector_after_upgrade() {
    let v1 = deploy_garden_tile();

    v1.upgrade(Toto::TEST_CLASS_HASH.try_into().unwrap());
    let v2 = ITotoDispatcher { contract_address: v1.contract_address };

    assert(v2.toto() == 'toto', 'Not equal to \'toto\'');
}
