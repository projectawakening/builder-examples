# Frontier Building Tool

## Introduction
The Frontier Building Tool helps with setting environment and general variables for Buidling in Frontier without having to dig through files or find the correct information.

## Usage
You can use the tool by using eve-frontier <strong>[plugin]</strong>. The plugins are listed below with their function.
```bash
eve-frontier namespace
```

## Plugins
### - Assembly-Scaffold-Config
Sets the assembly scaffold .env values for:
- SSU ID

### - Gate-Config
Sets the Smart Gate example .env values for:
- Source Smart Gate ID
- Destination Smart Gate ID
- Allowed Tribe ID

### - Local
Sets .env values to the local chain values:
- World Address
- Chain ID
- RPC URL

### - Namespace
Sets the namespace in:
- contracts/src/systems/constants.sol
- contracts/mud.config.ts

### - Private-Key
Sets the private key for your .env

### - SSU-Config
Sets the Smart Storage Unit example .env values for:
- SSU ID
- Item In ID
- Item Out ID
- In Ratio
- Out Ratio

### - Stillness
Fetches the most up-to-date stillness config values and sets them to the .env for:
- World Address
- Chain ID
- RPC URL

### - Turret-Config
Sets the Smart Turret example .env values for:
- Smart Turret ID
- Allowed Tribe ID

## Want to add a new plugin?
