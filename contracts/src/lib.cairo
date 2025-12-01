#[starknet::interface]
pub trait ICounter<TContractState> {
    fn get_counter(self: @TContractState, user: felt252) -> felt252;
    fn increase_counter(ref self: TContractState);
}

#[starknet::contract]
mod Counter {
    use starknet::get_caller_address;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    #[storage]
    struct Storage {
        counters: Map<felt252, felt252>,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn get_counter(self: @ContractState, user: felt252) -> felt252 {
            self.counters.read(user)
        }

        fn increase_counter(ref self: ContractState) {
            let caller = get_caller_address();
            let caller_felt: felt252 = caller.into();
            let current = self.counters.read(caller_felt);
            self.counters.write(caller_felt, current + 1);
        }
    }
}
