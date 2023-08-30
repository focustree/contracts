use starknet::ClassHash;
use starknet::ContractAddress;
use openzeppelin::tests::utils;
use focustree::garden_tile::GardenTile;
use focustree::garden_tile::IGardenTileDispatcher;
use focustree::garden_tile::IGardenTileDispatcherTrait;
use focustree::tests::mocks::toto::Toto;
use focustree::tests::mocks::toto::ITotoDispatcher;
use focustree::tests::mocks::toto::ITotoDispatcherTrait;

//
// Setup
//

fn deploy_garden_tile_v1() -> IGardenTileDispatcher {
    let calldata: Array<felt252> = array![];
    let address: ContractAddress = utils::deploy(GardenTile::TEST_CLASS_HASH, calldata);
    IGardenTileDispatcher { contract_address: address }
}

//
// Tests
//

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Class hash cannot be zero', 'ENTRYPOINT_FAILED',))]
fn test_upgrade_with_class_hash_zero() {
    let v1 = deploy_garden_tile_v1();
    v1.upgrade(Zeroable::zero());
}

#[test]
#[available_gas(2000000)]
fn test_new_selector_after_upgrade() {
    let v1 = deploy_garden_tile_v1();

    v1.upgrade(Toto::TEST_CLASS_HASH.try_into().unwrap());
    let v2 = ITotoDispatcher { contract_address: v1.contract_address };

    assert(v2.toto() == 'toto', 'Not equal to \'toto\'');
}
