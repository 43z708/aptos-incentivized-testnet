# ローカルに実行環境を用意

docker-compose up -d

# docker 内にログイン

docker-compose exec ubuntu bash

# AWS 上に必要なリソースを作成

./scripts/terraform.sh && ./scripts/create-resource.sh

# node を起動

./scripts/generate.sh

# node の状態を確認

kubectl get pods
