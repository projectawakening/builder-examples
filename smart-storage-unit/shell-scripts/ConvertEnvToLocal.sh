ENV_FILE="./.env"
ENV_SAMPLE_FILE="./.envsample"

CLIENT_ENV_FILE="../client/.env"
CLIENT_ENV_SAMPLE_FILE="../client/.envsample"

WORLD_ADDRESS="0x8a791620dd6260079bf849dc5567adc3f2fdc318"
CHAIN_ID="31337"
RPC_URL="http://127.0.0.1:8545"
WS_URL="http://127.0.0.1:8545"
SERVER="Local"

#COLORS
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

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
fi

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
fi

set_content "WORLD_ADDRESS" $WORLD_ADDRESS $ENV_FILE "$SERVER World Address"
set_content "CHAIN_ID" $CHAIN_ID $ENV_FILE "Local Anvil Chain ID"
set_content "RPC_URL" $RPC_URL $ENV_FILE "$SERVER RPC URL"

if [ ! -f  $CLIENT_ENV_FILE ]; then
    cp $CLIENT_ENV_SAMPLE_FILE $CLIENT_ENV_FILE
fi

set_content "VITE_CHAIN_ID" $CHAIN_ID $CLIENT_ENV_FILE "Local Anvil Chain ID"
set_content "VITE_GATEWAY_HTTP" $RPC_URL $CLIENT_ENV_FILE "Gateway HTTP URL"
set_content "VITE_GATEWAY_WS" $WS_URL $CLIENT_ENV_FILE "Local Gateway WebSocket URL"
