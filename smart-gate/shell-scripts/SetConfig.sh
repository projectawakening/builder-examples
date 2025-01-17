ENV_FILE="./.env"
CLIENT_ENV_FILE="../client/.env"
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

SOURCE_GATE_ID=$(validate_input "Source Gate ID" "2" "80")
DESTINATION_GATE_ID=$(validate_input "Destination Gate ID" "2" "80")
ALLOWED_CORP_ID=$(validate_input "Allowed Corp ID" "2" "30")

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

    $SED_CMD "${SED_OPTS[@]}" "s/^${SEARCH}=.*/${SEARCH}=${CONTENT} #${COMMENT}/" "$FILE"

    printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}${SEARCH}${RESET} in ${YELLOW}${FILE}${RESET}\n"
}

printf "\n"

set_content "SOURCE_GATE_ID" $SOURCE_GATE_ID $ENV_FILE "Smart Gate the player wants to jump from"
set_content "DESTINATION_GATE_ID" $DESTINATION_GATE_ID $ENV_FILE "Smart Gate the player wants to jump to"
set_content "ALLOWED_CORP_ID" $ALLOWED_CORP_ID $ENV_FILE "The corporation that members are able to use the gate"

printf "\n"