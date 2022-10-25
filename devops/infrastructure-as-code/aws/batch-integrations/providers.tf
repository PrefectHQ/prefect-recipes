# Primary master provider - additional providers can be added e.g. dev/prod
# Tags were assigned from tagging guidelines
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = "@Boyd"
      Environment = "Dev"
      Product     = "prefect-aws"
      Source      = "https://bitbucket.org/prefect_utils/src/master/"
      Controller  = "terraform"
    }
  }
}