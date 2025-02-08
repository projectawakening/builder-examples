ENV_FILE="./.env"
ENV_SAMPLE_FILE="./.envsample"

ENV_CLIENT_FILE="../client/.env"
ENV_CLIENT_SAMPLE_FILE="../client/.envsample"

WORLD_ADDRESS="0x8a791620dd6260079bf849dc5567adc3f2fdc318"
CHAIN_ID="31337"
RPC_URL="http://127.0.0.1:8545"

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

printf "${YELLOW}[CONTRACTS]${RESET}\n"

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $ENV_FILE from sample .env file as it did not exist \n\n"
fi

set_content "WORLD_ADDRESS" $WORLD_ADDRESS $ENV_FILE "$SERVER World Address"
set_content "CHAIN_ID" $CHAIN_ID $ENV_FILE "Garnet Chain ID"
set_content "RPC_URL" $RPC_URL $ENV_FILE "$SERVER RPC URL"

printf "\n${YELLOW}[CLIENT]${RESET}\n"

if [ ! -f  $ENV_CLIENT_FILE ]; then
    cp $ENV_CLIENT_SAMPLE_FILE $ENV_CLIENT_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $ENV_CLIENT_FILE from sample .env file as it did not exist \n\n"
fi

set_content "VITE_CHAIN_ID" $CHAIN_ID $ENV_CLIENT_FILE "Garnet Chain ID"