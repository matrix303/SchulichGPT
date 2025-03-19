# AWS

## IAM

Dev User Group: schulichgpt_dev
Group has access to EC2, ECR, ECS, ECF
- ADD NEW DEV USERS TO THIS GROUP


## Container Registry
https://us-east-2.console.aws.amazon.com/ecr/private-registry/repositories?region=us-east-2
- schulichgpt/dev

### Push commands
  1. Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:
    `aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 253921444959.dkr.ecr.us-east-2.amazonaws.com`
    Note: If you receive an error using the AWS CLI, make sure that you have the latest version of the AWS CLI and Docker installed.
  2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built:
    `docker build -t schulichgpt/dev .`
    NOTE: WHEN BUILDING, SPECIFY PLATFORM AS AMD64 to ensure deployment x86_64
    `docker build -t schulichgpt/dev . --platform linux/amd64`
`
  3. After the build completes, tag your image so you can push the image to this repository:
    `docker tag schulichgpt/dev:latest 253921444959.dkr.ecr.us-east-2.amazonaws.com/schulichgpt/dev:latest`
  4. Run the following command to push this image to your newly created AWS repository:
    `docker push 253921444959.dkr.ecr.us-east-2.amazonaws.com/schulichgpt/dev:latest`

# Build Image
`docker build --platform linux/amd64 -t schulichgpt/dev-prisma -f ./docker/Dockerfile .`
`docker tag schulichgpt/dev-prisma:latest 253921444959.dkr.ecr.us-east-2.amazonaws.com/schulichgpt/dev-prisma:latest`
`docker push 253921444959.dkr.ecr.us-east-2.amazonaws.com/schulichgpt/dev-prisma:latest`
