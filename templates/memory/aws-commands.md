# AWS CLI — Quick Reference for OpenClaw Infrastructure

> Common commands for managing EC2 instances and AWS resources.
> All commands assume `aws configure` has been run.

## EC2 — Instance Management

### List running instances
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,IP:PublicIpAddress,Name:Tags[?Key==`Name`]|[0].Value}' --output table
```

### Launch an instance (Ubuntu 24.04 LTS)
```bash
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.medium \
  --key-name openclaw-deploy \
  --security-group-ids sg-XXXXXXXX \
  --subnet-id subnet-XXXXXXXX \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=username-openclaw},{Key=project,Value=openclaw}]' \
  --user-data 'file://setup.sh' \
  --count 1
```

Recommended instance types:
- `t3.medium` — 4GB / 2 vCPU — ~$30/mo (recommended for most users)
- `t3.large` — 8GB / 2 vCPU — ~$60/mo (for power users with sub-agents)
- `t3.small` — 2GB / 1 vCPU — ~$15/mo (chat-only, minimal building)

### Start/Stop/Terminate
```bash
aws ec2 start-instances --instance-ids i-XXXXXXXXX
aws ec2 stop-instances --instance-ids i-XXXXXXXXX
aws ec2 terminate-instances --instance-ids i-XXXXXXXXX
```

### Get instance status
```bash
aws ec2 describe-instances --instance-ids i-XXXXXXXXX \
  --query 'Reservations[].Instances[].{State:State.Name,IP:PublicIpAddress,Type:InstanceType}'
```

## EC2 — Security Groups

### Open ports for OpenClaw
```bash
# SSH
aws ec2 authorize-security-group-ingress --group-id sg-XXXXXXXX --protocol tcp --port 22 --cidr 0.0.0.0/0

# OpenClaw Control UI
aws ec2 authorize-security-group-ingress --group-id sg-XXXXXXXX --protocol tcp --port 18789 --cidr 0.0.0.0/0
```

### List security group rules
```bash
aws ec2 describe-security-groups --group-ids sg-XXXXXXXX \
  --query 'SecurityGroups[].IpPermissions[].{Port:FromPort,Protocol:IpProtocol,CIDR:IpRanges[].CidrIp}'
```

## EC2 — Key Pairs

### Create a key pair
```bash
aws ec2 create-key-pair --key-name openclaw-deploy --query 'KeyMaterial' --output text > ~/openclaw-deploy.pem
chmod 600 ~/openclaw-deploy.pem
```

### List key pairs
```bash
aws ec2 describe-key-pairs --query 'KeyPairs[].{Name:KeyName,ID:KeyPairId}' --output table
```

## EC2 — Elastic IPs

### Allocate and associate
```bash
aws ec2 allocate-address --domain vpc
aws ec2 associate-address --instance-id i-XXXXXXXXX --allocation-id eipalloc-XXXXXXXX
```

## EC2 — AMI Snapshots & Backups

### Create an AMI (full backup)
```bash
aws ec2 create-image --instance-id i-XXXXXXXXX --name "openclaw-backup-$(date +%Y%m%d)" --no-reboot
```

### List AMIs
```bash
aws ec2 describe-images --owners self --query 'Images[].{Name:Name,ID:ImageId,Created:CreationDate}' --output table
```

## S3 — File Storage & Backups

### Create a bucket
```bash
aws s3 mb s3://carpe-openclaw-backups --region us-west-2
```

### Upload/Download files
```bash
aws s3 cp /path/to/file s3://carpe-openclaw-backups/
aws s3 cp s3://carpe-openclaw-backups/file /path/to/local/
```

### Sync a workspace backup
```bash
aws s3 sync ~/.openclaw/workspace/ s3://carpe-openclaw-backups/username/ --exclude "node_modules/*"
```

## SSM — Remote Command Execution (no SSH needed)

### Run a command on an instance
```bash
aws ssm send-command \
  --instance-ids "i-XXXXXXXXX" \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["openclaw status"]'
```

## Useful One-Liners

### Check all OpenClaw instances at once
```bash
aws ec2 describe-instances \
  --filters "Name=tag:project,Values=openclaw" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,State:State.Name,IP:PublicIpAddress}' --output table
```

### Quick SSH to an instance
```bash
ssh -i ~/openclaw-deploy.pem ubuntu@<IP_ADDRESS>
```

### EC2 Instance Connect (no key needed)
Use the AWS Console: EC2 → Instances → select instance → Connect → EC2 Instance Connect → Connect
