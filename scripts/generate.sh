#!/bin/bash

. ./.env

# Set variables
export WORKSPACE=testnet

export VALIDATOR_ADDRESS="$(kubectl get svc ${WORKSPACE}-aptos-node-validator-lb --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

export FULLNODE_ADDRESS="$(kubectl get svc ${WORKSPACE}-aptos-node-fullnode-lb --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

# Generate key pairs
aptos genesis generate-keys --output-dir ~/$WORKSPACE

# Configure validator information
aptos genesis set-validator-configuration --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE --username $VALIDATOR_NAME --validator-host $VALIDATOR_ADDRESS:6180 --full-node-host $FULLNODE_ADDRESS:6182

# Create layout YAML file, which defines the node in the validatorSet.
cat <<EOF > layout.yaml
---
root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
users:
    - $VALIDATOR_NAME
chain_id: 23
EOF

# Download AptosFramework Move bytecodes into a folder named framework
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip

unzip framework.zip

# Compile genesis blob and waypoint
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE

# Insert genesis.blob, waypoint.txt and the identity files as secret into k8s cluster
kubectl create secret generic ${WORKSPACE}-aptos-node-genesis-e1 \
    --from-file=genesis.blob=genesis.blob \
    --from-file=waypoint.txt=waypoint.txt \
    --from-file=validator-identity.yaml=validator-identity.yaml \
    --from-file=validator-full-node-identity.yaml=validator-full-node-identity.yaml
