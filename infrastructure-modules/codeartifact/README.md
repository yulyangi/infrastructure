# Usage

## terragrunt.hcl
```
terraform {
  source = "path/to/module
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  enable_codeartifact_domain              = true
  codeartifact_domain_name                = "domain_name"
  enable_codeartifact_domain_kms_key      = true
  codeartifact_domain_kms_key_description = "Codeartifact domain KMS key"
  codeartifact_repositories               = [
    {
      name        = "npm-repository"
      description = "NPM repository"
      external_connections = [{
        external_connection_name = "public:npmjs"
      }]
    },
    {
      name        = "npm-downstream"
      description = "NPM repository with upstream connection"
      upstream = [{
        upstream_repository_name = "npm-repository"
      }]
    },
  ]

  repository_policies = {
    "npm-repository" = [
      {
        action   = [
          "codeartifact:AssociateWithDownstreamRepository",
          "codeartifact:AssociateExternalConnection",
          "codeartifact:CopyPackageVersions",
          "codeartifact:DeletePackageVersions",
          "codeartifact:DeletePackage",
          "codeartifact:DeleteRepository",
          "codeartifact:DeleteRepositoryPermissionsPolicy",
          "codeartifact:DescribePackageVersion",
          "codeartifact:DescribeRepository",
          "codeartifact:DisassociateExternalConnection",
          "codeartifact:DisposePackageVersions",
          "codeartifact:GetPackageVersionReadme",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ListPackageVersionAssets",
          "codeartifact:ListPackageVersionDependencies",
          "codeartifact:ListPackageVersions",
          "codeartifact:ListPackages",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "codeartifact:PutRepositoryPermissionsPolicy",
          "codeartifact:ReadFromRepository",
          "codeartifact:UpdatePackageVersionsStatus",
          "codeartifact:UpdateRepository"
        ]
        resource = "*"
        principal = {
          "AWS" = "*"
        }
      }
    ]
  }

  tags = {
    "foo = "bar"
  }
}
```
