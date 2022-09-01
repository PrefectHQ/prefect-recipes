provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner   = "@Boyd"
      Environment = "Dev"
      Product = "prefect-aws"
      Source = "https://bitbucket.org/prefect_utils/src/master/"
      Controller = "terraform"
    }
  }
}