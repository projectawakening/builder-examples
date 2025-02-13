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

$SED_CMD "${SED_OPTS[@]}" "s/^SSU_ID=.*/SSU_ID=$SSU_ID #SSU ID/" "$ENV_FILE"

if [ ! -f  $CLIENT_ENV_FILE ]; then
    cp $CLIENT_ENV_SAMPLE_FILE $CLIENT_ENV_FILE
fi

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}SSU_ID${RESET} in ${YELLOW}.env${RESET} to ${YELLOW}${SSU_ID}${RESET}\n\n"

$SED_CMD "${SED_OPTS[@]}" "s/^VITE_SMARTASSEMBLY_ID=.*/VITE_SMARTASSEMBLY_ID=$SSU_ID #SSU ID/" "$CLIENT_ENV_FILE"

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}SSU_ID${RESET} in ${YELLOW}client/.env${RESET} to ${YELLOW}${SSU_ID}${RESET}\n\n"