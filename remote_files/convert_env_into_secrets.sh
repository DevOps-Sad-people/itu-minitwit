#!/bin/bash

# Path to your .env file
ENV_FILE=".env"

# Read each line from the .env file
while IFS='=' read -r key value; do
  # Skip lines that are comments or empty
  if [[ -z "$key" || "$key" == \#* ]]; then
    continue
  fi

  # Remove potential surrounding quotes (like in 'value' or "value")
  value=$(echo "$value" | sed "s/^['\"]//g" | sed "s/['\"]$//g")

  # Create a Docker secret for each key-value pair
  echo "$value" | docker secret create "$key" -
done < "$ENV_FILE"

echo "Docker secrets created successfully from .env"
