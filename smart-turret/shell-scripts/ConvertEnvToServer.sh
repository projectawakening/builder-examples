ENV_FILE="./.env"
ENV_SAMPLE_FILE="./.envsample"

SERVER=$1

#COLORS
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

API_URL="blockchain-gateway-$SERVER.test.tech.evefrontier.com"

if [[ $SERVER = "stillness" ]]; then
    API_URL="blockchain-gateway-$SERVER.live.tech.evefrontier.com"
fi

API_URL="https://${API_URL}"

response=$(curl -s -H "Accept: application/json" "$API_URL/config")
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

function set_content(){
    local SEARCH="$1"
    local CONTENT="$2"
    local FILE="$3"
    local COMMENT="$4"

    if [[ "$CONTENT" == *"://"* ]]; then
        CONTENT="\"$CONTENT\""
    fi

    $SED_CMD "${SED_OPTS[@]}" "s|^${SEARCH}=.*|${SEARCH}=${CONTENT} #${COMMENT}|" "$FILE"

    printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}${SEARCH}${RESET} in ${YELLOW}${FILE}${RESET}\n"
}

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $ENV_FILE from sample .env file as it did not exist \n\n"
fi

set_content "WORLD_ADDRESS" $world_address $ENV_FILE "$SERVER World Address"
set_content "CHAIN_ID" $CHAIN_ID $ENV_FILE "Garnet Chain ID"
set_content "RPC_URL" $RPC_URL $ENV_FILE "$SERVER RPC URL"