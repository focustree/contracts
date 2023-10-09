#[starknet::contract]
mod GardenTile {
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use debug::PrintTrait;
    use core::ecdsa;
    use hash::LegacyHash;
    use starknet::{
        get_caller_address, get_contract_address, get_tx_info, ClassHash, ContractAddress,
        contract_address_to_felt252, contract_address_const
    };
    use openzeppelin::token::erc721::{ERC721, interface::{IERC721, IERC721Metadata}};
    use openzeppelin::upgrades::{upgradeable::Upgradeable};
    use openzeppelin::access::ownable::{interface::IOwnable, ownable::Ownable};
    use openzeppelin::introspection::interface::ISRC5;
    use focustree::upgrade::interface::IUpgradeable;
    use array::ArrayTrait;
    use alexandria_ascii::ToAsciiArrayTrait;


    #[storage]
    struct Storage {
        _total_supply: u256,
        _signer: felt252,
        _is_tile_minted: LegacyMap<u128, bool>,
        _base_uri_1: felt252,
        _base_uri_2: felt252
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        approved: ContractAddress,
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let mut unsafe_ownable_state = Ownable::unsafe_new_contract_state();
        let owner =
            contract_address_const::<0x05161ae78b651b239167b3ed0c1b2f09983cbd9ff433c14fb31472ce8008ac1d>();
        Ownable::InternalImpl::initializer(ref unsafe_ownable_state, owner);

        let mut unsafe_erc721_state = ERC721::unsafe_new_contract_state();
        ERC721::InternalImpl::initializer(ref unsafe_erc721_state, 'Garden Tile', 'TILE');
    }

    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            let unsafe_state_ownable = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state_ownable);
            let mut unsafe_state = Upgradeable::unsafe_new_contract_state();
            Upgradeable::InternalImpl::_upgrade(ref unsafe_state, new_class_hash);
        }

        fn version(self: @ContractState) -> felt252 {
            1
        }
    }

    #[external(v0)]
    impl OwnableImpl of IOwnable<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::owner(@unsafe_state)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::transfer_ownership(ref unsafe_state, new_owner);
        }

        fn renounce_ownership(ref self: ContractState) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::renounce_ownership(ref unsafe_state);
        }
    }

    #[external(v0)]
    impl ERC721Impl of IERC721<ContractState> {
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::balance_of(@unsafe_state, account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::owner_of(@unsafe_state, token_id)
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::get_approved(@unsafe_state, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::is_approved_for_all(@unsafe_state, owner, operator)
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::approve(ref unsafe_state, to, token_id)
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::set_approval_for_all(ref unsafe_state, operator, approved)
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::transfer_from(ref unsafe_state, from, to, token_id)
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::safe_transfer_from(ref unsafe_state, from, to, token_id, data)
        }
    }


    #[external(v0)]
    impl SRC5Impl of ISRC5<ContractState> {
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::SRC5Impl::supports_interface(@unsafe_state, interface_id)
        }
    }

    #[external(v0)]
    fn mint(ref self: ContractState, tile_id: u128, signature_r: felt252, signature_s: felt252) {
        assert(self._is_tile_minted.read(tile_id) == false, 'Tile already minted');
        let message_hash = message_hash(tile_id);
        assert(
            verify_signature(ref self, message_hash, signature_r, signature_s), 'Invalid Signature'
        );
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        let supply = self._total_supply.read();
        self._total_supply.write(supply + 1);
        self._is_tile_minted.write(tile_id, true);
        let tile_id_u256 = u256 { low: tile_id, high: 0 };
        ERC721::InternalImpl::_mint(ref unsafe_state, get_caller_address(), tile_id_u256);
    }

    fn verify_signature(
        ref self: ContractState, message_hash: felt252, signature_r: felt252, signature_s: felt252
    ) -> bool {
        return ecdsa::check_ecdsa_signature(
            message_hash, self._signer.read(), signature_r, signature_s
        );
    }

    #[external(v0)]
    fn set_signer(ref self: ContractState, signer: felt252) {
        let unsafe_state = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::assert_only_owner(@unsafe_state);
        self._signer.write(signer);
    }

    fn message_hash(tile_id: u128) -> felt252 {
        let contract_address = contract_address_to_felt252(get_contract_address());
        let caller_address = contract_address_to_felt252(get_caller_address());

        let mut message_hash = LegacyHash::hash(0, (contract_address, caller_address, tile_id, 3));

        return message_hash;
    }

    #[external(v0)]
    fn total_supply(self: @ContractState) -> u256 {
        self._total_supply.read()
    }

    #[external(v0)]
    fn get_signer(self: @ContractState) -> felt252 {
        self._signer.read()
    }

    #[external(v0)]
    fn set_base_uri(ref self: ContractState, base_uri_1: felt252, base_uri_2: felt252,) {
        let unsafe_state = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::assert_only_owner(@unsafe_state);
        self._base_uri_1.write(base_uri_1);
        self._base_uri_2.write(base_uri_2);
    }

    #[external(v0)]
    fn get_base_uri_1(self: @ContractState) -> felt252 {
        return self._base_uri_1.read();
    }

    #[external(v0)]
    fn get_base_uri_2(self: @ContractState) -> felt252 {
        return self._base_uri_2.read();
    }

    #[external(v0)]
    fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        assert(ERC721::InternalImpl::_exists(@unsafe_state, token_id), 'ERC721: invalid token ID');
        let base_uri_1 = self._base_uri_1.read();
        let base_uri_2 = self._base_uri_2.read();
        let token_id_low = token_id.low;
        let mut uri: Array<felt252> = ArrayTrait::new();
        uri.append(base_uri_1);
        uri.append(base_uri_2);
        let ascii_array = token_id_low.to_ascii_array();
        let mut ascii_array_reverse = ascii_array.reverse();
        uri.append_all(ref ascii_array_reverse);
        return uri;
    }

    #[external(v0)]
    fn name(self: @ContractState) -> felt252 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721MetadataImpl::name(@unsafe_state)
    }

    #[external(v0)]
    fn symbol(self: @ContractState) -> felt252 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721MetadataImpl::symbol(@unsafe_state)
    }
}
