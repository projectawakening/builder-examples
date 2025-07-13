<div align="center">
  <img src="readme-imgs/evefrontier.png" alt="EVE Frontier" width="800"/>
  
  # EVE Frontier Builder Examples
  
  🚀 Learn to build in EVE Frontier with examples and guides.
  
  [![Documentation](https://img.shields.io/badge/docs-evefrontier-blue)](https://docs.evefrontier.com/)
  [![Discord](https://img.shields.io/badge/join-discord-7289DA)](https://discord.gg/evefrontier)
  [![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
</div>

## Welcome to EVE Frontier Building!
Welcome, this repository contains guides and examples to get started building on [EVE Frontier](https://evefrontier.com/en). For more information, you can visit https://docs.evefrontier.com/. 

To start building, follow the steps below to setup your local development tools and environment. If you already have the tools, make sure they are the correct version as otherwise you may have difficulties running the examples and building.

## Table of Contents

1. [Installing general tools](#step-1-installing-general-tools)
   - [Installing Git](#installing-git)
   - [Installing Node Version Manager](#installing-node-version-manager) 
   - [Installing PNPM](#installing-pnpm)
   - [Installing Foundry + Forge](#installing-foundry--forge)
2. [Setting up your environment](#step-2-setting-up-your-environment)
   - [Prerequisites](#prerequisites)
   - [Deploying world contracts into a local node](#deploying-world-contracts-into-a-local-node)
3. [Start Building!](#step-3-start-building)

--- 

### Step 1: Installing general tools
Before you get started you need to either install, or make sure you have the required tools. Install these tools for Linux, if you use a different OS then visit [Tools Setup](https://docs.evefrontier.com/Tools) and follow the guide for your operating system.

#### Installing Git
Install Git through [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). 

To confirm Git has been installed run:
```bash
git --version
```

#### Installing Node Version Manager
Install NVM using this command:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash && source ~/.bashrc
```

#### Installing Node
Install Node version 20 by using this command:
```bash
nvm install 20
```

#### Installing PNPM
Install PNPM, which is used as a more efficient version of NPM with:
```bash
npm install -g pnpm
```

### Installing Foundry + Forge
Install foundry and restart the shell with:
```bash
curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc
```

Run the below command to install forge, cast, anvil and chisel:
```bash
foundryup
```

### Step 2: Setting up your environment:
This guide will walk you through setting up a local environment for running a local Anvil node, deploying world contracts using Docker, and pulling ABIs.

#### Prerequisites
Ensure you have **Docker** installed on your system: [Installation Guide](https://docs.docker.com/get-docker/)

#### Deploying world contracts into a local node.
We have provided a docker compose file which bundles the running of the local node/world and deploying the world chain contracts to simulate the existing world. Run that with the command:

```bash
docker compose up -d
```

![alt text](readme-imgs/docker-success.png)

Monitor the progress of the world deployment with:

```bash
docker compose logs -f world-deployer
```

Once deployment is complete, you should see an output similar to the one below. Make sure to copy the world contract address and save it for future reference.

![alt text](readme-imgs/docker-deployment.png)

#### Retrieving world ABIs (Optional)
You can also retrieve the world abis and save them to the root directory from the deployment by running:

```bash
docker compose cp world-deployer:/monorepo/abis .
```

### Step 3: Start Building!

Now that your local tools and development environment is set up, you're ready to start building! 

To begin, navigate to the desired example directory then follow the instructions outlined in its README file. For more information on Smart Assemblies you can visit the [Smart Assemblies Documentation](https://docs.evefrontier.com/SmartAssemblies).

```bash
cd smart-storage-unit
cat readme.md
```

## Example Projects

### [📦 Smart Storage Unit](./smart-storage-unit/readme.md)
Create a SSU vending machine for item trading

### [🎯 Smart Turret](./smart-turret/readme.md)
Configure a Smart Turret with a custom strategy

### [🚪 Smart Gate](./smart-gate/readme.md)
Control access to a Smart Gate based on Tribe membership

## Need Help? 

[![Documentation](https://img.shields.io/badge/📚_Documentation-Visit_Docs-blue)](https://docs.evefrontier.com/)
[![Smart Assemblies](https://img.shields.io/badge/🔧_Smart_Assemblies-Read_Guide-orange)](https://docs.evefrontier.com/SmartAssemblies)
[![Community](https://img.shields.io/badge/💬_Discord-Join_Community-7289DA)](https://discord.gg/evefrontier)

## License

[MIT License](LICENSE)