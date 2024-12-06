ENV_FILE="./.env"
WORLD_ADDRESS="0x1ad901bfc07872c4a2b2817f4b2468bde2083957"
CHAIN_ID="17069"

sed -i "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$WORLD_ADDRESS #Nova World Address/" "$ENV_FILE"
sed -i "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Garnet Chain ID/" "$ENV_FILE"

echo "Updated environment variables in .env to match Nova!"