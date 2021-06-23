# RESTIC_REPOSITORY = S3 or B2 bucket url
# S3 example: s3:https://s3.amazonaws.com/bucketname
# B2 example: b2:bucketname:path/to/repo

export RESTIC_REPOSITORY="REPLACE_WITH_S3_OR_B2_BUCKET_URL"
export RESTIC_PASSWORD="REPLACE_WITH_RESTIC_REPOSITORY_PASSWORD"

# Edit EITHER the AWS or B2 credentials with your keys
# Do not enter values for both S3/B2 entries. You can only do one of them

export AWS_ACCESS_KEY_ID="REPLACE_WITH_AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="REPLACE_WITH_AWS_SECRET_ACCESS_KEY"

export B2_ACCOUNT_ID="REPLACE_WITH_B2_ACCOUNT_ID"
export B2_ACCOUNT_KEY="REPLACE_WITH_B2_ACCOUNT_KEY"

# This section is optional. Telegram messages will not work if values are not entered.

export TELEGRAM_TOKEN="REPLACE_WITH_TELEGRAM_TOKEN"
export CHAT_ID="REPLACE_WITH_TELEGRAM_CHAT_ID"
