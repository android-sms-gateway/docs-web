terraform {
  backend "s3" {
    bucket                      = "38e04e71-private"
    key                         = "terraform/android-sms-gateway-docs.tfstate"
    region                      = "ru-1"
    endpoint                    = "s3.timeweb.com"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}
