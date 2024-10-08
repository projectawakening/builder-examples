# Smart Turret Example

## Introduction
This guide will walk you through the process of building contracts for the smart turret, deploying them into an existing world running in Docker, and testing their functionality by executing scripts.

This example shows how to interact with the Smart Turret smart assembly and how to create contracts for it. The Smart Turret allows you to defend an area and can be configured to determine which ships to shoot and the priority to shoot them.

### Additional Information

For additional information on the Smart Turret you can visit: [https://docs.evefrontier.com/SmartAssemblies/SmartTurret](https://docs.evefrontier.com/SmartAssemblies/SmartTurret).

## Deployment and Testing
### Step 0: Deploy the smart turret contracts to the existing world 
First, copy the World Contract Address from the Docker logs obtained in the previous step, then run the following command:

![alt text](../readme-imgs/docker_deployment.png)

```bash
cd smart-turret/packages/contracts
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

**Devnet/Production Deployment**
To deploy in devenet or production you can retrieve the world address through the below links and then replace <worldAddress> with the world address. 

Devnet which connects to Nova - Builder Sandbox

https://blockchain-gateway-nova.nursery.reitnorf.com/config

```bash
pnpm run deploy:garnet --worldAddress <worldAddress> 
```

Production which connects to Nebula

https://blockchain-gateway-nebula.nursery.reitnorf.com/config 

eg: `pnpm deploy:garnet --worldAddress 0xafc8e4fd5eee66590c93feebf526e1aa2e93c6c3`

Once deployment is successful, you'll see a screen similar to the one below. This process deploys the Smart Turret contract. <br>

![alt text](./readme-imgs/deployment.png)


### Step 1: Setup the environment variables 
Next, replace the following values in the [.env](./packages/contracts/.env) file with the respective values 

You can change values in the .env file for Nova and Nebula, though they are optional for local testing.

For Nova and Nebula, Get your recovery phrase from the game wallet, import into EVE Wallet and then grab the private key from there.

```bash
PLAYER_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

For Nova and Nebula, get the world address from the configs

https://blockchain-gateway-nova.nursery.reitnorf.com/config
https://blockchain-gateway-nebula.nursery.reitnorf.com/config

![alt text](../readme-imgs/worldAddress.png)

```bash
#WORLD ADDRESS COPIED FROM DOCKER LOGS FOR LOCAL
WORLD_ADDRESS=
```

For Nova or Nebula, the smart turret id is available once you have deployed an Smart Turret in the game. 

Right click your Smart Turret, click Interact and open the dapp window and copy the smart turret id.


```bash
#SMART TURRET ID (Only need to change if you are running on Devnet)
SMART_TURRET_ID=
```

### Step 2: Mock data for the existing world **(Local Development Only)**
To generate mock data for testing the Smart Turret logic on the local world, run the following command:

```bash
pnpm mock-data
```

This will create the on-chain turret, fuel it, bring it online, and create a test smart character.

### Step 3: Configure Smart Turret
To set the Smart Turret, turret ID use:

```bash
pnpm configure-smart-turret
```

You can adjust the values for the SSU_ID, in and out item ID's and the ratios in the .env file as needed, though they are optional.

### Step 4: Test The Smart Turret (Optional)
To test the Smart Turret In Proximity functionality you can use the follow command:

```bash
pnpm execute
```

### Troubleshooting

If you encounter any issues, refer to the troubleshooting tips below:

1. **World Address Mismatch**: Double-check that the `WORLD_ADDRESS` is correctly updated in the `contracts/.env` file. Make sure you are deploying contracts to the correct world.
   
2. **Anvil Instance Conflicts**: Ensure there is only one running instance of Anvil. The active instance should be initiated via the `docker compose up -d` command. Multiple instances of Anvil may cause unexpected behavior or deployment errors.

3. **Turret ID Mismatch (Devnet)**: Double-check that the `SMART_TURRET_ID` is correctly updated in the `contracts/.env` file. 

### Still having issues?
If you are still having issues, then visit [the documentation website](https://docs.evefrontier.com/Troubleshooting) for more general troubleshooting tips.