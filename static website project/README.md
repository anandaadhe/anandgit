# S3 Static Website + EC2-in-VPC (Free Tier friendly) — Terraform

This stack creates:

- **VPC** with one **public** subnet and one **private** subnet (no NAT Gateway — kept out on purpose, see below)
- Internet Gateway + route table for the public subnet
- A free **Gateway VPC Endpoint** for S3 (so traffic to S3 never needs the internet or a NAT Gateway)
- One **EC2 instance** (`t2.micro`, free-tier eligible) in the public subnet, running a tiny Apache "hello world" page
- An **S3 bucket** configured for static website hosting, with a sample `index.html` / `error.html`
- Security groups: HTTP open, SSH restricted to an IP you choose

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Terraform + provider version pins |
| `variables.tf` | All configurable inputs |
| `vpc.tf` | VPC, subnets, IGW, route tables, S3 gateway endpoint |
| `security_groups.tf` | Security groups for public/private instances |
| `ec2.tf` | EC2 instance(s) + latest Amazon Linux 2 AMI lookup |
| `s3.tf` | S3 bucket, website config, public-read policy, sample pages |
| `outputs.tf` | URLs/IDs printed after apply |
| `terraform.tfvars.example` | Copy to `terraform.tfvars` and edit |

## How to deploy

```bash
# 1. Configure AWS credentials (any of these work)
aws configure
# or export AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN

# 2. Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# set my_ip_cidr to your own IP, adjust region if needed

# 3. Initialize, review, apply
terraform init
terraform plan
terraform apply
```

After apply, Terraform prints:
- `s3_website_endpoint` — the S3 static website URL
- `public_ec2_website_url` — the Apache page on your EC2 instance

## How this stays inside the AWS Free Tier

- **EC2**: `t2.micro`, 750 instance-hours/month free for the first 12 months of an account. Only **one** instance is created by default.
- **Public IPv4**: since Feb 2024 AWS bills $0.005/hr per public IPv4 address, but EC2's Free Tier includes 750 hrs/month of public IPv4 usage for a single running instance — so one instance running continuously stays free. Don't create Elastic IPs or extra instances with public IPs, since those aren't covered.
- **No NAT Gateway**: NAT Gateways are never free (~$0.045/hr + per-GB data charges) regardless of account age, so this stack doesn't create one. That also means the private subnet has **no internet route** — it's there to demonstrate the public/private topology, but nothing in it can reach the internet. `create_private_instance` defaults to `false` for the same reason: if you flip it on, the instance will boot but won't be able to reach the internet (e.g., `yum update` will fail) unless you separately add a NAT Gateway — which then costs money.
- **S3 Gateway Endpoint**: always free, no hourly charge.
- **S3 storage**: Free Tier gives 5 GB storage + 20,000 GET + 2,000 PUT requests/month for the first 12 months. A small static site stays well within this.
- **EBS root volume**: 8 GB gp3, within the 30 GB-month Free Tier allowance.

## Important — this is only free if

1. Your AWS account is within its **first 12 months** (the EC2/EBS/S3 Free Tier is a 12-month allowance for new accounts, not permanent). Older accounts will be billed standard on-demand rates for EC2/EBS (S3's request/storage free tier is also 12-month based).
2. You don't add extra resources beyond what's here (extra instances, Elastic IPs, NAT Gateways, load balancers, etc.).
3. You **destroy the stack** when you're done experimenting:

```bash
terraform destroy
```

Leaving the EC2 instance running indefinitely will eventually exceed the 750 free hours in a month if you also run other instances, and will incur standard hourly charges once the account ages past 12 months.

## Cleaning up / avoiding surprise charges

- Set a **Billing Alert / Budget** in the AWS Console (Billing → Budgets) for a low threshold (e.g. $1) so you're notified immediately of any charge.
- Run `terraform destroy` when you're finished, rather than deleting resources by hand — it removes everything Terraform created, in the right order.
- S3 bucket names are globally unique; if `bucket_name` is left unset, a random suffix is generated for you so `terraform apply` won't clash with an existing bucket.
