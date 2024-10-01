# Smart Gate Example

## Introduction
This guide will walk you through the process of building contracts for the Smart Gate, deploying them into an existing world running in Docker, and testing their functionality by executing scripts.

This example shows how to interact with the Smart gate smart assembly and how to create contracts for it. The Smart Gate allows players to create player made transport gates, connecting systems and regions. It also features configuration options to allow specific players to use it.

### Additional Information

For additional information on the Smart Gate you can visit: [https://docs.evefrontier.com/SmartAssemblies/SmartGate](https://docs.evefrontier.com/SmartAssemblies/SmartGate).

## Deployment and Testing
### Step 0: Deploy the smart gate contracts to the existing world 
First, copy the World Contract Address from the Docker logs obtained in the previous step, then run the following command:

![alt text](../readme-imgs/docker_deployment.png)

```bash
cd smart-gate/packages/contracts
```

Install the Solidity dependencies for the contracts:
```bash
pnpm install
```

**Local Deployment**
This will deploy the contracts to your local world.
```bash
pnpm deploy:local --worldAddress <worldAddress> 
```

**Devnet/Production Deployment**
To deploy in devenet or production you can retrieve the world address through the below links and then replace <worldAddress> with the world address. 

Devnet which connects to Nova - Builder Sandbox

https://blockchain-gateway-nova.nursery.reitnorf.com/config

```bash
pnpm run deploy:garnet --worldAddress <worldAddress> 
```

Production which connects to Nebula

https://blockchain-gateway-nebula.nursery.reitnorf.com/config 
```

eg: `pnpm run deploy:local --worldAddress 0xafc8e4fd5eee66590c93feebf526e1aa2e93c6c3`

Once deployment is successful, you'll see a screen similar to the one below. This process deploys the Vending Machine contract.

![alt text](./readme-imgs/deployment.png)

### Step 1: Setup the environment variables 
Next, replace the following values in the [.env](./packages/contracts/.env) file with the values you copied earlier:

```bash
#WORLD ADDRESS COPIED FROM DOCKER LOGS
WORLD_ADDRESS=

# SMART GATE CONFIG (Only need to change if you are running on Devnet)
SOURCE_GATE_ID=123994
DESTINATION_GATE_ID=1230006
```

### Step 2: Mock data for the existing world **(Local Development Only)**
To generate mock data for testing the Smart Gate logic on the local world, run the following command:

```bash
pnpm mock-data
```

This will create the on-chain Gates, fuel them, bring them online, and create a test smart character.

### Step 3: Configure Smart Gate
To configure which smart gates will be used, run:

```bash
pnpm configure-smart-gate
```

You can adjust the values for the SSU_ID, in and out item ID's and the ratios in the .env file as needed, though they are optional.

### Step 4: Link Gates
To use the smart gates, you need to link them together to create a connection. To link the source and destination gates use:

```bash copy
pnpm link-gates
```

### Step 5: Test The Smart Gate (Optional)
To test the smart gate and check the canJump, use the following command:

```bash
pnpm execute
```

### Troubleshooting

If you encounter any issues, refer to the troubleshooting tips below:

1. **World Address Mismatch**: Double-check that the `WORLD_ADDRESS` is correctly updated in the `contracts/.env` file. Make sure you are deploying contracts to the correct world.
   
2. **Anvil Instance Conflicts**: Ensure there is only one running instance of Anvil. The active instance should be initiated via the `docker compose up -d` command. Multiple instances of Anvil may cause unexpected behavior or deployment errors.

3. **Gate IDs Mismatch**: If you are using Garnet make sure you have set the SOURCE_GATE_ID and DESTINATION_GATE_ID correctly. 

4. **Not Linked**: Make sure you link the gates as seen in Step 4, as otherwise the Smart Gates will not work.

### Still having issues?
If you are still having issues, then visit [the documentation website](https://docs.evefrontier.com/Troubleshooting) for more general troubleshooting tips.