# Frontier Building Tool

## Introduction
The Frontier Building Tool helps with setting environment and general variables for Building in Frontier without having to dig through files or find the correct information.

## Usage
You can use the tool by using eve-frontier <strong>[plugin]</strong>. The plugins are listed below with their function.
```bash
eve-frontier namespace
```

In the examples, they can also be called by using for example:
```bash
pnpm set-namespace
```

> [!NOTE]
> Check the documentation or package.json for how to call it in the example if you use the pnpm "command"

## Plugins
### - assembly-scaffold-config
Sets the assembly scaffold .env values for:
- SSU ID

### - gate-config
Sets the Smart Gate example .env values for:
- Source Smart Gate ID
- Destination Smart Gate ID
- Allowed Tribe ID

### - local
Sets .env values to the local chain values:
- World Address
- Chain ID
- RPC URL

### - namespace
Sets the namespace in:
- contracts/src/systems/constants.sol
- contracts/mud.config.ts

### - private-key
Sets the private key for your .env

### - ssu-config
Sets the Smart Storage Unit example .env values for:
- SSU ID
- Item In ID
- Item Out ID
- In Ratio
- Out Ratio

### - stillness
Fetches the most up-to-date stillness config values and sets them to the .env for:
- World Address
- Chain ID
- RPC URL

### - turret-config
Sets the Smart Turret example .env values for:
- Smart Turret ID
- Allowed Tribe ID
