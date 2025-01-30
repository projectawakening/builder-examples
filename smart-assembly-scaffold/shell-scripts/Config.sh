ENV_FILE="./.env"
ENV_SAMPLE_FILE="./.envsample"

CLIENT_ENV_FILE="../client/.env"
CLIENT_ENV_SAMPLE_FILE="../client/.envsample"

WORLD_ADDRESS="0x8a791620dd6260079bf849dc5567adc3f2fdc318"
CHAIN_ID="31337"
RPC_URL="http://127.0.0.1:8545"
SERVER="Local"

#COLORS
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

function validate_input(){
    local INPUT=""
    read -p $'\e[0mPlease type your \e[1;33m'"$1"$': \e[0m' INPUT

    local MIN_LENGTH="$2"
    local MAX_LENGTH="$3"
    while true 
    do
        if [[ -z "$INPUT" ]]; then
            read -p $'\e[38;5;202m[ERROR]\e[0m You did not enter anything. Please type your \e[1;33m'"$1"$': \e[0m' INPUT
        else
            if [[ ${#INPUT} -ge $MIN_LENGTH ]]; then
                if [[ ${#INPUT} -le $MAX_LENGTH ]]; then
                    break;
                else
                    read -p $'\e[38;5;202m[ERROR]\e[0m \e[1;33m'"$1"$'\e[0m was too long. Please type your \e[1;33m'"$1"$': \e[0m' INPUT
                fi
            else
                read -p $'\e[38;5;202m[ERROR]\e[0m \e[1;33m'"$1"$'\e[0m was too short. Please type your \e[1;33m'"$1"$': \e[0m' INPUT
            fi
        fi
    done

    echo $INPUT
}

PRIVATE_KEY=$(validate_input "Private Key" "2" "60")

if [[ $PRIVATE_KEY == 'default' ]]; then
    PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    SSU_ID="23563565629941518662089712946553773054394767785169002865278787679356860010098"
else
    SSU_ID=$(validate_input "SSU ID" "2" "60")
fi

SED_CMD="sed"
if [[ $OSTYPE == 'darwin'* ]]; then
    SED_OPTS=(-i '')
else
    SED_OPTS=(-i)
fi

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
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

set_content "PRIVATE_KEY" $PRIVATE_KEY $ENV_FILE "Private Key"
set_content "SSU_ID" $SSU_ID $ENV_FILE "Smart Storage Unit ID"

printf "\n${YELLOW}[CLIENT]${RESET}\n"

if [ ! -f  $CLIENT_ENV_FILE ]; then
    cp $CLIENT_ENV_SAMPLE_FILE $CLIENT_ENV_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $CLIENT_ENV_FILE from sample .env file as it did not exist \n\n"
fi

set_content "VITE_SMARTASSEMBLY_ID" $SSU_ID $CLIENT_ENV_FILE "Smart Assembly ID"