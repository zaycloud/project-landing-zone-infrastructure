#!/usr/bin/env bash
set -e

# Färger
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Secure Landing Zone Generator (GCP) ===${NC}"

# 1. Input
echo ""
echo "1. Gå till https://console.cloud.google.com/projectcreate"
echo "2. Skapa ett nytt tomt projekt (t.ex. portfolio-demo-1)"
echo ""
read -p "Klistra in ditt Projekt-ID här: " PROJECT_ID

# 2. Input Bucket
read -p "Ange din Terraform State Bucket (t.ex. tf-state-zayn...): " BUCKET_NAME

# 3. Säkerhetskoll
if ! gcloud projects describe "$PROJECT_ID" > /dev/null 2>&1; then
  echo "Fel: Kan inte hitta projektet '$PROJECT_ID' (eller saknar rättigheter)."
  exit 1
fi

# 4. Skapa tfvars (Utan bucket-namnet, för det behövs inte där)
echo "Konfigurerar..."
cd "$(dirname "$0")/../live/dev"

cat > terraform.tfvars <<EOF
project_id = "$PROJECT_ID"
region     = "europe-north1"
EOF

# 5. Initiera
# Vi injicerar bucket-namnet direkt i kommandot.
echo "Initierar Terraform mot bucket: $BUCKET_NAME"
terraform init -reconfigure -backend-config="bucket=$BUCKET_NAME"

# 6. Apply
echo ""
echo -e "${YELLOW}Redo att bygga i projekt: $PROJECT_ID${NC}"
read -p "Skriv 'ja' för att köra: " CONFIRM
if [[ "$CONFIRM" != "ja" ]]; then
  echo "Avbryter."
  exit 0
fi

terraform apply -auto-approve

echo ""
echo -e "${GREEN}KLART!${NC}"
terraform output -raw connect