#[starknet::contract]
mod GardenTile {
    use openzeppelin::token::erc721::ERC721::ERC721Impl;
    use openzeppelin::token::erc721::ERC721::InternalImpl;
    use openzeppelin::token::erc721::ERC721;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use core::ecdsa;

    #[storage]
    struct Storage {
        _total_supply: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        InternalImpl::initializer(ref unsafe_state, 'Garden Tile', 'TILE');
        InternalImpl::_mint(ref unsafe_state, get_caller_address(), 0);
        self._total_supply.write(1);
    }

    #[external(v0)]
    fn mint(ref self: ContractState)  {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        let supply = self._total_supply.read();
        InternalImpl::_mint(ref unsafe_state, get_caller_address(), supply);
        self._total_supply.write(supply + 1);
    }

    #[external(v0)]
    fn test_check_ecdsa_signature(self: @ContractState) -> bool {
        let message_hash = 0x503f4bea29baee10b22a7f10bdc82dda071c977c1f25b8f3973d34e6b03b2c;
        let public_key = 0x7b7454acbe7845da996377f85eb0892044d75ae95d04d3325a391951f35d2ec;
        let signature_r = 0xbe96d72eb4f94078192c2e84d5230cde2a70f4b45c8797e2c907acff5060bb;
        let signature_s = 0x677ae6bba6daf00d2631fab14c8acf24be6579f9d9e98f67aa7f2770e57a1f5;

        return ecdsa::check_ecdsa_signature(:message_hash, :public_key, :signature_r, :signature_s);
    }

    #[external(v0)]
    fn test_recover_public_key(self: @ContractState, y_parity: bool) -> Option<felt252> {
        let message_hash = 0x503f4bea29baee10b22a7f10bdc82dda071c977c1f25b8f3973d34e6b03b2c;
        let signature_r = 0xbe96d72eb4f94078192c2e84d5230cde2a70f4b45c8797e2c907acff5060bb;
        let signature_s = 0x677ae6bba6daf00d2631fab14c8acf24be6579f9d9e98f67aa7f2770e57a1f5;

        return ecdsa::recover_public_key(:message_hash, :signature_r, :signature_s, :y_parity);
    }

    #[external(v0)]
    fn total_supply(self: @ContractState) -> u256 {
        self._total_supply.read()
    }

    #[external(v0)]
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::SRC5Impl::supports_interface(@unsafe_state, interface_id)
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

    #[external(v0)]
    fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721MetadataImpl::token_uri(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::balance_of(@unsafe_state, account)
    }

    #[external(v0)]
    fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::owner_of(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::get_approved(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn is_approved_for_all(
        self: @ContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::is_approved_for_all(@unsafe_state, owner, operator)
    }

    #[external(v0)]
    fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::approve(ref unsafe_state, to, token_id)
    }

    #[external(v0)]
    fn set_approval_for_all(ref self: ContractState, operator: ContractAddress, approved: bool) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::set_approval_for_all(ref unsafe_state, operator, approved)
    }

    #[external(v0)]
    fn transfer_from(
        ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    ) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::transfer_from(ref unsafe_state, from, to, token_id)
    }

    #[external(v0)]
    fn safe_transfer_from(
        ref self: ContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    ) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721Impl::safe_transfer_from(ref unsafe_state, from, to, token_id, data)
    }
}
