#!/usr/bin/env bash
set -euo pipefail

# Set default AWS region to match Terraform and Jenkins configuration
export AWS_DEFAULT_REGION="ap-south-1"

# Print usage instructions
usage() {
  echo "Usage: $0 {apply|destroy}"
  exit 1
}

# Check if an argument was provided
if [ $# -lt 1 ]; then
  usage
fi

ACTION="$1"

if [ "$ACTION" == "apply" ]; then
  # 1. Run first-stage Terraform Apply (standalone app node deployed, ASGs set to 0)
  echo "=== Step 1: Deploying standalone infrastructure (ASGs scale = 0) ==="
  cd terraform
  terraform apply -auto-approve -lock=false \
    -var="app_asg_desired=0" \
    -var="app_asg_min=0"
  cd ..

  # 2. Wait for instances to boot and SSH port to open
  echo "=== Step 2: Waiting 45 seconds for instances to boot and SSH to start ==="
  sleep 45

  # 3. Configure the standalone instances using Ansible
  echo "=== Step 3: Configuring instances with Ansible ==="
  ansible-playbook ha.yml

  # 4. Fetch standalone Instance ID from Terraform
  echo "=== Step 4: Fetching instance ID for AMI baking ==="
  cd terraform
  APP_INSTANCE_ID=$(terraform output -raw app_instance_id)
  cd ..

  # 5. Create new AMI from configured standalone instance
  TIMESTAMP=$(date +%s)
  APP_AMI_NAME="vm-app-baked-${TIMESTAMP}"

  echo "=== Step 5: Baking new AMI for Application (vm-app) from $APP_INSTANCE_ID ==="
  APP_AMI_ID=$(aws ec2 create-image \
    --instance-id "$APP_INSTANCE_ID" \
    --name "$APP_AMI_NAME" \
    --no-reboot \
    --query "ImageId" \
    --output text)
  echo "Application AMI ID: $APP_AMI_ID"

  # 6. Wait for AMI to be active and ready
  echo "=== Step 6: Waiting for AMI to become active (usually takes 2-3 minutes) ==="
  aws ec2 wait image-available --image-ids "$APP_AMI_ID"
  echo "AMI is active and ready!"

  # 7. Run second-stage Terraform Apply to scale ASGs to 2 using the new AMI
  echo "=== Step 7: Scaling ASGs to 2 with the newly baked AMI ==="
  cd terraform
  terraform apply -auto-approve \
    -var="ami_id_ingestion=$APP_AMI_ID" \
    -var="app_asg_desired=2" \
    -var="app_asg_min=2"
  cd ..

  echo "=== Deployment Completed Successfully! ==="

elif [ "$ACTION" == "destroy" ]; then
  echo "=== Step 1: Destroying Terraform-managed infrastructure ==="
  cd terraform
  terraform destroy -auto-approve
  cd ..

  echo "=== Step 2: Cleaning up baked AMIs and their snapshots from AWS ==="
  # Find all AMI IDs starting with vm-app-baked-
  for ami_id in $(aws ec2 describe-images --owners self --filters "Name=name,Values=vm-app-baked-*" --query "Images[].ImageId" --output text); do
      if [ -n "$ami_id" ] && [ "$ami_id" != "None" ]; then
          echo "Deregistering AMI: $ami_id"
          # Find snapshot ID associated with the AMI
          snapshot_ids=$(aws ec2 describe-images --image-ids "$ami_id" --query "Images[].BlockDeviceMappings[].Ebs.SnapshotId" --output text)
          aws ec2 deregister-image --image-id "$ami_id"
          
          # Delete the EBS snapshots associated with the AMI
          for snap in $snapshot_ids; do
              if [ "$snap" != "None" ] && [ -n "$snap" ]; then
                  echo "Deleting snapshot: $snap"
                  aws ec2 delete-snapshot --snapshot-id "$snap"
              fi
          done
      fi
  done
  echo "=== Teardown Completed Successfully! ==="

else
  echo "Error: Unknown action '$ACTION'"
  usage
fi
