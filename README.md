## Step 0: Setting up your environment:
This guide will walk you through setting up a local environment for running a local Anvil node, deploying world contracts using Docker, and pulling ABIs.

### Prerequisites
Make sure you have the **Docker** installed on your system: [Installation Guide](https://docs.docker.com/get-docker/)

### Step 0.1: Deploying world contracts into a local node.
We have provided a compose file which bundles the running of the local node and deploying the contracts together. Run that with the command
```bash
docker compose up -d
```
and monitor the progress of the world deployment with:

```bash
docker compose logs -f world-deployer
```

This will display the progress of the deployment and relevant addresses once it completes.

### Step 0.2 (Optional): Retrieveing world ABIs
You can also retrieve the world abis from the deployment by running:

```bash
docker compose cp world-deployer:/monorepo/abis .
```

