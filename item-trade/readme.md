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

**Devnet Deployment**
This will deploy the contracts to the Devnet world. You can retrieve the world address through https://blockchain-gateway-oblivion.nursery.reitnorf.com/config and then replace <worldAddress> with the world address. 
```bash
pnpm deploy:garnet --worldAddress <worldAddress> 
```


eg: `pnpm deploy:local --worldAddress 0xafc8e4fd5eee66590c93feebf526e1aa2e93c6c3`

Once the deployment is successful, you'll see a screen similar to the one below. This process deploys the Item Seller Trade and a test ERC20 token required for the Item Trade. Be sure to copy the ERC20 token address and save it for future use.
![alt text](./readme-imgs/deployment.png)


### Step 1: Setup the environment variables 
Next, replace the following values in the [.env](./packages/contracts/.env) file with the values you copied earlier:

```bash
#WORLD ADDRESS COPIED FROM DOCKER LOGS
WORLD_ADDRESS=

#ERC20 TOKEN ADDRESS COPIED FROM ITEM SELLER DEPLOYMENT
ERC20_TOKEN_ADDRESS=

```

You can adjust the remaining values in the .env file as needed, based on the environment.


<details markdown="block">
<summary>Changing optional environment values</summary>

### Setting item, price and payment address
You can set the item you want to sell and the item you want to buy, the address that receives payments, the price in Wei and the enforcedMultipleForItem

```bash
##### ITEM TRADE CONFIGURATION
#ITEM IN : SALT
ITEM_IN_ID=888
#ITEM OUT : LENS
ITEM_OUT_ID=999

ERC20_TOKEN_ADDRESS=0x6563b29D32AcAdEFA83214b322bDB8055c121bd9
RECEIVER_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
##PRICE SHOULD BE IN WEI
PRICE_IN_WEI=500000000000000000
ENFORCED_ITEM_MULTIPLE=99
TOKEN_AMOUNT=275000000000000000000
```

To get the ITEM_IN_ID and ITEM_OUT_ID in devnet, you can follow these steps:

#### Step 0:
Right click your SSU, open the dapp window and copy the smart storage unit id.

> [!CAUTION]
> TODO: FINALIZE THIS SECTION.

![alt text](./readme-imgs/ssu_view.png)

#### Step 1:
Once you have your SSU ID, you can go to https://blockchain-gateway-test.nursery.reitnorf.com/smartdeployables/ssu_id (and replace ssu_id with your copied SSU ID). 

#### Step 2:
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

</details>


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