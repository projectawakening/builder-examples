# Item Seller Storage Unit System

## Overview

The **Item Seller Storage Unit System** is a smart contract designed for the MUD framework by LatticeXYZ. It extends the capabilities of a vanilla Smart Storage Unit (SSU) into a specialized item seller unit. This system allows users to deposit specific types of items, with no withdrawals permitted, and enforces strict rules about item types and quantities.

This repository is intended for DeFi builders participating in a hackathon, offering a robust foundation for building complex game mechanics and storage solutions.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Contract Details](#contract-details)
- [Development](#development)
- [License](#license)

## Installation

1. **Clone the repository:**

    ```sh
    git clone https://github.com/yourusername/item-seller-storage-unit.git
    cd item-seller-storage-unit
    ```

2. **Install dependencies:**

  Ensure you have [Foundry](https://github.com/foundry-rs/foundry) and [pnpm](https://pnpm.io/) installed, then run:
    ```sh
    pnpm i
    pnpm foundry:up
    ```

3. **Build the contracts:**

    ```sh
    forge build
    ```

## Usage

### Deploying the Contract

1. **Deploy the contract to your preferred network:**

  ```sh
    cd packages/contracts
    pnpm initializeModules
    pnpm initializeClassAssociation
    pnpm initializeItemSeller
    ```
  NOTE: this is only needed to initialize the base modules and class association once; on our playtest's Testnet, it has probably already been done ! but to test locally, it will be necessary to run those prior to installing the War Module initialization script.

  WARNING: The MUD version this repository relies on uses _Transient Storage_ opcodes. This means that, in order to deploy the contract suite, you *need* to run a local node that has its `evm_version` set to `cancun` or higher.
  For that, you can run the following script:

  ```sh
  pnpm anvil
  ```

2. **Verify deployment:**

    Ensure the contract is deployed correctly by checking the transaction receipt on a block explorer.

### Interacting with the Contract

Use the following methods to interact with the contract:

- **createAndAnchorItemSeller**: Create and anchor a new Item Seller storage unit.
- **associateSSUToItemSeller**: Tag an existing SSU as an Item Seller storage unit.
- **setItemSellerAcceptedItemTypeId**: Set the accepted item type ID for an Item Seller storage unit.
- **setAllowPurchase**: Set the allow purchase status for an Item Seller storage unit.
- **setAllowBuyback**: Set the allow buyback status for an Item Seller storage unit.
- **setERC20PurchasePrice**: Set the ERC20 purchase price for an Item Seller storage unit.
- **setERC20BuybackPrice**: Set the ERC20 buyback price for an Item Seller storage unit.
- **setERC20Currency**: Set the ERC20 currency address for an Item Seller storage unit.
- **itemSellerDepositToInventoryHook**: Hook for depositing items to the Item Seller inventory.
- **itemSellerEphemeralToInventoryTransferHook**: Hook for transferring items from ephemeral to inventory storage.
- **itemSellerWithdrawFromInventoryHook**: Hook for withdrawing items from inventory storage.
- **itemSellerInventoryToEphemeralTransferHook**: Hook for transferring items from inventory to ephemeral storage.

## Contract Details

### ItemSeller.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// Import statements...

/**
 * @title Item Seller
 * @notice Contains hook logic that modifies a vanilla SSU into an Item Seller, that accepts only a single type of item for purchases and buybacks.
 * ERC20 transfers are automatically triggered from and to the user and SSU owner's wallets respectively each time a deposit or withdrawal of item is made, in the currency chosen by the owner.
 */
contract ItemSeller is EveSystem, IItemSellerErrors {
    // Contract implementation...
}
```

### Key Functions

- **createAndAnchorItemSeller**: Initializes a new Item Seller storage unit with specific parameters including fuel capacity and storage details.
- **associateSSUToItemSeller**: Tags an existing SSU as an Item Seller unit if the caller is the owner.
- **setItemSellerAcceptedItemTypeId**: Defines the type of items that can be deposited into the Item Seller storage unit.
- **setAllowPurchase**: Sets whether purchases are allowed from the Item Seller storage unit.
- **setAllowBuyback**: Sets whether buybacks are allowed to the Item Seller storage unit.
- **setERC20PurchasePrice**: Sets the purchase price in ERC20 tokens for the specified item type.
- **setERC20BuybackPrice**: Sets the buyback price in ERC20 tokens for the specified item type.
- **setERC20Currency**: Sets the ERC20 currency address for the Item Seller storage unit.
- **itemSellerDepositToInventoryHook**: Handles item deposits, ensuring they match the accepted item type and do not exceed the target quantity.
- **itemSellerEphemeralToInventoryTransferHook**: Handles transfers of items from ephemeral to inventory storage.
- **itemSellerWithdrawFromInventoryHook**: Restricts item withdrawals from Item Seller storage units to their owner.
- **itemSellerInventoryToEphemeralTransferHook**: Handles transfers of items from inventory to ephemeral storage.

## Development

### Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry) - A blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.

### Running Tests

1. **Write your tests** in the `test` directory. Example:

    ```solidity
    // test/ItemSeller.t.sol
    pragma solidity ^0.8.21;
    import "forge-std/Test.sol";
    import "../src/ItemSeller.sol";

    contract ItemSellerTest is Test {
        ItemSeller itemSeller;

        function setUp() public {
            itemSeller = new ItemSeller();
        }

        function testCreateAndAnchorItemSeller() public {
            // Test implementation...
        }

        function testSetItemSellerAcceptedItemTypeId() public {
            // Test implementation...
        }

        // Additional test cases...
    }
    ```

2. **Run the tests:**

    ```sh
    forge test
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.