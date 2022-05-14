source ./.env

aws s3api create-bucket --bucket $AWS_BUCKET_NAME --region $AWS_DEFAULT_REGION