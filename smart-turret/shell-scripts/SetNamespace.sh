#Files
ENV_FILE=".env"
MUD_CONFIG_FILE="mud.config.ts"
CONSTANTS_FILE="src/systems/constants.sol"

#Colours
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
                    read -p "Inputted namespace was too long. Please insert your $1: " INPUT
                fi
            else
                read -p "Inputted namespace was not long enough. Please insert your $1: " INPUT
            fi
        fi
    done

    echo $INPUT
}

NAMESPACE=$(validate_input "Namespace" "2" "14")

SED_CMD="sed"
if [[ $OSTYPE == 'darwin'* ]]; then
    SED_OPTS="-i ''"
else
    SED_OPTS="-i"
fi

$SED_CMD $SED_OPTS "s/^bytes14 constant SMART_TURRET_DEPLOYMENT_NAMESPACE.*/bytes14 constant SMART_TURRET_DEPLOYMENT_NAMESPACE = \"$NAMESPACE\";/" "$CONSTANTS_FILE"
$SED_CMD $SED_OPTS "s/^  namespace.*/  namespace: \"$NAMESPACE\",/" "$MUD_CONFIG_FILE"

printf "\n${GREEN}[COMPLETED]${RESET} Set ${YELLOW}DEPLOYMENT_NAMESPACE${RESET} in ${YELLOW}$CONSTANTS_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} \n\n"