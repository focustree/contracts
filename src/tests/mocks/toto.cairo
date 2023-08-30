#[starknet::interface]
trait IToto<TState> {
    fn toto(self: @TState) -> felt252;
}

#[starknet::contract]
mod Toto {
    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[external(v0)]
    fn toto(self: @ContractState) -> felt252 {
        'toto'
    }
}
