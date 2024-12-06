ENV_FILE="./.env"
WORLD_ADDRESS="0x972bfea201646a87dc59f042ad91254628974f0d"
CHAIN_ID="17069"

sed -i "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$WORLD_ADDRESS #Nebula World Address/" "$ENV_FILE"
sed -i "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Garnet Chain ID/" "$ENV_FILE"

echo "Updated environment variables in .env to match Nebula!"