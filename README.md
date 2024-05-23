# Good Place to start 
Our work is built on [MUD](https://mud.dev/quickstart). [MUD](https://mud.dev/introduction) docs is a good place to start learning the concepts 

Thanks to the contributors of the original project!

# Smart Storage Unit (SSU) Extension
This repository serves as an illustrative example for extending in-game functionalities.

You can enhance in-game functionalities by:

- Customizing existing game features, such as configuring an SSU as a vending machine, Item Seller .
- Add or extend new features for in-game Smart-Storage Units by inheriting EVE system smart contracts and hooks. Eg: Gatekeeper SSU

Refer the [docs](https://docs.projectawakening.io/developing) for details.

 
## Example
This example demonstrates customizing an in-game SSU as a vending machine. The vending machine can be configured to determine which items go into the input bay, what is returned (vended) in the output bay, and in what ratio.


There are 2 ways you can start building. 
1. Less code / No code 
    - configure your SSU as a vending machine with the ratio you like 
2. Program your SSU 
    - make code changes to the Vending Machine smart contract and have your own logic 
    - deploy to the exsiting world
    - interact


## Less code / No code  
### Steps to Customize a SSU as a vending machine
To get started without making any code changes, follow below steps by adjusting the configuration in the [.env](./packages/contracts/.env) file and later explore making code changes and implementing new features.

### Prerequisites
- Create a SSU in-game

- this guide requires that you have an UNIX terminal on your machine, either `bash` or `zsh`.
- Ensure you have `node` Version 18 and `pnpm` installed. 
- Have basic knowledge of smart contracts and the [MUD](https://mud.dev/quick-start) framework.
- Have an IDE that supports Solidity (preferably).

## Step 0 (optional): Setting up your environment:

### For Windows users:
First you will need to install Windows Subsystem for Linux, version 2. To do that, open the command prompt and enter the command:

```bash
wsl.exe --install
```

Once that is done, you can launch the `Ubuntu` app from the _Start Menu_, which will give you access to a Linux terminal. From then on, enter the following commands to update your Linux distribution:

```bash
apt update && apt upgrade
```

### For MacOS users:
First, we need to install the CLI tools for Xcode. Run the following command in a Terminal: 

```bash
xcode-select --install
```

Then, install homebrew:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

And finally, install Z Shell (a.k.a. zsh), which is a Unix shell built on top of bash. This will solve most issue linked to disreptancies between MacOS and other Linux distributions:

```bash
brew install zsh
```

You can then close this terminal and open a new one to confirm the changes made to your terminal.

## Step 0.5: Setting up node:

If that is not done already, we need to install Node Version Manager. (See the project page on Github for more info or troubleshooting : [Node Version Manager Github](https://github.com/nvm-sh/nvm))
To do that, run either of the following cURL or Wget commands in your terminal:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash
```

```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash
```

To test if the installation went properly, verify that you can run the following command:

```bash
nvm —version
```

Now, let’s install Node Package Manager (nvm) with the following command:

```bash
nvm install 18 && nvm use 18
```

running `node --version` should return `v18.19.0`, which means your terminal is now properly set for the next steps.

Finally, install pnpm :

```bash
npm install pnpm -g
```

## Step 1: Set up the repository:

After cloning this repository on your machine, open a terminal, and change directory to the root of this repository:

```bash
cd [path-to]/builder-examples
```

Then, execute the following commands

```bash
pnpm run foundry:up

pnpm i
```

## Step 2: ENV changes:

```bash
cd packages/contracts
pnpm run build
```

Make changes to [.env](./packages/contracts/.env) to get started:
- Add your **private key** to execute smart contract transactions on-chain.
    - You can export your **private key** from EVE Vault by clicking the three dots on the main screen and there select **view private key**.
    
- The [.env](./packages/contracts/.env) file is configured by default for deployment to the playtest devnet, if you are testing locally be sure to comment out Lines 20-21 and uncomment the Local RPC parameters on Lines 16-17.

- Add your **Smart Storage Unit ID**, **item-in ID**, and **item-out ID** to configure your vending machine. Obtain ID values from either the dapp or indexer.

- **Smart Storage Unit ID (SSU ID)** is available once you have deployed an SSU in the game. 
  - Right click your Smart Storage Unit, and view the `ssu-id`.
  - **item-in ID** and **item-out ID** can be viewed in the indexer.


## Step 3: Configure SSU as Vending Machine

- Configure the vending Machine by giving your `SSU_ID` and `ITEM_IN_ID`, `ITEM_OUT_ID`, `IN_RATIO` and `OUT_RATIO` in the [.env](./packages/contracts/.env) file.
`IN_RATIO` and `OUT_RATIO` represent the required number of items put into the SSU and the resulting number of items that will come out, e.g., if `RATIO_IN`=5 and `RATIO_OUT`=1 then for every multiple of 5 `ITEM_IN`, the vending logic will output 1 `ITEM_OUT`.

NOTE: Its a prerequisite to have already deposited these items into the SSU once before configuration. This is to ensure that the game logic has updated those specific items data on-chain beforehand. Also be aware the for the vending logic to execute properly after configuration.. there must be a pre-deposited amount of `ITEM_OUT` item in the SSU to vend those items out properly. If the SSU runs out of `ITEM_OUT` items, the vending logic will fail.
  

```bash
pnpm run configure-vending-machine
```

## Step 3: Build a UI to interact with the vending machine in game

You can build a external UI or a In game to interact with your SSU by calling `executeVendingMachine()` function from the dapp.

Now, test the configuration by adding items to the input bay in-game and observe how it works. Play around, and once comfortable, delve deeper by making code changes. To understand the smart contract structure, refer to the docs and start building.


## Program your SSU 
### Customize your SSU with code changes (optional)
Note: This step is required only if you are making code changes. 

1.  Make sure you also change the `NAMESPACE` in [mudConfig.ts](./packages/contracts/mud.config.ts) L4, so that it doesn't fail trying to deploy to the old namespace.

**NOTE:** In the MUD Framework deploying new contracts is specific to a NAMESPACE for permissioning reasons. If you try to deploy to an existing namespace for which you are not the namespace owner, the deployment will fail.

2. Deploy 
  - Build locally:

```bash
pnpm tablegen && pnpm worldgen
pnpm build
```

### Deploy World Contract 
Under the `world-chain-contracts` repository, run the following: 

```
git clone https://github.com/projectawakening/world-chain-contracts
cd world-chain-contracts
pnpm run dev 
``` 

- To deploy the smart contracts to the existing world deployment by providing the correct world contract address.

```bash
pnpm run deploy:tesnet --worldAddress ${WORLD_ADDRESS}
```

4. Write Scripts to interact with it in [scripts](./packages/contracts/script/) folder. Or make use of the existing script if it is using the ratio logic and run it! 

```
pnpm run configure-ratio
```


## Running and Deploying in Local with the World Chain Contracts 
Clone the World Chain Contracts repository [here](https://github.com/projectawakening/world-chain-contracts) and deploy a canonical World contract in your local. 

1. To deploy all contract in local run, from the root of the repository 

```
pnpm run dev
```

2. In your terminal, under the `.scripts/deploy-all.sh` process, wait a few seconds for all the contracts to compile and deploy. 

Obtain the world contract address in the terminal, or in the `worlds.json` file created in the root directory. 

![World deployment script](./world-deployment.png)


3. Deploying builder example contract to World Contract

```
cd packages/contracts
```

Deploy the contracts in this repository by, replacing the ADDRESS field with the address of the world contract we just deployed. 

```
pnpm run deploy:local --worldAddress <ADDRESS>
``` 

Now you have the local chain, world contracts and builder example contracts deployed to the chain. You can play around by any building any logic. 