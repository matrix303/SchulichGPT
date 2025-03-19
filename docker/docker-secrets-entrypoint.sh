#!/bin/bash
set -e

# AWS CLI should be available in the task environment when running on ECS
# Retrieve secrets and set them as environment variables
if [ -n "$DB_SECRET_ARN" ]; then
  echo "Retrieving database secrets from AWS Secrets Manager..."

  # Get the secret value using AWS CLI
  SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $DB_SECRET_ARN --query SecretString --output text)

  # Extract values from JSON (requires jq)
  export DB_USERNAME=$(echo $SECRET_JSON | jq -r '.username')
  export DB_PASSWORD=$(echo $SECRET_JSON | jq -r '.password')
  export DB_HOST=$(echo $SECRET_JSON | jq -r '.host')
  export DB_PORT=$(echo $SECRET_JSON | jq -r '.port // "5432"')
  export DB_NAME=$(echo $SECRET_JSON | jq -r '.dbname')



  # Construct DATABASE_URL for Prisma
  # export DATABASE_URL="postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
  # Function to perform URL encoding based on the specified rules
  url_encode() {
    local raw="$1"
    local encoded

    encoded=$(printf '%s' "$raw" | sed -e 's/%/%25/g' \
                                    -e 's/ /%20/g' \
                                    -e 's/&/%26/g' \
                                    -e 's/\//%2F/g' \
                                    -e 's/:/%3A/g' \
                                    -e 's/=/%3D/g' \
                                    -e 's/?/%3F/g' \
                                    -e 's/@/%40/g' \
                                    -e 's/$$/%5B/g' \
                                    -e 's/$$/%5D/g' \
                                    -e 's/\+/%2B/g' \
                                    -e 's/!/%21/g' \
                                    -e 's/#/%23/g' \
                                    -e "s/'/%27/g" \
                                    -e 's~%7E/g')  # tilde

    echo "$encoded"
  }
  # URL-encode each component
  ENCODED_DB_USERNAME=$(url_encode "$DB_USERNAME")
  ENCODED_DB_PASSWORD=$(url_encode "$DB_PASSWORD")
  ENCODED_DB_HOST=$(url_encode "$DB_HOST")
  ENCODED_DB_PORT=$(url_encode "$DB_PORT")
  ENCODED_DB_NAME=$(url_encode "$DB_NAME")

  # Reconstruct DATABASE_URL using encoded values
  export DATABASE_URL="postgresql://${ENCODED_DB_USERNAME}:${ENCODED_DB_PASSWORD}@${ENCODED_DB_HOST}:${ENCODED_DB_PORT}/${ENCODED_DB_NAME}"
  echo "=================================================================="
  echo "DATABASE_URL constructed from AWS Secrets Manager:"
  echo "${DATABASE_URL}" | sed 's/:/\\\*\\\*\\\*@/2'  # Hide password in logs
  echo "=================================================================="

  # Add to .env file for Prisma to find it
  echo "DATABASE_URL=${DATABASE_URL}" > /app/server/.env

  echo "Database connection configured from secrets."
else
  echo "WARNING: DB_SECRET_ARN not set. Using default DATABASE_URL if available."
fi

# Print environment info for debugging
echo "Current DATABASE_URL being used:"
grep DATABASE_URL /app/server/.env 2>/dev/null || echo "DATABASE_URL not found in .env file"
env | grep -i postgres || echo "No POSTGRES environment variables found"


echo "Logging all variables from /app/server/.env:"
cat /app/server/.env
echo "=================================================================="
echo "Environment variables set for database connection."
echo "=================================================================="
# echo "Starting application..."
# echo "=================================================================="
# Execute the original entrypoint script
exec /usr/local/bin/docker-entrypoint.sh "$@"
