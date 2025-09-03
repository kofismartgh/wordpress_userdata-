terraform {
  backend "s3" {
    #    bucket = "myterraform-state01" #enable versioning on bucket
    bucket = "myterraform-state01" #enable versioning on bucket
    region = "us-east-1"
    #    dynamodb_table = "myterraformstate-locking" #the hashkey has to be LockID
    key = "kodecloud/wordpress.tfstate" #directory

  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}