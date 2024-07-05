terraform {
  backend "s3" {
    bucket         = "mybucket-vk-remote-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
 }
}