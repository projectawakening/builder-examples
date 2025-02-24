ENV_FILE="./.env"
ENV_SAMPLE_FILE="./.envsample"

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

SSU_ID=$(validate_input "Smart Storage Unit ID" "10" "80")
ITEM_IN_ID=$(validate_input "Item In ID" "10" "80")
ITEM_OUT_ID=$(validate_input "Item Out ID" "10" "80")
IN_RATIO=$(validate_input "Items In Ratio" "1" "30")
OUT_RATIO=$(validate_input "Items Out Ratio" "1" "30")

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

    local ESCAPED_CONTENT=$(echo "$CONTENT" | sed 's/[\/&]/\\&/g')

    $SED_CMD "${SED_OPTS[@]}" "s/^${SEARCH}=.*/${SEARCH}=${ESCAPED_CONTENT} #${COMMENT}/" "$FILE"

    printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}${SEARCH}${RESET} in ${YELLOW}${FILE}${RESET}\n"
}

printf "\n"

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $ENV_FILE from sample .env file as it did not exist \n\n"
fi

set_content "SSU_ID" $SSU_ID $ENV_FILE "Smart Storage Unit to use"
set_content "ITEM_IN_ID" $ITEM_IN_ID $ENV_FILE "Item that is bought"
set_content "ITEM_OUT_ID" $ITEM_IN_ID $ENV_FILE "Item that is sold"
set_content "IN_RATIO" $IN_RATIO $ENV_FILE "Ratio of items bought"
set_content "OUT_RATIO" $OUT_RATIO $ENV_FILE "Ratio of items sold"

printf "\n"