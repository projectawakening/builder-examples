# Item Trade Example

## Introduction
This guide will walk you through the process of building contracts for the item trade, deploying them into an existing world running in Docker, and testing their functionality by executing scripts. 

### User Flow
The item trade is a Smart Storage Unit (SSU) which can exchange ERC20 tokens for items and items in exchange for ERC20Tokens. 

The SSU (item seller) has two types of inventories; the main inventory and the ephemeral inventory.

#### Inventory
This is the storage that belongs to the owner of the SSU.

#### Ephemeral Inventory
Temporary storage for players interacting with the SSU. Players can deposit and withdraw items from the SSU via this inventory.

When an ERC20 token is transferred by the player, the item seller SSU transfers items from the owner's inventory to the player's ephemeral inventory. Players can then withdraw these items to their ship's hangar.

## Deployment and Testing
### Step 0: Deploy the item seller contracts to the existing world 
First, copy the World Contract Address from the Docker logs obtained in the previous step, then run the following command:

![alt text](../readme-imgs/docker_deployment.png)

```bash
cd item-trade/packages/contracts
```

Install the dependencies for the contracts:
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

```bash
pnpm run deploy:prod --worldAddress <worldAddress> 
```

eg: `pnpm run deploy:local --worldAddress 0xafc8e4fd5eee66590c93feebf526e1aa2e93c6c3`

Once the deployment is successful, you'll see a screen similar to the one below. This process deploys the Item Trade contract and a test ERC20 token required for the Item Trade. Be sure to copy the ERC20 token address and save it for future use.
![alt text](./readme-imgs/deployment.png)


### Step 1: Setup the environment variables 
Next, replace the following values in the [.env](./packages/contracts/.env) file with the respective values 

You can change values in the .env file for Nova and Nebula, though they are optional for local testing.

For Nova and Nebula, Get your recovery phrase from the game wallet, import into EVE Wallet and then grab the private key from there.

```bash
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

For Nova and Nebula, get the world address from the configs. You can deploy your own ERC20 token or use the EVE Token address in the config

https://blockchain-gateway-nova.nursery.reitnorf.com/config
https://blockchain-gateway-nebula.nursery.reitnorf.com/config

![alt text](../readme-imgs/worldAddress.png)

```bash
#WORLD ADDRESS COPIED FROM DOCKER LOGS FOR LOCAL
WORLD_ADDRESS=

#ERC20 TOKEN ADDRESS COPIED FROM ITEM SELLER DEPLOYMENT FOR LOCAL
ERC20_TOKEN_ADDRESS=
```

For Nova or Nebula, Smart Storage Unit ID (SSU ID) is available once you have deployed an SSU in the game.

Right click your Smart Storage Unit, and open the dapp window and copy the smart storage unit id.

![alt text](../readme-imgs/ssuid.png)

```bash
#DONT NEED TO CHANGE IF YOUR RUNNING LOCALLY
SSU_ID=34818344039668088032259299209624217066809194721387714788472158182502870248994
```

For Nova or Nebula, You can get the item you want to sell and the item you want to buy from the world api by using the below links and replace the `ssu_id` by your own SSU_ID.

NOTE: Its a prerequisite to have already deposited these items into the SSU. This is to ensure that the game logic has updated those specific items data on-chain.

https://blockchain-gateway-nebula.nursery.reitnorf.com/smartassemblies/<ssu_id>
https://blockchain-gateway-nova.nursery.reitnorf.com/smartassemblies/<ssu_id>

You should now have similar JSON to this. You want to get the item ID from the itemId in the storage items array and ephemeralInventoryItems array. The item ID should look something like: 

```json
"112603025077760770783264636189502217226733230421932850697496331082050661822826"
```

```json
"inventory": {
  "storageCapacity": 100000000000000,
  "usedCapacity": 490000000000,
  "storageItems": [
    {
      "typeId": 77518,
      "itemId": "112603025077760770783264636189502217226733230421932850697496331082050661822826",
      "quantity": 49,
      "name": "Lens 3X",
      "image": "https://devnet-data-ipfs-gateway.nursery.reitnorf.com/ipfs/QmcQzTvz9Z4koU8pvBJL94HxHtLoPoB9wDnuRE278AdbmA"
    }
  ],
  "ephemeralInventoryList": [
    {
      "ownerId": "0xbc07106cc909d37e36a1c3db35411805836bdf67",
      "ownerName": "skygirl",
      "storageCapacity": 1000000000000,
      "usedCapacity": 10000000000,
      "ephemeralInventoryItems": [
        {
          "typeId": 77518,
          "itemId": "112603025077760770783264636189502217226733230421932850697496331082050661822826",
          "quantity": 1,
          "name": "Lens 3X",
          "image": "https://devnet-data-ipfs-gateway.nursery.reitnorf.com/ipfs/QmcQzTvz9Z4koU8pvBJL94HxHtLoPoB9wDnuRE278AdbmA"
        }
      ]
    }
  ]
},
```

Fetch the `itemId` from `{inventory.storageItems.itemId}`

![alt text](../readme-imgs/itemIds.png)

```bash
#ITEM IN : SALT
ITEM_IN_ID=70505200487489129491533272716910408603753256595363780714882065332876101173161
#ITEM OUT : LENS
ITEM_OUT_ID=112603025077760770783264636189502217226733230421932850697496331082050661822826
```

**Setting item trade configs**
You can set the address that receives payments, the price in Wei and the enforcedMultipleForItem

```bash
ERC20_TOKEN_ADDRESS=0x6563b29D32AcAdEFA83214b322bDB8055c121bd9
RECEIVER_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
##PRICE SHOULD BE IN WEI
PRICE_IN_WEI=500000000000000000
ENFORCED_ITEM_MULTIPLE=99
TOKEN_AMOUNT=275000000000000000000
```


### Step 2: Mock data for the existing world **(Local Development Only)**
To generate mock data for testing the Item Trade logic on the local world, run the following command:

```bash
pnpm mock-data
```
This will create the on-chain SSU, fuel it, bring it online, and deposit some items into inventory and players ephemeral inventory so they can be traded in exchange for the ERC20 token.

This will also transfer some ERC20 tokens to the item trade contract so that there is enough balance to sell to players in exchange for an item.

### Step 3: Configure Item Seller 
To configure which items should be sold and purchased in return for the ERC20 token, run:

```bash
pnpm configure-item-trade
```

You can adjust the values for the SSU_ID & INVENTORY_ITEM_ID in the .env file as needed, though they are optional.

### Step 4: Test Item Seller (Optional)
To test the purchase of an item in return for the token, execute the following command:

Note: In Devnet, ensure that the player has enough tokens to complete the purchase.

```bash
pnpm approve
pnpm purchase-item
```

### Step 5: Test Item Buyer (Optional)
To test the selling an item in return for the token, execute the following command:

Note: In Devnet, ensure that the player has items to sell

```bash
pnpm sell-item
```

## Client UI

### Step 6: Launch the Client UI

To start the client interface, navigate to the client directory and run the following command:

```bash
cd ../client
pnpm run dev
```

This will launch a local development server at `http://localhost:3000`, which will be connected to the world address defined earlier in Step 1.

