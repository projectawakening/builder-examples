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
    read -p "Please insert your $1: " INPUT
    local MIN_LENGTH="$2"
    local MAX_LENGTH="$3"
    while true 
    do
        if [[ -z "$INPUT" ]]; then
            read -p "You did not input anything. Please insert your $1: " INPUT
        else
            if [[ ${#INPUT} -ge $MIN_LENGTH ]]; then
                if [[ ${#INPUT} -le $MAX_LENGTH ]]; then
                    break;
                else
                    read -p "Inputted $1 was too long. Please insert your $1: " INPUT
                fi
            else
                read -p "Inputted $1 was not long enough. Please insert your $1: " INPUT
            fi
        fi
    done

    echo $INPUT
}

PRIVATE_KEY=$(validate_input "Private Key" "2" "80")

if [[ $PRIVATE_KEY == 'default' ]]; then
    PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
    SOURCE_GATE_ID=23563565629941518662089712946553773054394767785169002865278787679356860010098
    DESTINATION_GATE_ID=23563565629941518662089712946553773054394767785169002865278787679356860010098
    ALLOWED_CORP_ID=12345
else
    SOURCE_GATE_ID=$(validate_input "Source Gate ID" "2" "80")
    DESTINATION_GATE_ID=$(validate_input "Destination Gate ID" "2" "80")
    ALLOWED_CORP_ID=$(validate_input "Allowed Corp ID" "2" "30")
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

    $SED_CMD "${SED_OPTS[@]}" "s/^${SEARCH}=.*/${SEARCH}=${CONTENT} #${COMMENT}/" "$FILE"

    printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}${SEARCH}${RESET} in ${YELLOW}${FILE}${RESET}\n"
}

printf "\n"

set_content "PRIVATE_KEY" $PRIVATE_KEY $ENV_FILE "Private Key"
set_content "TEST_PLAYER_PRIVATE_KEY" $PRIVATE_KEY $ENV_FILE "Test Player Private Key"
set_content "SOURCE_GATE_ID" $SOURCE_GATE_ID $ENV_FILE "Smart Gate the player wants to jump from"
set_content "DESTINATION_GATE_ID" $DESTINATION_GATE_ID $ENV_FILE "Smart Gate the player wants to jump to"
set_content "ALLOWED_CORP_ID" $ALLOWED_CORP_ID $ENV_FILE "The corporation that members are able to use the gate"

printf "\n"