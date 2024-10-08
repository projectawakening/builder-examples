FROM node:18.12.1

RUN mkdir -p /usr/src/builder-examples
WORKDIR /usr/src/builder-examples
RUN apt-get install -y git curl

RUN npm install -g pnpm@8

RUN curl -L https://foundry.paradigm.xyz | bash && \
    export PATH="$HOME/.foundry/bin:$PATH" && \
    foundryup && \
    echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> /root/.bash_profile

ENV PATH="/root/.foundry/bin:${PATH}"

ENTRYPOINT ["tail", "-f", "/dev/null"]