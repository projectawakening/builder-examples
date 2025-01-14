# 🏗️ Smart Assembly Scaffold

## Introduction

EVE Frontier Smart Assembly Scaffold is a streamlined framework designed for interfacing with the EVE Frontier game. It focuses on providing information about basic blockchain primitives, such as smart assembly info and ownership details, without delving into further module-specific details. Built with MUD, React, Rainbowkit, TypeScript, Tailwind CSS, and Vite, it ensures efficient and scalable development. It utilizes the `example` MUD namespace for contract management.

### 🚀 User Flow

The Smart Assembly Scaffold provides a minimal example to toggle the state of an assembly on or off.

---

## 🛠️ Development & Deployment Steps

### Step 1: 🏗️ Stillness Deployment

When the contracts are ready to be deployed:

1. Navigate to contracts:
   
```bash
cd packages/contracts
```

2. Set the environment to Stillness with:

```bash
pnpm env-stillness
```

3. Set your namespace with:

```bash
pnpm set-namespace
```

4. Set your config with:

```bash
pnpm config
```

5. To deploy to Garnet:

```bash
pnpm deploy:garnet
```

### Step 2: 🌐 dApp Environment Variables and Considerations

The Smart Assembly Scaffold’s client UI (dApp) leverages a `<SmartObjectContext>` to provide read-only blockchain primitives, such as smart assembly info. These primitives require access to a deployed world instance and a corresponding World API service to function correctly. This typically means working against an environment like Nova or Stillness, where dedicated API HTTP and WebSocket endpoints are available.

By connecting to these endpoints, the dApp can stream real-time updates over WebSockets, enabling dynamic state changes and real-time feedback within your dApp. To fully realize this functionality, you’ll need properly configured environment variables that point to a running instance of the World API service.

### Step 3: 💻 Configuring dApp Environment Variables

The DApp environment variables were set in step 1, by running the **env-stillness** and **config** commands. 

The dApp uses Stash and the `useRecord` hook to fetch table data from your deployed contracts. Additionally, the World Explorer UI can be accessed to visually inspect states and updates in real time, streamlining your development and debugging workflows.

---

## 🖥️ dApp Overview

The dApp leverages MUD tooling (`@latticexyz`) and EVE World tooling (`@eveworld`) to integrate with EVE Frontier’s in-game systems. The UI dynamically updates as on-chain data changes, providing an immersive and real-time experience.

With the environment variables set correctly and the right blockchain gateway URLs in place, you’ll be able to toggle states, inspect game entities, and interact directly with the contracts deployed via your chosen environment.
