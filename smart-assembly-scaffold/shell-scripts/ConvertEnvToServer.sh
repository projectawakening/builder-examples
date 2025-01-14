ENV_FILE=".env"
CLIENT_ENV_FILE="../client/.env"

SERVER=$1

#COLORS
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

API_URL="https://blockchain-gateway-$SERVER.nursery.reitnorf.com/config"

VITE_GATEWAY_HTTP="https://blockchain-gateway-nebula.test.tech.evefrontier.com" 
VITE_GATEWAY_WS="wss://blockchain-gateway-nebula.test.tech.evefrontier.com"

if [[ $SERVER = "stillness" ]]; then
    API_URL="https://blockchain-gateway-$SERVER.live.tech.evefrontier.com/config"
    VITE_GATEWAY_HTTP="https://blockchain-gateway-$SERVER.live.tech.evefrontier.com" 
    VITE_GATEWAY_WS="wss://blockchain-gateway-$SERVER.live.tech.evefrontier.com"
fi

response=$(curl -s -H "Accept: application/json" "$API_URL")
world_address=$(echo "$response" | grep -o '"world":{[^}]*}' | grep -o '"address":"[^"]*"' | sed 's/"address":"//;s/"//')
RPC_URL=$(echo "$response" | grep -o '"default":{[^}]*}' | grep -o '"http":"[^"]*"' | sed 's/"http":"//;s/"//')

CHAIN_ID="17069"

# If the API call didn't work - use a known world address for Stillness or Nova
if [[ -z "$world_address" ]]; then
    if [[ $SERVER = "stillness" ]]; then
        world_address="0x7fe660995b0c59b6975d5d59973e2668af6bb9c5"
    else
        world_address="0x972bfea201646a87dc59f042ad91254628974f0d"
    fi    
fi

# If the API call didn't work - use a known RPC URL for Stillness or Nova
if [[ -z "$RPC_URL" ]]; then
    RPC_URL="https://garnet-rpc.dev.evefrontier.tech"
fi

SED_CMD="sed"
if [[ $OSTYPE == 'darwin'* ]]; then
    SED_OPTS=(-i '')
else
    SED_OPTS=(-i)
fi

if [ ! -e $CLIENT_ENV_FILE ]
then
    cp "../client/.envsample" $CLIENT_ENV_FILE
    printf "${GREEN}[COMPLETED]${RESET} Created ${YELLOW}.env${RESET} file in ${YELLOW}packages/client${RESET} from ${YELLOW}.envsample${RESET} as it did not exist\n\n"
fi

printf "${YELLOW}[CONTRACTS]${RESET}\n\n"

$SED_CMD "${SED_OPTS[@]}" "s/^WORLD_ADDRESS=.*/WORLD_ADDRESS=$world_address #${SERVER} World Address/" "$ENV_FILE"
$SED_CMD "${SED_OPTS[@]}" "s/^CHAIN_ID=.*/CHAIN_ID=$CHAIN_ID #Garnet Chain ID/" "$ENV_FILE"
$SED_CMD "${SED_OPTS[@]}" "s|^RPC_URL=.*|RPC_URL=\"${RPC_URL}\" #${SERVER} RPC URL|" "$ENV_FILE"

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}WORLD_ADDRESS${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}${SERVER}${RESET} ${YELLOW}[$world_address]${RESET} \n\n"
printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}RPC_URL${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}${SERVER}${RESET} ${YELLOW}[$RPC_URL]${RESET}\n\n"

printf "${YELLOW}[CLIENT]${RESET}\n\n"

$SED_CMD "${SED_OPTS[@]}" "s|^VITE_GATEWAY_HTTP=.*|VITE_GATEWAY_HTTP=${VITE_GATEWAY_HTTP} # World API for $SERVER|" "$CLIENT_ENV_FILE"
$SED_CMD "${SED_OPTS[@]}" "s|^VITE_GATEWAY_WS=.*|VITE_GATEWAY_WS=${VITE_GATEWAY_WS} # Web Socket World API for $SERVER|" "$CLIENT_ENV_FILE"

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}VITE_GATEWAY_HTTP${RESET} in ${YELLOW}packages/client/.env${RESET} to ${YELLOW}${SERVER}${RESET} ${YELLOW}[$VITE_GATEWAY_HTTP]${RESET}\n\n"
printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}VITE_GATEWAY_WS${RESET} in ${YELLOW}packages/client/.env${RESET} to ${YELLOW}${SERVER}${RESET} ${YELLOW}[$VITE_GATEWAY_WS]${RESET}\n\n"