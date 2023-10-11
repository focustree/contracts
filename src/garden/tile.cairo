#[starknet::contract]
mod GardenTile {
    use openzeppelin::token::erc721::erc721::ERC721::InternalTrait;
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use debug::PrintTrait;
    use core::ecdsa;
    use hash::LegacyHash;
    use starknet::{
        get_caller_address, get_contract_address, get_tx_info, ClassHash, ContractAddress,
        contract_address_to_felt252, contract_address_const
    };
    use openzeppelin::token::erc721::{
        ERC721, interface::{IERC721, IERC721CamelOnly, IERC721Metadata}
    };
    use openzeppelin::upgrades::{upgradeable::Upgradeable};
    use openzeppelin::access::ownable::{interface::IOwnable, ownable::Ownable};
    use openzeppelin::introspection::interface::{ISRC5, ISRC5Camel};
    use focustree::upgrade::interface::IUpgradeable;
    use array::ArrayTrait;
    use alexandria_ascii::ToAsciiArrayTrait;

    const NAME: felt252 = 'Focus Tree | Tile';
    const SYMBOL: felt252 = 'TILE';
    fn FOCUS_TREE_MULTISIG() -> ContractAddress {
        contract_address_const::<0x040b0060a849f50C27648a31dFDB7816Bf9bDc9D4bD03cDd774AD965E02C82Aa>()
    }


    #[storage]
    struct Storage {
        _signer: felt252,
        _base_uri: felt252,
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
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        #[key]
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        approved: ContractAddress,
        #[key]
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        #[key]
        owner: ContractAddress,
        #[key]
        operator: ContractAddress,
        approved: bool
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let mut unsafe_ownable_state = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::initializer(ref unsafe_ownable_state, FOCUS_TREE_MULTISIG());

        let mut unsafe_erc721_state = ERC721::unsafe_new_contract_state();
        ERC721::InternalImpl::initializer(ref unsafe_erc721_state, 'Focus Tree | Tile', 'TILE');
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
    impl ERC721CamelOnlyImpl of IERC721CamelOnly<ContractState> {
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            ERC721Impl::balance_of(self, account)
        }

        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            ERC721Impl::owner_of(self, tokenId)
        }

        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            ERC721Impl::get_approved(self, tokenId)
        }

        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721Impl::is_approved_for_all(self, owner, operator)
        }

        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            ERC721Impl::set_approval_for_all(ref self, operator, approved)
        }

        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
        ) {
            ERC721Impl::transfer_from(ref self, from, to, tokenId)
        }

        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            ERC721Impl::safe_transfer_from(ref self, from, to, tokenId, data)
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
    impl SRC5CamelImpl of ISRC5Camel<ContractState> {
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            return SRC5Impl::supports_interface(self, interfaceId);
        }
    }

    #[external(v0)]
    fn mint(ref self: ContractState, tile_id: u128, signature_r: felt252, signature_s: felt252) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        let tile_id_u256 = u256 { low: tile_id, high: 0 };
        assert(!unsafe_state._exists(tile_id_u256), 'Tile already minted');

        let message_hash = message_hash(tile_id);
        assert(
            verify_signature(ref self, message_hash, signature_r, signature_s), 'Invalid Signature'
        );

        let caller_address = get_caller_address();
        ERC721::InternalImpl::_mint(ref unsafe_state, caller_address, tile_id_u256);
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
    fn get_signer(self: @ContractState) -> felt252 {
        self._signer.read()
    }

    #[external(v0)]
    fn set_base_uri(ref self: ContractState, base_uri: felt252) {
        let unsafe_state = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::assert_only_owner(@unsafe_state);
        self._base_uri.write(base_uri);
    }

    #[external(v0)]
    fn get_base_uri(self: @ContractState) -> felt252 {
        return self._base_uri.read();
    }

    #[external(v0)]
    fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        assert(ERC721::InternalImpl::_exists(@unsafe_state, token_id), 'ERC721: invalid token ID');
        let base_uri = self._base_uri.read();
        let token_id_low = token_id.low;
        let mut uri: Array<felt252> = ArrayTrait::new();
        uri.append(base_uri);
        let ascii_array = token_id_low.to_ascii_array();
        let mut ascii_array_reverse = ascii_array.reverse();
        uri.append_all(ref ascii_array_reverse);
        return uri;
    }

    #[external(v0)]
    fn tokenUri(self: @ContractState, token_id: u256) -> Array<felt252> {
        return token_uri(self, token_id);
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
