**Flask CI/CD Pipeline on AWS**

A fully automated CI/CD pipeline that builds, containerizes, and deploys a Flask application to AWS on every push to main — using GitHub Actions, Docker, Amazon ECR, and EC2, with infrastructure provisioned via Terraform.

Architecture
Developer push (main)
        │
        ▼
GitHub Actions Workflow
        │
        ├─► Build Docker image
        │
        ├─► Push image to Amazon ECR
        │
        └─► SSH into EC2 → pull latest image → restart container
                        │
                        ▼
                Flask app running on EC2 (port 5000)

**Infrastructure (Terraform-managed):**

-> Amazon ECR repository (with image scanning on push)
-> EC2 instance (Ubuntu 22.04, Docker pre-installed via user_data)
-> Security group (SSH + app port access)
-> Dynamic AMI lookup via AWS SSM parameter (no hardcoded, stale AMI IDs)

**Tech Stack**

-> App: Python, Flask
-> Containerization: Docker
-> CI/CD: GitHub Actions
-> Container Registry: Amazon ECR
-> Compute: Amazon EC2
-> IaC: Terraform
-> Region: ap-south-1 (Mumbai)

**How It Works**
1.Code is pushed to the main branch.
2.GitHub Actions triggers automatically (.github/workflows/deploy.yml).
3.The workflow authenticates to AWS, builds the Docker image, and pushes it to ECR (tagged with both the commit SHA and latest).
4.The workflow then SSHs into the EC2 instance, pulls the newly pushed image, stops/removes the old container, and starts the new one.
5.The updated app is live on the EC2 instance's public IP, port 5000.

**Project Structure**
.
├── app.py                  # Flask application
├── requirements.txt        # Python dependencies
├── Dockerfile               # Container build instructions
├── .dockerignore
├── .gitignore
├── terraform/
│   ├── providers.tf         # AWS provider config
│   ├── ecr.tf                # ECR repository
│   └── ec2.tf                 # EC2 instance, security group, AMI lookup
└── .github/
    └── workflows/
        └── deploy.yml       # CI/CD pipeline definition
        
**Running Locally**

pip install -r requirements.txt
python app.py
Running via Docker

**Running via Docker**

docker build -t flask-cicd-app .
docker run -d -p 5000:5000 --name flask-app flask-cicd-app
**Endpoints**
Route	Description
/	Returns a hello-world greeting
/health	Health check endpoint — returns {"status": "healthy"}

**Provisioning Infrastructure**
cd terraform
terraform init
terraform plan
terraform apply

Outputs the ECR repository URL and the EC2 instance's public IP.

**CI/CD Setup**

The pipeline authenticates using GitHub repository secrets:

Secret	Purpose
AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY	AWS authentication for ECR push
AWS_REGION	Target AWS region (ap-south-1)
ECR_REPOSITORY	ECR repo name
EC2_HOST	EC2 instance public IP
EC2_USER	SSH user (ubuntu)
EC2_SSH_KEY	Private key for SSH deploy access

**Key Design Decisions**

Dynamic AMI resolution via SSM parameter store instead of a hardcoded AMI ID, to avoid stale/deprecated images.
Image scanning enabled on ECR push for basic vulnerability visibility.
Terraform-managed infrastructure instead of manual console setup, for reproducibility and version control.
Terraform state excluded from version control (.gitignore) since state files can contain sensitive resource data.


