#[starknet::contract]
mod GardenTile {
    use openzeppelin::token::erc721::ERC721::ERC721Impl;
    use openzeppelin::token::erc721::ERC721::InternalImpl;
    use openzeppelin::token::erc721::ERC721;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_contract_address;
    use starknet::contract_address_to_felt252;
    use core::ecdsa;
    use hash::LegacyHash;

    #[storage]
    struct Storage {
        _total_supply: u256,
        _signer: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        InternalImpl::initializer(ref unsafe_state, 'Garden Tile', 'TILE');
        InternalImpl::_mint(ref unsafe_state, get_caller_address(), 0);
        self._total_supply.write(1);
    }

    #[external(v0)]
    fn mint(ref self: ContractState, class_id: u128, signature_r: felt252, signature_s: felt252 )  {
        let message_hash = message_hash(class_id);
        assert(verify_signature(ref self, message_hash, signature_r, signature_s), 'Invalid Signature');
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        let supply = self._total_supply.read();
        InternalImpl::_mint(ref unsafe_state, get_caller_address(), supply);
        self._total_supply.write(supply + 1);
    }

    fn verify_signature(ref self: ContractState, message_hash:felt252,signature_r: felt252, signature_s: felt252)->bool{
        return ecdsa::check_ecdsa_signature(message_hash,self._signer.read(),signature_r, signature_s);
    }

    #[external(v0)]
    fn test_message_hash(self: @ContractState, class_id: u128, contract_address: felt252, caller_address: felt252) -> felt252 {
        return LegacyHash::hash(0, (contract_address, caller_address, class_id,3));
    }

    #[external(v0)]
    fn test_verify_signature(self: @ContractState,message_hash:felt252,signature_r: felt252, signature_s: felt252 ) -> bool {
        return ecdsa::check_ecdsa_signature(message_hash,self._signer.read(),signature_r, signature_s);
    }

    //should be only called by the owner of the contract
    #[external(v0)]
    fn set_signer(ref self: ContractState, signer: felt252) {
        self._signer.write(signer);
    }

    fn message_hash(class_id: u128 ) -> felt252 {
        let contract_address = contract_address_to_felt252(get_contract_address());
        let caller_address = contract_address_to_felt252(get_caller_address());

        let mut message_hash = LegacyHash::hash(0, (contract_address, caller_address, class_id, 3));

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
