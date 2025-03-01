variable "enable_codeartifact_domain_kms_key" {
  description = "Whether to enable creation of a KMS key for the CodeArtifact domain"
  type        = bool
  default     = false
}

variable "codeartifact_domain_kms_key_description" {
  description = "Description of KMS key to create if enabled"
  type        = string
  default     = ""
}

variable "enable_codeartifact_domain" {
  description = "Whether to enable creation of a CodeArtifact domain"
  type        = bool
  default     = true
}

variable "codeartifact_domain_name" {
  description = "Name of CodeArtifact domain to create or reference based on var.enable_codeartifact_domain"
  type        = string
}

variable "codeartifact_domain_kms_key_arn" {
  description = "CodeArtifact domain KMS key to use if var.enable_codeartifact_domain_kms_key is disabled"
  type        = string
  default     = null
}

variable "codeartifact_repositories" {
  description = "List of repositories to create. Defaults is empty list"
  type = list(object({
    name        = string
    description = string
    external_connections = optional(list(object({
      external_connection_name = string
    })))
    upstream = optional(list(object({
      upstream_repository_name = string
    })))
  }))
  default = []
}

variable "domain_policy" {
  type = list(object({
    action   = list(string)
    resource = string
    principal = map(string)
  }))
  default = [
    {
      action   = [
        "codeartifact:ListRepositoriesInDomain",
        "codeartifact:GetAuthorizationToken",
        "codeartifact:CreateRepository",
        "codeartifact:DescribeDomain",
        "codeartifact:GetDomainPermissionsPolicy"
      ]
      resource = "arn:aws:codeartifact:*"
      principal = {
        "AWS": "*"
      }
    },
  ]
}

# read-only repository access
variable "repository_policies" {
  type = map(list(object({
    action   = list(string)
    resource = string
    principal = map(string)
  })))
  default = {
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
