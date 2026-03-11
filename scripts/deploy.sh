#!/bin/bash

# Salesforce Supermarket Data Management System - Deployment Script
# Usage: ./scripts/deploy.sh <target-org>

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if org alias is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Target org alias is required${NC}"
    echo "Usage: ./scripts/deploy.sh <target-org>"
    exit 1
fi

TARGET_ORG=$1

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Salesforce Deployment Script${NC}"
echo -e "${GREEN}Target Org: $TARGET_ORG${NC}"
echo -e "${GREEN}========================================${NC}"

# Step 1: Validate target org
echo -e "\n${YELLOW}Step 1: Validating target org...${NC}"
sf org display --target-org $TARGET_ORG || {
    echo -e "${RED}Error: Cannot connect to target org '$TARGET_ORG'${NC}"
    exit 1
}

# Step 2: Deploy metadata
echo -e "\n${YELLOW}Step 2: Deploying metadata to $TARGET_ORG...${NC}"
sf project deploy start --target-org $TARGET_ORG || {
    echo -e "${RED}Error: Deployment failed${NC}"
    exit 1
}

# Step 3: Run Apex tests
echo -e "\n${YELLOW}Step 3: Running Apex tests...${NC}"
sf apex run test --target-org $TARGET_ORG --code-coverage --result-format human --wait 10 || {
    echo -e "${RED}Warning: Some tests failed. Check test results.${NC}"
}

# Step 4: Check deployment status
echo -e "\n${YELLOW}Step 4: Checking deployment status...${NC}"
sf project deploy report --target-org $TARGET_ORG

# Step 5: Get code coverage
echo -e "\n${YELLOW}Step 5: Checking code coverage...${NC}"
sf apex get test --target-org $TARGET_ORG --code-coverage --result-format human || {
    echo -e "${YELLOW}Warning: Could not retrieve code coverage${NC}"
}

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Verify deployment: sf org open --target-org $TARGET_ORG"
echo "2. Create test data: Run scripts/apex/createTestData.apex"
echo "3. Test CSV import via excelUploader component"
echo "4. Verify flows are active"
echo "5. Test end-to-end workflow"

exit 0
