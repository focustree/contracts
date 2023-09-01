use starknet::{ClassHash, ContractAddress, account::Call};

#[starknet::interface]
trait TileABI<TState> {
    // Upgradeable
    fn upgrade(ref self: TState, impl_hash: ClassHash);

    // SRC5
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;

    // ERC721
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;

    // ERC721Metadata
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn token_uri(self: @TState, token_id: u256) -> felt252;
}

#[starknet::interface]
trait GardenABI<TState> {
    // Upgradeable
    fn upgrade(ref self: TState, impl_hash: ClassHash);

    // SRC5
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;

    // ERC721Metadata
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn token_uri(self: @TState, token_id: u256) -> felt252;

    // SRC6
    fn __execute__(self: @TState, calls: Array<Call>) -> Array<Span<felt252>>;
    fn __validate__(self: @TState, calls: Array<Call>) -> felt252;
    fn is_valid_signature(self: @TState, hash: felt252, signature: Array<felt252>) -> felt252;
}
