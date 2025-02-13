#Files
ENV_FILE="./packages/contracts/.env"
ENV_SAMPLE_FILE="./packages/contracts/.envsample"

if [ ! -f  $ENV_FILE ]; then
    cp $ENV_SAMPLE_FILE $ENV_FILE
    printf "\n${GREEN}[COMPLETED]${RESET} Created $ENV_FILE from sample .env file as it did not exist \n\n"
fi