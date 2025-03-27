#Files
ENV_FILE="./.env"
ENV_SAMPLE_FILE="./.envsample"

MUD_CONFIG_FILE="mud.config.ts"
CONSTANTS_FILE="src/systems/constants.sol"
CLIENT_ENTITY_VIEW_FILE="../client/src/components/EntityView.tsx"

#Colours
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

NAMESPACE=$(validate_input "Namespace" "2" "14")

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

printf "\n"

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $ENV_FILE from sample .env file as it did not exist \n\n"
fi

$SED_CMD $SED_OPTS "s/^bytes14 constant SMART_TURRET_DEPLOYMENT_NAMESPACE.*/bytes14 constant SMART_TURRET_DEPLOYMENT_NAMESPACE = \"$NAMESPACE\";/" "$CONSTANTS_FILE"

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}SMART_TURRET_DEPLOYMENT_NAMESPACE${RESET} in ${YELLOW}$CONSTANTS_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} \n"

$SED_CMD "${SED_OPTS[@]}" "s/^[[:space:]]*namespace:.*/  namespace: \"$NAMESPACE\",/" "$MUD_CONFIG_FILE"

printf "${GREEN}[COMPLETED]${RESET} Set ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} and ${YELLOW}namespace${RESET} in ${YELLOW}$MUD_CONFIG_FILE${RESET} \n"
