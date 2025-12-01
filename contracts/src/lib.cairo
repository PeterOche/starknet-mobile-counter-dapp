#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState, user: felt252) -> felt252;
    fn increase_counter(ref self: TContractState);
}

#[starknet::contract]
mod Counter {
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        counter: felt252,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn get_counter(self: @ContractState, user: felt252) -> felt252 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let current = self.counter.read();
            self.counter.write(current + 1);
        }
    }
}