![alt text](./readme-imgs/item-trade-client.webp)

### Step 7: Configure Client Environment Variables

Next, update the following values in the `.env` file located in the `./packages/client/` folder:

```bash
VITE_ITEM_OUT_ID=
VITE_ITEM_IN_ID=
VITE_SMARTASSEMBLY_ID=
VITE_ERC20_TOKEN_ADDRESS=
```

These variables must be set as follows:

- **`VITE_ITEM_OUT_ID`**: This should match the `ITEM_OUT_ID` from `./packages/contracts/.env`.
- **`VITE_ITEM_IN_ID`**: This should match the `ITEM_IN_ID` from `./packages/contracts/.env`.
- **`VITE_SMARTASSEMBLY_ID`**: This should match the `SSU_ID` you set in `./packages/contracts/.env`.
- **`VITE_ERC20_TOKEN_ADDRESS`**: Use the ERC20 token address from the contract deployment step.

By ensuring these values match those in the `contracts` folder, the client will correctly interface with the on-chain environment.

### Step 8: Running and Testing the Client

Once the client is running, you can interact with the system through the browser interface. This step allows you to simulate and test interactions like purchasing items, monitoring transactions, and observing live contract behavior.

### Troubleshooting

If you encounter any issues, refer to the troubleshooting tips below:

1. **World Address Mismatch**: Double-check that the `WORLD_ADDRESS` is correctly updated in the `contracts/.env` file. Make sure you are deploying contracts to the correct world.
   
2. **Anvil Instance Conflicts**: Ensure there is only one running instance of Anvil. The active instance should be initiated via the `docker compose up -d` command. Multiple instances of Anvil may cause unexpected behavior or deployment errors.

3. **Item Limits**: Be cautious not to attempt purchasing more items than have been generated via the `mock-data` script. The number of available items is controlled by `MockSsuData.s.sol`, so ensure this script has been properly executed.

4. **Environment Variable Consistency**: Confirm that the environment variables in the client `.env` file match the values set up in `./packages/contracts/.env`. Misalignment between these variables can cause the client to fail when interacting with the contract.

5. **Connected accounts**: Confirm the connected account for the role that you are acting as: owner or player. Certain actions, such as configuring smart assemblies, are restricted to only owners or only players. Attempting to call actions while in the wrong roles might cause functions to fail when interacting with the contract.

### Still having issues?
If you are still having issues, then visit [the documentation website](https://docs.evefrontier.com/Troubleshooting) for more general troubleshooting tips.