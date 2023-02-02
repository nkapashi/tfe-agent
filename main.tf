variable "TFC_WORKSPACE_NAME" {
  type        = string
}
variable "TFE_RUN_ID" {
  type        = string
}
provider "vault" {
  address    = "https://52.8.132.87:8200"
  token_name = "terraform-${var.TFE_RUN_ID}"
  auth_login {
    path = "auth/tfe-auth/login"
    parameters = {
      role      = "workspace_role"
      workspace = var.TFC_WORKSPACE_NAME
      run-id    = var.TFE_RUN_ID
      tfe-credentials-file = filebase64("/tmp/cli.tfrc")
    }
  }
}
data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "deploy"
}
provider "aws" {
  region     = var.region
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  token      = data.vault_aws_access_credentials.creds.security_token
}
