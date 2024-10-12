# Chainflip Dart

This package facilitates seamless interaction with the Chainflip network, supporting both Chainflip Substrate and Ethereum contracts, including StateGateway, Vault, and ERC20 contracts. It offers an API for creating, signing, and sending transactions for swaps across Bitcoin, Ethereum, Solana, and Substrate, enabling cross-chain swaps without dependencies.

## Futures

- **Chainflip substrate**
  - Create, sign, and send transactions to Substrate.
  - Support for creating broker accounts, opening swaps, depositing channels, creating liquidity accounts, withdrawing funds and etc.
  - Support for brokers, backend services, and Substrate RPC.

- **Chainflip ethereum**
  - Create, sign, and send transactions to the Ethereum network.
  - Interact with ERC20, Chainflip Vault, and StateGateway contracts.


- **Related Chain API**
  - Bitcoin: Create, sign, and send transactions using P2PKH, P2SH, P2WPKH, and P2TR addresses, and interact with Bitcoin via the   Electrum API.
  - Ethereum: Create, sign, and send transactions, and interact with ERC20 tokens, Chainflip Vault, and StateGateway contracts.
  - Solana: Create, sign, and send transactions using the Solana API, and manage token transfers and interactions.
  - Substrate: Create, sign, and send transactions to the Substrate network, supporting various asset transfers and interactions with smart contracts

## ChainFlip Examples

- Create Broker account [example](https://github.com/mrtnetwork/chainflip_dart/blob/main/example/lib/cf_api/become_broker.dart)
- Create liquidity account [example](https://github.com/mrtnetwork/chainflip_dart/blob/main/example/lib/cf_api/become_liquidity.dart)
- Request Swap Deposit Address [example](https://github.com/mrtnetwork/chainflip_dart/blob/main/example/lib/cf_api/request_swap_deposit_address.dart)
- Open Liquidity Deposit Address channel [example](https://github.com/mrtnetwork/chainflip_dart/blob/main/example/lib/cf_api/open_liquidity_deposit_channel.dart)
- Set liquidity Refund address [example](https://github.com/mrtnetwork/chainflip_dart/blob/main/example/lib/cf_api/set_liquidity_refunt_address.dart)
- Vault contract intraction [example](https://github.com/mrtnetwork/chainflip_dart/blob/main/example/lib/cf_api/vault_contract/swap_native.dart)

## Related chain Examples
- Create, sign and send bitcoin transactions [example](https://github.com/mrtnetwork/chainflip_dart/tree/main/example/lib/chain_api/bitcoin_example)
- Create, sign and send solana transactions [example](https://github.com/mrtnetwork/chainflip_dart/tree/main/example/lib/chain_api/solana_examples)
- Create, sign and send substrate transactions [example](https://github.com/mrtnetwork/chainflip_dart/tree/main/example/lib/chain_api/substrate_examples)
- Create, sign and send ethereum transactions [example](https://github.com/mrtnetwork/chainflip_dart/tree/main/example/lib/chain_api/ethereum_example)


## Resources

- [chainflip-io](https://github.com/chainflip-io)

## Contributing

Contributions are welcome! Please follow these guidelines:

- Fork the repository and create a new branch.
- Make your changes and ensure tests pass.
- Submit a pull request with a detailed description of your changes.

## Feature requests and bugs

Please file feature requests and bugs in the issue tracker.
