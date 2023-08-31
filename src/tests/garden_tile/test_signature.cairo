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
    set_contract_address(OTHER());
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
    assert(res == signer, 'Signer not setted well');
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

#[test]
#[available_gas(2000000)]
fn test_message_hash() {
    let mut state = setup();
    set_caller_address(OWNER());
    set_contract_address(OTHER());
    let tile_id: u128 = 14;
    let expected_hash = 0x5b57062e4d01cbfd0d25d6d4d9e933c265fadc5eda16ed17b8600e0a1ba27b3;
    let message_hash = GardenTile::message_hash(tile_id);
    assert(expected_hash == message_hash, 'Hash is not correct');
}

#[test]
#[available_gas(2000000)]
fn test_verify_signature_with_all_good() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id: u128 = 14;
    let message_hash = 0x5b57062e4d01cbfd0d25d6d4d9e933c265fadc5eda16ed17b8600e0a1ba27b3;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    let is_signature_valid = GardenTile::verify_signature(
        ref state, message_hash, signature_r, signature_s
    );
    assert(is_signature_valid == true, 'Signature is not valid');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Signature is not valid',))]
fn test_verify_signature_with_wrong_message_hash() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let message_hash = 0x5b57062e4d01cbfd0d25d6d4d9e933c265fadc5eda16ed17b8600e0a1ba27b3 + 1;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    let is_signature_valid = GardenTile::verify_signature(
        ref state, message_hash, signature_r, signature_s
    );
    assert(is_signature_valid == true, 'Signature is not valid');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Signature is not valid',))]
fn test_verify_signature_with_wrong_signature_r() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let message_hash = 0x5b57062e4d01cbfd0d25d6d4d9e933c265fadc5eda16ed17b8600e0a1ba27b3;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837 + 1;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    let is_signature_valid = GardenTile::verify_signature(
        ref state, message_hash, signature_r, signature_s
    );
    assert(is_signature_valid == true, 'Signature is not valid');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Signature is not valid',))]
fn test_verify_signature_with_wrong_signature_s() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let message_hash = 0x5b57062e4d01cbfd0d25d6d4d9e933c265fadc5eda16ed17b8600e0a1ba27b3;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c + 1;
    let is_signature_valid = GardenTile::verify_signature(
        ref state, message_hash, signature_r, signature_s
    );
    assert(is_signature_valid == true, 'Signature is not valid');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Signature is not valid',))]
fn test_verify_signature_with_wrong_signer() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670 + 1;
    GardenTile::set_signer(ref state, signer);
    let message_hash = 0x5b57062e4d01cbfd0d25d6d4d9e933c265fadc5eda16ed17b8600e0a1ba27b3;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    let is_signature_valid = GardenTile::verify_signature(
        ref state, message_hash, signature_r, signature_s
    );
    assert(is_signature_valid == true, 'Signature is not valid');
}

#[test]
#[available_gas(2000000)]
fn test_mint_with_all_good() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id = 14;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Invalid Signature',))]
fn test_mint_with_wrong_tile_id() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id = 14 + 1;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Invalid Signature',))]
fn test_mint_with_wrong_signature_r() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id = 14;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837 + 1;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Invalid Signature',))]
fn test_mint_with_wrong_signature_s() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id = 14;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c + 1;
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('Tile already minted',))]
fn test_two_mint_with_same_params() {
    let mut state = setup();
    set_caller_address(OWNER());
    let signer = 0x6456f9bc55067882db6e28461aa53a5cb38c55b14b82211fe3844e62c143670;
    GardenTile::set_signer(ref state, signer);
    let tile_id = 14;
    let signature_r = 0x2931d989893cb9cf454639b3385bab442a08ba6d7b8979a678e0ee037495837;
    let signature_s = 0x60af0a432adc4816eaeacb618dde31971c7c18423c227cb49a8f293dd06c94c;
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
    GardenTile::mint(ref state, tile_id, signature_r, signature_s);
}
