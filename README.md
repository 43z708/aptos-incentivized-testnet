# What you need

1. AWS

-   IAM for aws cli

2. Local

-   git
-   docker
-   docker-compose

# Importing source code into local environment

```
git clone https://github.com/43z708/aptos-incentivized-testnet.git
cd aptos-incentivized-testnet
cp src/.env.example src/.env
vi src/.env
```

Edit appropriately.
Press "Esc", ":wq" and "Enter"

# Prepare local execution environment

docker-compose up -d

# Login in docker container

docker-compose exec ubuntu bash

# Create necessary resources on AWS and start nodes

./scripts/start.sh

# Check node status(require few minutes)

kubectl get pods
