ENV_FILE="./.env"
WORLD_ADDRESS="0x8a791620dd6260079bf849dc5567adc3f2fdc318"
CHAIN_ID="31337"

sed -i "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$WORLD_ADDRESS #Local World Address/" "$ENV_FILE"
sed -i "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Local Chain ID/" "$ENV_FILE"

echo "Updated environment variables in .env to match Local!"