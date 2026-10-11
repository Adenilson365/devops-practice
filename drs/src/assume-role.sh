#!/bin/bash

set -euo pipefail

if [ -f "./.credentials-commands.sh" ]; then
  > ./.credentials-commands.sh
  
else
  touch ./.credentials-commands.sh
fi

if [ -z "$ASSUME_ROLE_ARN" ]; then
  echo "ASSUME_ROLE_ARN is not set. Please set it before running this script."
  exit 1
fi

ASSUME_ROLE_ARN="${ASSUME_ROLE_ARN:-}"
ASSUME_ROLE_SESSION_NAME="${ASSUME_ROLE_SESSION_NAME:-drs}"
ASSUME_ROLE_DURATION="${ASSUME_ROLE_DURATION:-3600}"

aws sts assume-role \
  --role-arn "$ASSUME_ROLE_ARN" \
  --role-session-name "$ASSUME_ROLE_SESSION_NAME" \
  --duration-seconds "$ASSUME_ROLE_DURATION" \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text | {
    read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN
  }

echo export AWS_ACCESS_KEY_ID='"'$AWS_ACCESS_KEY_ID'"' > .credentials-commands.sh

echo export AWS_SECRET_ACCESS_KEY='"'$AWS_SECRET_ACCESS_KEY'"' >> .credentials-commands.sh
echo export AWS_SESSION_TOKEN='"'$AWS_SESSION_TOKEN'"' >> .credentials-commands.sh

echo " Export VBox commands to .credentials-commands.sh"
echo -e "\n\n" >> .credentials-commands.sh
echo VBoxManage controlvm '$VM' \
  keyboardputstring '"'${AWS_ACCESS_KEY_ID}'"' >> .credentials-commands.sh
echo -e "\n" >> .credentials-commands.sh
echo VBoxManage controlvm '$VM' \
  keyboardputstring '"'$AWS_SECRET_ACCESS_KEY'"' >> .credentials-commands.sh
echo -e "\n" >> .credentials-commands.sh
echo VBoxManage controlvm '$VM' \
  keyboardputstring '"'$AWS_SESSION_TOKEN'"' >> .credentials-commands.sh

export TF_VAR_local_ip=$(curl -4 ifconfig.me)