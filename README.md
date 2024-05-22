# War Effort Storage Unit System

## Overview

The **War Effort Storage Unit System** is a smart contract designed for the MUD framework by LatticeXYZ. It extends the capabilities of a vanilla Smart Storage Unit (SSU) into a specialized storage unit tailored for war efforts. This system allows users to deposit specific types of items, with no withdrawals permitted, and enforces strict rules about item types and quantities.

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
    git clone https://github.com/yourusername/war-effort-storage-unit.git
    cd war-effort-storage-unit
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
    pnpm initializeWarEffort
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

- **createAndAnchorWarEffort**: Create and anchor a new War Effort storage unit.
- **associateSSUToWarEffort**: Tag an existing SSU as a War Effort storage unit.
- **setAcceptedItemTypeId**: Set the accepted item type ID for a War Effort storage unit.
- **setTargetQuantity**: Set the target item quantity for a War Effort storage unit.
- **warEffortEphemeralToInventoryTransferHook**: Hook for transferring items from ephemeral to inventory storage.
- **warEffortDepositToInventoryHook**: Hook for depositing items to the War Effort inventory.
- **warEffortInventoryToEphemeralTransferHook**: Hook for transferring items from inventory to ephemeral storage.
- **warEffortWithdrawFromInventoryHook**: Hook for withdrawing items from inventory storage.

## Contract Details

### WarEffort.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

// Import statements...

/**
 * @title War Effort Storage Unit System
 * @notice Contains hook logic that modifies a vanilla SSU into a War Effort storage unit.
 * Users can only deposit a pre-determined kind of items, no withdrawals are allowed (transaction).
 */
contract WarEffort is EveSystem, IWarEffortErrors {
    // Contract implementation...
}
```

### Key Functions

- **createAndAnchorWarEffort**: Initializes a new War Effort storage unit with specific parameters including fuel capacity and storage details.
- **associateSSUToWarEffort**: Tags an existing SSU as a War Effort unit if the caller is the owner.
- **setAcceptedItemTypeId**: Defines the type of items that can be deposited into the War Effort storage unit.
- **setTargetQuantity**: Sets the target quantity for the specified item type.
- **warEffortEphemeralToInventoryTransferHook**: Handles transfers of items from ephemeral to inventory storage, enforcing rules on item types and quantities.
- **warEffortDepositToInventoryHook**: Handles item deposits, ensuring they match the accepted item type and do not exceed the target quantity.
- **warEffortInventoryToEphemeralTransferHook**: Restricts item withdrawals from War Effort storage units to their owner.
- **warEffortWithdrawFromInventoryHook**: Similar restriction as above for withdrawals.

## Development

### Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry) - A blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.

### Running Tests

1. **Review or add your tests** in the `test` directory. Example:

    ```solidity
    // test/WarEffort.t.sol
    pragma solidity ^0.8.21;
    import "forge-std/Test.sol";
    import "../src/WarEffort.sol";

    contract WarEffortTest is Test {
        // Test implementation...
    }
    ```

2. **Run the tests:**
    ```sh
    pnpm test
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.