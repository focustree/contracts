use focustree::garden::tile::GardenTile;
use starknet::{
    ClassHash, ContractAddress, contract_address_const, get_caller_address,
    testing::{set_account_contract_address, set_contract_address, set_caller_address}
};
use openzeppelin::tests::utils::constants::{OWNER, OTHER};
use debug::PrintTrait;
use openzeppelin::access::ownable::ownable::Ownable;
use array::ArrayTrait;
use alexandria_ascii::ToAsciiArrayTrait;
use alexandria_data_structures::array_ext::ArrayTraitExt;

fn STATE() -> GardenTile::ContractState {
    GardenTile::contract_state_for_testing()
}

fn setup() -> GardenTile::ContractState {
    let mut state = STATE();
    set_contract_address(OTHER());
    let mut unsafe_ownable_state = Ownable::unsafe_new_contract_state();
    Ownable::InternalImpl::initializer(ref unsafe_ownable_state, OWNER());
    state
}

#[test]
#[available_gas(2000000)]
fn test_set_base_uri_when_owner() {
    let mut state = setup();
    set_caller_address(OWNER());
    let base_uri = 184555836509371486643729180464952852387281955161842107580111539754880492847;
    GardenTile::set_base_uri(ref state, base_uri);
    let res = GardenTile::get_base_uri(@state);
    assert(res == base_uri, 'Base Uri 1 not setted well');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_set_base_uri_when_not_owner() {
    let mut state = setup();
    set_caller_address(OTHER());
    let signer = 184555836509371486643729180464952852387281955161842107580111539754880492847;
    GardenTile::set_signer(ref state, signer);
}


#[test]
#[available_gas(2000000)]
fn test_token_uri_with_all_good() {
    let mut state = setup();
    set_caller_address(OWNER());
    let base_uri = 184555836509371486643729180464952852387281955161842107580111539754880492847;
    GardenTile::set_base_uri(ref state, base_uri);
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id = 14;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
    let tile_id_u256 = u256 { low: tile_id, high: 0 };
    let token_uri = GardenTile::token_uri(@state, tile_id_u256);
    let mut expected_token_uri: Array<felt252> = ArrayTrait::new();
    let ascii_array = tile_id_u256.low.to_ascii_array();
    let mut ascii_array_reverse = ascii_array.reverse();
    expected_token_uri.append(base_uri);
    expected_token_uri.append_all(ref ascii_array_reverse);
    assert(expected_token_uri == token_uri, 'Token Uri is wrong');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC721: invalid token ID',))]
fn test_token_uri_when_id_not_minted() {
    let mut state = setup();
    set_caller_address(OWNER());
    let base_uri = 184555836509371486643729180464952852387281955161842107580111539754880492847;
    GardenTile::set_base_uri(ref state, base_uri);
    let tile_id = 14;
    let tile_id_u256 = u256 { low: tile_id, high: 0 };
    let token_uri = GardenTile::token_uri(@state, tile_id_u256);
}
