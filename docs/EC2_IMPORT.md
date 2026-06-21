# EC2 Import & Adoption Guide

KrishiFarms uses the **same EC2 as Gamya Couture** by default. See [SHARED_EC2.md](SHARED_EC2.md) for full setup.

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

## 6. Bootstrap host (shared EC2 — does not affect Gamya)

```bash
aws ssm start-session --target i-XXXXXXXXX
sudo SHARED_EC2=true API_DOMAIN=api.krishifarms.in \
  bash /tmp/krishifarms-infra/scripts/bootstrap/install.sh
```

## 7. SSL

```bash
sudo API_DOMAIN=api.krishifarms.in ADMIN_EMAIL=you@domain.com \
  bash /opt/krishifarms/scripts/ssl/setup-ssl.sh
```

## 8. Start stack

```bash
/opt/krishifarms/scripts/compose-up.sh prod
/opt/krishifarms/scripts/health-check.sh
```
