FROM ubuntu:20.04
ENV TZ=Asia/Tokyo
ARG AWS_DEFAULT_REGION=""
ARG AWS_BUCKET_NAME=""

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone &&\
    apt update && apt install -y git unzip wget curl gnupg lsb-release software-properties-common &&\
    rm -rf /var/lib/apt/lists/* &&\
    # install aptos-cli
    wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip && unzip aptos-cli-0.1.1-Ubuntu-x86_64.zip && mv aptos /usr/local/bin/ && chmod +x /usr/local/bin/aptos && ln -s /usr/local/bin/aptos /usr/bin/aptos &&\
    # install terraform
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - &&\
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
    ./aws/install -i /usr/local/aws-cli -b /usr/local/bin &&\
    mkdir -p /app/testnet

WORKDIR /app/testnet

COPY src/.env .
COPY src/scripts/ ./scripts/

RUN mkdir -p ~/.aws && chmod +x scripts/credentials.sh &&\
    ./scripts/credentials.sh &&\
    chmod +x ./scripts/terraform.sh && chmod +x ./scripts/create-resource.sh && chmod +x ./scripts/generate.sh
