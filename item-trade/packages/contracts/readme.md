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
pnpm run deploy:local --worldAddress <worldAddress> 
```

**Devnet Deployment**
This will deploy the contracts to the Devnet world. You can retrieve the world address through https://blockchain-gateway-oblivion.nursery.reitnorf.com/config and then replace <worldAddress> with the world address. 
```bash
pnpm run deploy:devnet --worldAddress <worldAddress> 
```


eg: `pnpm run deploy:local --worldAddress 0xafc8e4fd5eee66590c93feebf526e1aa2e93c6c3`

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
pnpm run mock-data
```
This will create the on-chain SSU, fuel it, bring it online, and deposit some items into inventory and players ephemeral inventory so they can be traded in exchange for the ERC20 token.

### Step 3: Configure Item Seller 
To configure which items should be sold and purchased in return for the ERC20 token, run:

```bash
pnpm run configure-item-seller
```

You can adjust the values for the SSU_ID & INVENTORY_ITEM_ID in the .env file as needed, though they are optional.

### Step 4: Test Item Seller (Optional)
To test the purchase of an item in return for the token, execute the following command:

Note: In Devnet, ensure that the player has enough tokens to complete the purchase.

```bash
pnpm run approve
pnpm run purchase-item
```

### Step 5: Test Item Buyer (Optional)
To test the selling an item in return for the token, execute the following command:

Note: In Devnet, ensure that the player has items to sell

```bash
pnpm run sell-item
```

