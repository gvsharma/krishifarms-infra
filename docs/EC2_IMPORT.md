# EC2 Import & Adoption Guide

Terraform **does not create EC2** for KrishiFarms CRM. Production reuses an existing instance.

## 1. Discover existing resources

```bash
aws ec2 describe-instances --instance-ids i-XXXXXXXXX \
  --query 'Reservations[0].Instances[0].{Id:InstanceId,VpcId:VpcId,PublicIp:PublicIpAddress,Profile:IamInstanceProfile.Arn,SGs:SecurityGroups[*].GroupId}'
```

Record:

- `instance_id`
- `vpc_id`
- Elastic IP (prefer stable EIP over ephemeral public IP)
- Current IAM instance profile
- Security groups

## 2. Configure prod tfvars

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Set existing_ec2_instance_id, existing_ec2_public_ip, vpc_id
```

## 3. Apply Terraform

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## 4. Attach IAM instance profile

```bash
PROFILE=$(terraform output -raw ec2_instance_profile_name)
aws ec2 associate-iam-instance-profile \
  --instance-id i-XXXXXXXXX \
  --iam-instance-profile Name="${PROFILE}"
```

## 5. Attach security group

```bash
SG=$(terraform output -raw ec2_security_group_id)
aws ec2 modify-instance-attribute \
  --instance-id i-XXXXXXXXX \
  --groups sg-existing1 sg-existing2 "${SG}"
```

## 6. Bootstrap host

```bash
aws ssm start-session --target i-XXXXXXXXX
sudo ENVIRONMENT=prod API_DOMAIN=api.krishifarms.in bash /opt/krishifarms/scripts/bootstrap/install.sh
```

Copy repo assets first if bootstrap runs before git clone on host:

```bash
scp -r docker scripts ec2-user@<eip>:/tmp/krishifarms-infra/
```

## 7. SSL

```bash
sudo API_DOMAIN=api.krishifarms.in ADMIN_EMAIL=you@domain.com \
  bash /opt/krishifarms/scripts/ssl/setup-ssl.sh
```

## 8. Start stack

```bash
cd /opt/krishifarms/app
cp /path/to/.env ../config/.env
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
