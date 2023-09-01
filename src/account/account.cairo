use array::ArrayTrait;
use array::SpanTrait;
use option::OptionTrait;
use serde::Serde;
use starknet::{ContractAddress, account::Call};

const TRANSACTION_VERSION: felt252 = 1;

// 2**128 + TRANSACTION_VERSION
const QUERY_VERSION: felt252 = 340282366920938463463374607431768211457;

trait PublicKeyTrait<TState> {
    fn set_public_key(ref self: TState, new_public_key: felt252);
    fn get_public_key(self: @TState) -> felt252;
}

trait PublicKeyCamelTrait<TState> {
    fn setPublicKey(ref self: TState, newPublicKey: felt252);
    fn getPublicKey(self: @TState) -> felt252;
}

#[starknet::contract]
mod FocusAccount {
    use array::ArrayTrait;
    use array::SpanTrait;
    use box::BoxTrait;
    use ecdsa::check_ecdsa_signature;
    use option::OptionTrait;
    use zeroable::Zeroable;
    use starknet::{get_caller_address, get_contract_address, get_tx_info, ClassHash};
    use openzeppelin::account::{interface, account::Account};
    use openzeppelin::introspection::{interface::{ISRC5, ISRC5Camel}, src5::SRC5};
    use openzeppelin::upgrades::upgradeable::Upgradeable;
    use focustree::upgrade::interface::IUpgradeable;

    use super::Call;
    use super::QUERY_VERSION;
    use super::TRANSACTION_VERSION;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnerAdded: OwnerAdded,
        OwnerRemoved: OwnerRemoved,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnerAdded {
        new_owner_guid: felt252
    }

    #[derive(Drop, starknet::Event)]
    struct OwnerRemoved {
        removed_owner_guid: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState, _public_key: felt252) {
        let mut unsafe_state = Account::unsafe_new_contract_state();
        Account::InternalImpl::initializer(ref unsafe_state, _public_key);
    }

    //
    // External
    //

    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, impl_hash: ClassHash) {
            let mut unsafe_state = Upgradeable::unsafe_new_contract_state();
            Upgradeable::InternalImpl::_upgrade(ref unsafe_state, impl_hash);
        }
    }

    #[external(v0)]
    impl SRC6Impl of interface::ISRC6<ContractState> {
        fn __execute__(self: @ContractState, mut calls: Array<Call>) -> Array<Span<felt252>> {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::SRC6Impl::__execute__(@unsafe_state, calls)
        }

        fn __validate__(self: @ContractState, mut calls: Array<Call>) -> felt252 {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::InternalImpl::validate_transaction(@unsafe_state)
        }

        fn is_valid_signature(
            self: @ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::SRC6Impl::is_valid_signature(@unsafe_state, hash, signature)
        }
    }

    #[external(v0)]
    impl SRC6CamelOnlyImpl of interface::ISRC6CamelOnly<ContractState> {
        fn isValidSignature(
            self: @ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::SRC6Impl::is_valid_signature(@unsafe_state, hash, signature)
        }
    }

    #[external(v0)]
    impl DeclarerImpl of interface::IDeclarer<ContractState> {
        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::InternalImpl::validate_transaction(@unsafe_state)
        }
    }

    #[external(v0)]
    impl SRC5Impl of ISRC5<ContractState> {
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            let unsafe_state = SRC5::unsafe_new_contract_state();
            SRC5::SRC5Impl::supports_interface(@unsafe_state, interface_id)
        }
    }

    #[external(v0)]
    impl SRC5CamelImpl of ISRC5Camel<ContractState> {
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            let unsafe_state = SRC5::unsafe_new_contract_state();
            SRC5::SRC5CamelImpl::supportsInterface(@unsafe_state, interfaceId)
        }
    }

    #[external(v0)]
    impl PublicKeyImpl of super::PublicKeyTrait<ContractState> {
        fn get_public_key(self: @ContractState) -> felt252 {
            let unsafe_state = Account::unsafe_new_contract_state();
            Account::PublicKeyImpl::get_public_key(@unsafe_state)
        }

        fn set_public_key(ref self: ContractState, new_public_key: felt252) {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::PublicKeyImpl::set_public_key(ref unsafe_state, new_public_key);
        }
    }

    #[external(v0)]
    impl PublicKeyCamelImpl of super::PublicKeyCamelTrait<ContractState> {
        fn getPublicKey(self: @ContractState) -> felt252 {
            let unsafe_state = Account::unsafe_new_contract_state();
            Account::PublicKeyImpl::get_public_key(@unsafe_state)
        }

        fn setPublicKey(ref self: ContractState, newPublicKey: felt252) {
            let mut unsafe_state = Account::unsafe_new_contract_state();
            Account::PublicKeyImpl::set_public_key(ref unsafe_state, newPublicKey);
        }
    }

    #[external(v0)]
    fn __validate_deploy__(
        self: @ContractState,
        class_hash: felt252,
        contract_address_salt: felt252,
        _public_key: felt252
    ) -> felt252 {
        let mut unsafe_state = Account::unsafe_new_contract_state();
        Account::InternalImpl::validate_transaction(@unsafe_state)
    }
}
