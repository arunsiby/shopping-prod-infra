---
name: "Prod infra"

on:

 workflow_dispatch:

    inputs:

      instance_type:
        type: choice
        description: "Instance type"
        options: 
        - t2.micro
        - t2.small
        default: "t2.micro"

      ami:
        type: string
        description: "Instance ami"
        required: true
        default: "ami-02e94b011299ef128"

    
jobs:
    
  build:
    runs-on: ubuntu-latest

    steps:

      - name: "Repository Checkout"
        uses: actions/checkout@v3

      - name: "Terraform Installation"
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.2
     
      - name: "Terraform init"
        run: |
           terraform init \
               -backend-config="bucket=${{ secrets.PROD_S3_BUCKET }}" \
               -backend-config="key=terraform.tfstate" \
               -backend-config="region=ap-south-1" \
               -backend-config="access_key=${{ secrets.PROD_ACCESS_KEY }}" \
               -backend-config="secret_key=${{ secrets.PROD_SECRET_KEY }}" \            
            
      - name: "Terraform fmt"
        run: terraform fmt
          
      - name: "Terraform validate"
        run: terraform validate

      - name: "Terraform plan"
        run: |
           terraform plan \
             -var "instance_type=${{ github.event.inputs.instance_type }}" \
             -var "ami=${{ github.event.inputs.ami }}"
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.PROD_ACCESS_KEY }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.PROD_SECRET_KEY }}
          AWS_REGION: "ap-south-1"

        
      - name: "Terraform apply"
        run: |
           terraform apply \
             -var "instance_type=${{ github.event.inputs.instance_type }}" \
             -var "ami=${{ github.event.inputs.ami }}" \
             -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.PROD_ACCESS_KEY }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.PROD_SECRET_KEY }}
          AWS_REGION: "ap-south-1"
