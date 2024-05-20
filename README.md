# Builder Examples 

## Using this Repository 

To run the examples in this repository, first visit the World Chain Contract repository [here](https://github.com/projectawakening/world-chain-contracts/tree/stable-release) to deploy a canonical World contract that we can interact with. 

### Deploy World Contract 
In `world-chain-contracts` repository, run the following: 

```
git clone https://github.com/projectawakening/world-chain-contracts/tree/stable-release
pnpm run dev 
``` 

In your terminal, under the `.scripts/deploy-all.sh` process, wait a few seconds for all the contracts to compile and deploy. 

Obtain the world contract address in the terminal, or in the `worlds.json` file created in the root directory. 

![World deployment script](./world-deployment.png)

### Deploying Builder Examples 

Copy the world contract address from before. 

Clone and deploy the contracts in this repository as follows, replacing the <ADDRESS> field with the address of the world contract we just deployed. 

```
git clone https://github.com/projectawakening/builder-examples
pnpm run deploy:local --worldAddress <ADDRESS>
``` 