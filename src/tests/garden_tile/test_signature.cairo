use focustree::garden_tile::GardenTile;
use starknet::{
    ClassHash, ContractAddress, contract_address_const, get_caller_address,
    testing::{set_account_contract_address, set_contract_address, set_caller_address}
};
use openzeppelin::tests::utils::constants::{OWNER, OTHER};
use debug::PrintTrait;
use openzeppelin::access::ownable::ownable::Ownable;

fn STATE() -> GardenTile::ContractState {
    GardenTile::contract_state_for_testing()
}

fn setup() -> GardenTile::ContractState {
    let mut state = STATE();
    let mut unsafe_ownable_state = Ownable::unsafe_new_contract_state();
    Ownable::InternalImpl::initializer(ref unsafe_ownable_state, OWNER());
    state
}

#[test]
#[available_gas(2000000)]
fn test_set_signer_when_owner() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let res = GardenTile::get_signer(@state);
    assert(res==signer , 'Signer not setted well');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_set_signer_when_not_owner() {
    let mut state = setup();
    set_caller_address(OTHER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
}

