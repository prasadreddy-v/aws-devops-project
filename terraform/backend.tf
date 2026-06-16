terraform {

  backend "s3" {

    bucket         = "prasad-devops-tfstate"
    key            = "dev/vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"

    encrypt = true
  }
}