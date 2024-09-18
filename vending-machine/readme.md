## Introduction
This guide will walk you through the process of building contracts for the vending machine, deploying them into an existing world running in Docker, and testing their functionality by executing scripts.

The vending machine allows you to automatically trade an item for another item. For example, if a player gives you one set item depending on the ratio you set it could give the player two of another item.

## Deployment and Testing
### Step 0: Deploy the vending machine contracts to the existing world 
First, copy the World Contract Address from the Docker logs obtained in the previous step, then run the following command:

![alt text](../docker_deployment.png)

```bash
cd gate-keeper/packages/contracts
```

Install the dependecies for the contracts:
```bash
pnpm install
```

**Local Deployment**
```bash
pnpm run deploy:local --worldAddress <worldAddress> 
```

**Devnet Deployment**
```bash
cd packages/contracts
pnpm run deploy:devnet --worldAddress <worldAddress> 
```


eg: `pnpm run deploy:local --worldAddress 0xafc8e4fd5eee66590c93feebf526e1aa2e93c6c3`

Once the deployment is successful, you'll see a screen similar to the one below. This process deploys the Gate Keeper contract.
![alt text](./readme-imgs/deployment.png)


### Step 1: Setup the environment variables 
Next, replace the following values in the [.env](./packages/contracts/.env) file with the values you copied earlier:

```bash
#WORLD ADDRESS COPIED FROM DOCKER LOGS
WORLD_ADDRESS=
```

You can adjust the remaining values in the .env file as needed, though they are optional.

<details markdown="block">
<summary>Changing optional environment values</summary>
```
pnpm run mock-data
```

</details>


### Step 2: Mock data for the existing world 
To generate mock data for testing the Vending Machine logic, run the following command:

```bash
pnpm run mock-data
```
This will create the on-chain SSU, fuel it and bring it online.

### Step 3: Configure Gate Keeper 
To configure which items should be traded and the ratio's to trade for run:

```bash
pnpm run configure-ratio
```

You can adjust the values for the SSU_ID, in and out item ID's and the ratios in the .env file as needed, though they are optional.

### Step 4: Test The Vending Machine (Optional)
To test the vending machine, execute the following command:

```bash
pnpm run execute
```

### Troubleshooting

If you encounter any issues, refer to the troubleshooting tips below:

1. **World Address Mismatch**: Double-check that the `WORLD_ADDRESS` is correctly updated in the `contracts/.env` file. Make sure you are deploying contracts to the correct world.
   
2. **Anvil Instance Conflicts**: Ensure there is only one running instance of Anvil. The active instance should be initiated via the `docker compose up -d` command. Multiple instances of Anvil may cause unexpected behavior or deployment errors.

3. **Trade Quantity Is Incorrect**: Ensure your input and output ratios have been correctly set in the `contracts/.env` file.  