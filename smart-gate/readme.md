<div align="center">

# 🚪 Smart Gate Example

> Build a [**Smart Gate**](https://docs.evefrontier.com/SmartAssemblies/SmartGate) that only allows members of a specific tribe to use it

</div>

# Smart Gate Example

## Table of Contents

1. [Introduction](#introduction)
2. [Deployment and Testing in Local Environment](#deployment-and-testing-in-local-environment)
3. [Deployment To The Game (Stillness)](#deployment-to-the-game-stillness)
4. [Troubleshooting](#troubleshooting)

## Introduction

This example will show you how to deploy and configure contracts for a [Smart Gate](https://docs.evefrontier.com/SmartAssemblies/SmartGate) that only allows members of a specific tribe to use it.

Before starting make sure you've installed all required tools from the main [README](../README.md)

The Smart Gate allows players to create player-made transport gates, connecting systems and regions. It also features configuration options to allow specific players to use it. 

You can test everything locally first using the [Local Environment Guide](#deployment-and-testing-in-local-environment), and when ready, deploy to the live game using the [Deployment Guide](#deployment-to-the-game-stillness).

### Additional Information

For additional details on the Smart Gate, see our [Documentation](https://docs.evefrontier.com/SmartAssemblies/SmartGate).

## Deployment and Testing in Local Environment
To deploy the example to your local world hosted on Docker, follow the below steps.

### Step 1: Deploy the example contracts to the existing world
First, copy the World Contract Address from the Docker logs obtained in the previous steps:

![alt text](../readme-imgs/docker-deployment.png)

Then, run the following commands:

1. Navigate to the example directory:
    ```bash
    cd smart-gate
    ```

2. Install the Solidity dependencies for the contracts:
    ```bash
    pnpm install
    ```

3. Create your environment file:
    ```bash
    cp packages/contracts/.envsample packages/contracts/.env
    ```

4. Deploy to your local test environment
    ```bash
    pnpm dev
    ```

> [!NOTE]
> This will deploy the contracts to a forked version of your local world for testing.

### Step 2: Mock data for the existing world
Generate the test data by:

#### Step 2.1. Select the "shell" process and then click on the main terminal window. 

![Processes Image](../readme-imgs/processes.png)

#### Step 2.2. To generate mock data for testing the Smart Gate logic on the local world, run the following command. 

```bash
pnpm mock-data
```

> [!NOTE]
> This will create the on-chain Gates, fuel them, bring them online, and create a test smart character.

### Step 3: Configure Smart Gate
To configure which smart gates will be used and the allowed tribe ID, run:

```bash
pnpm configure
```

> [!NOTE]
> You can adjust the values for the SMART_GATE_ID and ALLOWED_TRIBE_ID in the .env file as needed, though they are optional.

### Step 4: Link Gates
To use the smart gates, you need to link them together to create a connection. To link the source and destination gates through a script use:

```bash copy
pnpm link-gates
```

### Step 5: Test The Smart Gate (Optional)
To test the smart gate and check the canJump, use the following command:

```bash
pnpm can-jump
```

You can also test the smart gate using the unit tests with:
```bash
pnpm test
```

This will run a series of pre-defined tests, and should display the results like:
![../readme-imgs/tests-gate.png]

## Deployment To The Game (Stillness)
To deploy the example to the game server which is named Stillness, follow the below steps.

### Step 1: Setup your Environment
Move to the example directory with:

```bash
cd smart-gate/packages/contracts
```

Then install the Solidity dependencies for the contracts:
```bash
pnpm install
```

Then, if you haven't already copy the .envsample file to a .env file with:
```bash
cp .envsample .env
```

### Step 2: Configure the Example to use Stillness

Next, set the following values in the [.env](./packages/contracts/.env) file to direct the scripts to use Stillness:

```bash copy
WORLD_ADDRESS=0xcdb380e0cd3949caf70c45c67079f2e27a77fc47
RPC_URL=https://pyrope-external-sync-node-rpc.live.tech.evefrontier.com
CHAIN_ID=695569
```

You can also automatically point to Stillness with current values using: 

```bash
pnpm env-stillness
```

### Step 3: Configure the Namespace

A namespace is a unique identifier for deploying your smart contracts. Once you deploy to a namespace, it will set you as the owner and only you will be able to deploy smart contracts within the namespace.

**Namespace Rules:**
- ✅ Use letters (a-z, A-Z)
- ✅ Use numbers (0-9)
- ✅ Use underscores (_)
- ❌ No special characters
- ❌ No spaces

Change the namespace from test to your own custom namespace. 

> [!TIP]
> Consider using your username or tribe name as your namespace.

First, edit **packages/contracts/mud.config.ts** to include your new namespace:

```ts
import { defineWorld } from "@latticexyz/world";

export default defineWorld({
    namespace: "new_namespace",
    tables: {
        ...
```

Then, edit **packages/contracts/src/systems/constants.sol**:

```solidity
bytes14 constant DEPLOYMENT_NAMESPACE = "new_namespace";
```

You can also use the below command and then input your new namespace to change it automatically:

```bash
pnpm set-namespace
```

### Step 4: Configure the Private Key

Import your game wallet recovery phrase into EVE Wallet to get your private key:

<div align="center">
<img src="../readme-imgs/private-key.png" alt="Private Key" width="600">
</div>

<br />

Then, set the `PRIVATE_KEY` in your .env file:

```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

You can also use the below command and then input your private key to change it:

```bash
pnpm set-key
```

### Step 5: Deploy the Contract

Then deploy the SSU contracts using:

```bash
pnpm run deploy:pyrope
```

Once the deployment is successful, you'll see a screen similar to the one below.

<div align="center">
<img src="../readme-imgs/deploy.png" alt="Deploy" width="600">
</div>

## Configuring and Testing the Game Contracts (Stillness)

### Step 1: Setup the environment variables 
Next, replace the following values in the [.env](./packages/contracts/.env) file with the below steps.

#### Step 1.1: Smart Gate ID's

For Stillness, the smart gate id is available once you have deployed an Smart Gate in the game. Right click your Smart Gate, click Interact and open the dapp window and copy the smart gate id.

For Stillness, the Smart Gate ID is available once you have deployed an Smart Gate in the game.

1. Right click your Source Smart Gate and press Interact

2. Copy the smart gate id.

<div align="center">
<img src="../readme-imgs/ssu-id.png" alt="SSU ID" width="800">
</div>

3. Set the SOURCE_GATE_ID in the [.env](./packages/contracts/.env) file.

    ```bash
    SOURCE_GATE_ID=34818344039668088032259299209624217066809194721387714788472158182502870248994
    ```

4. Repeat the above steps for the DESTINATION_GATE_ID value.

#### Step 1.2: Allowed Tribe ID

Now set the ALLOWED_TRIBE_ID variable.

1. Retrieve your character address from searching your username here: [Smart Characters World API](https://world-api-stillness.live.tech.evefrontier.com/smartcharacters)

2. Use this link: https://world-api-stillness.live.tech.evefrontier.com/v2/smartcharacters/ADDRESS and replace **"ADDRESS"** with the address from the previous step.

3. Use the **"tribeId"** value which should be in:
    ```json
    {
        "address": "0x9dcd62f5c02e7066a3154bc3ba029e85345a5ce9",
        "id": "27968150122480120904130498262405934486185445355744041492535994892832439518842",
        "tribeId": "98000002",
        "name": "CCP Red Dragon",
        ...
    ```

4. Set the ALLOWED_TRIBE_ID variable in the [.env](./packages/contracts/.env) file.

    ```bash
    ALLOWED_TRIBE_ID=98000002
    ```

You can also set these values automatically using the below command:

```bash
pnpm set-config
```

### Step 2: Configure Smart Gate
To configure which smart gates will be used, run:

```bash
pnpm configure
```

> [!NOTE]
> You can alter the gate ID's and the allowed tribe in the .env file as needed.

### Troubleshooting

If you encounter any issues, refer to the troubleshooting tips below:

1. **World Address Mismatch**: Double-check that the `WORLD_ADDRESS` is correctly updated in the `contracts/.env` file. Make sure you are deploying contracts to the correct world.
   
2. **Anvil Instance Conflicts**: Ensure there is only one running instance of Anvil. The active instance should be initiated via the `docker compose up -d` command. Multiple instances of Anvil may cause unexpected behavior or deployment errors.

3. **Not able to jump even though it's the correct tribe**: Ensure you have set the correct tribe ID set in the `contracts/.env` file.

## Need Help? 

If you are still having issues, then visit the Documentation or join the Discord Community for support.

[![Documentation](https://img.shields.io/badge/📚_Documentation-Visit_Docs-blue)](https://docs.evefrontier.com/)
[![Community](https://img.shields.io/badge/💬_Discord-Join_Community-7289DA)](https://discord.gg/evefrontier)