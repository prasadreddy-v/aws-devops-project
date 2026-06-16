terraform {

  backend "s3" {

    bucket       = "prasad-devops-tfstate"
    key          = "dev/vpc/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true

    encrypt = true
  }
}