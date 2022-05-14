FROM ubuntu:20.04
WORKDIR /root/
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# ENV PATH="/root/bin:$PATH"


RUN apt-get update && apt-get install -y \
    ca-certificates curl unzip gcc pkg-config libclang-dev openssl libssl-dev &&\
    curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/root/.cargo/bin:$PATH"

    # install aptos cli
RUN    cargo install --git https://github.com/aptos-labs/aptos-core.git aptos --tag aptos-cli-latest


# RUN apt update && apt install -y unzip wget &&\
#     rm -rf /var/lib/apt/lists/*
# RUN wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip && unzip aptos-cli-0.1.1-Ubuntu-x86_64.zip && mv aptos-cli-0.1.1-Ubuntu-x86_64/aptos ~/bin/ && chmod +x ~/bin/aptos
# RUN    aptos help

    # install terraform
RUN    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - &&\
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" &&\
    apt-get update && apt-get install terraform &&\
    # install kubernetes
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&\
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" &&\
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check &&\
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&\
    # install aws cli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
    unzip awscliv2.zip &&\
    ./aws/install -i /usr/local/aws-cli -b /usr/bin

COPY ./.env .
COPY ./credentials.sh .
RUN chmod +x credentials.sh &&\
    ./credentials.sh

RUN export WORKSPACE=testnet &&\
    mkdir -p ~/$WORKSPACE &&\
    cd ~/$WORKSPACE

WORKDIR /root/$WORKSPACE

COPY ./main.tf .
COPY ./.env .
COPY ./bucket.sh .

RUN chmod +x bucket.sh &&\
    ./bucket.sh

RUN terraform plan -var-file=.env &&\
    terraform workspace new $WORKSPACE &&\
# This command will list all workspaces
    terraform workspace list &&\
    terraform apply