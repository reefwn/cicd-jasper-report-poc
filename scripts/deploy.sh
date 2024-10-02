#!/bin/sh

# Check if the environment argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    echo "Example: $0 development"
    exit 1
fi

# Set the environment variable to the argument provided
ENVIRONMENT=$1

ENV_DIR="./env"
REPORT_DIR="./reports"

# Determine the correct .env file based on the environment
case "$ENVIRONMENT" in
    development)
        ENV_FILE="$ENV_DIR/.env.development"
        ;;
    production)
        ENV_FILE="$ENV_DIR/.env.production"
        ;;
    *)
        echo "Invalid environment. Use development or production."
        exit 1
        ;;
esac

# Load environment variables from the specified .env file
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "Environment file $ENV_FILE not found."
    exit 1
fi

# Loop through all .jrxml files and deploy them
find "$REPORT_DIR" -type f -name "*.jrxml" | while read -r report; do
    report_name=$(basename "$report")
    report_full_dir=$(dirname "$report")
    report_dir=$(basename "$report_full_dir")

    echo "Replacing values in $report_dir"

    # Replace placeholders in the JRXML file
    sed -i.bak "s#{{JASPER_SERVER}}#$JASPER_SERVER#g" "$report"
    sed -i.bak "s#{{REPORT1_API_URL}}#$REPORT1_API_URL#g" "$report"
    sed -i.bak "s#{{REPORT2_API_URL}}#$REPORT2_API_URL#g" "$report"

    echo "Deploying $report_name from $report_dir"

    # Deploy .jrxml using REST API
    curl -u "$JASPER_USER:$JASPER_PASS" -X PUT \
        -H "Content-Type: application/repository.jrxml" \
        --data-binary @"$report" \
        "$JASPER_SERVER/rest_v2/resources/Reports/$report_dir/$report_name"
    
    if [ $? -eq 0 ]; then
        echo "Successfully deployed $report_dir"
    else
        echo "Failed to deploy $report_dir"
        exit 1
    fi
done

echo "Deplyment ends..."
