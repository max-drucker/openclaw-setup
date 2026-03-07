# AWS CLI — Quick Reference for OpenClaw Infrastructure

> Common commands for managing Lightsail instances, EC2, and AWS resources.
> All commands assume `aws configure` has been run.

## Lightsail — Instance Management

### List all instances
```bash
aws lightsail get-instances --query 'instances[].{Name:name,State:state.name,IP:publicIpAddress,Plan:bundleId}' --output table
```

### Create a new instance
```bash
aws lightsail create-instances \
  --instance-names "username-openclaw" \
  --availability-zone us-west-2a \
  --blueprint-id ubuntu_22_04 \
  --bundle-id medium_3_0 \
  --tags key=project,value=openclaw key=owner,value=USERNAME
```

Bundle IDs:
- `nano_3_0` — 512MB / 2 vCPU / 20GB — $3.50/mo
- `micro_3_0` — 1GB / 2 vCPU / 40GB — $7/mo
- `small_3_0` — 2GB / 2 vCPU / 60GB — $12/mo (recommended)
- `medium_3_0` — 4GB / 2 vCPU / 80GB — $20/mo
- `large_3_0` — 8GB / 2 vCPU / 160GB — $40/mo

### Start/Stop/Reboot an instance
```bash
aws lightsail start-instance --instance-name "username-openclaw"
aws lightsail stop-instance --instance-name "username-openclaw"
aws lightsail reboot-instance --instance-name "username-openclaw"
```

### Delete an instance
```bash
aws lightsail delete-instance --instance-name "username-openclaw"
```

### Get instance status
```bash
aws lightsail get-instance --instance-name "username-openclaw" \
  --query 'instance.{Name:name,State:state.name,IP:publicIpAddress,CPU:hardware.cpuCount,RAM:hardware.ramSizeInGb}'
```

## Lightsail — Static IPs

### Allocate and attach a static IP
```bash
aws lightsail allocate-static-ip --static-ip-name "username-openclaw-ip"
aws lightsail attach-static-ip --static-ip-name "username-openclaw-ip" --instance-name "username-openclaw"
```

### List static IPs
```bash
aws lightsail get-static-ips --query 'staticIps[].{Name:name,IP:ipAddress,Attached:isAttached,Instance:attachedTo}' --output table
```

## Lightsail — Snapshots & Backups

### Create a manual snapshot
```bash
aws lightsail create-instance-snapshot --instance-name "username-openclaw" --instance-snapshot-name "username-openclaw-$(date +%Y%m%d)"
```

### List snapshots
```bash
aws lightsail get-instance-snapshots --query 'instanceSnapshots[].{Name:name,State:state,Created:createdAt,Source:fromInstanceName}' --output table
```

### Create instance from snapshot (disaster recovery)
```bash
aws lightsail create-instances-from-snapshot \
  --instance-names "username-openclaw-restored" \
  --availability-zone us-west-2a \
  --instance-snapshot-name "username-openclaw-20260307" \
  --bundle-id small_3_0
```

### Enable automatic snapshots
```bash
aws lightsail enable-add-on --resource-name "username-openclaw" \
  --add-on-request addOnType=AutoSnapshot,autoSnapshotAddOnRequest={snapshotTimeOfDay=06:00}
```

## Lightsail — Firewall

### Open a port
```bash
aws lightsail open-instance-public-ports --instance-name "username-openclaw" \
  --port-info fromPort=3000,toPort=3000,protocol=tcp
```

### Close a port
```bash
aws lightsail close-instance-public-ports --instance-name "username-openclaw" \
  --port-info fromPort=3000,toPort=3000,protocol=tcp
```

### List open ports
```bash
aws lightsail get-instance --instance-name "username-openclaw" \
  --query 'instance.networking.ports[].{From:fromPort,To:toPort,Protocol:protocol,Access:accessType}'
```

## Lightsail — SSH Key Management

### Create a key pair
```bash
aws lightsail create-key-pair --key-pair-name "openclaw-deploy" \
  --query 'privateKeyBase64' --output text | base64 -d > ~/openclaw-deploy.pem
chmod 600 ~/openclaw-deploy.pem
```

### List key pairs
```bash
aws lightsail get-key-pairs --query 'keyPairs[].{Name:name,Fingerprint:fingerprint}' --output table
```

## EC2 — For Enterprise/Heavy Workloads

### List running instances
```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,IP:PublicIpAddress,Name:Tags[?Key==`Name`]|[0].Value}' --output table
```

### Launch an instance
```bash
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.medium \
  --key-name openclaw-deploy \
  --security-group-ids sg-XXXXXXXX \
  --subnet-id subnet-XXXXXXXX \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=username-openclaw},{Key=project,Value=openclaw}]' \
  --count 1
```

### Start/Stop/Terminate
```bash
aws ec2 start-instances --instance-ids i-XXXXXXXXX
aws ec2 stop-instances --instance-ids i-XXXXXXXXX
aws ec2 terminate-instances --instance-ids i-XXXXXXXXX
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

### Sync a directory
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
aws lightsail get-instances --query 'instances[?contains(name,`openclaw`)].{Name:name,State:state.name,IP:publicIpAddress}' --output table
```

### Get monthly cost estimate
```bash
aws lightsail get-cost-estimate --resource-name "username-openclaw" --start-time "$(date -d '30 days ago' +%Y-%m-%dT00:00:00Z)" --end-time "$(date +%Y-%m-%dT00:00:00Z)" 2>/dev/null || echo "Use: aws ce get-cost-and-usage for detailed billing"
```

### Quick health check across all instances
```bash
for inst in $(aws lightsail get-instances --query 'instances[?contains(name,`openclaw`)].name' --output text); do
  state=$(aws lightsail get-instance --instance-name "$inst" --query 'instance.state.name' --output text)
  echo "$inst: $state"
done
```
