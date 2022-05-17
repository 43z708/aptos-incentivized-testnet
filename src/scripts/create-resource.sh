. ./.env

aws s3api create-bucket --bucket $AWS_BUCKET_NAME --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
terraform init
terraform workspace new testnet
terraform workspace list
terraform apply
