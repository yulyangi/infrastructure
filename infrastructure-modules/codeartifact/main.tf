# create optional domain kms encryption key
locals {
  kms_key_description = (
    var.codeartifact_domain_kms_key_description == "" ?
    "domain kms key for ${var.codeartifact_domain_name} domain" :
    var.codeartifact_domain_kms_key_description
  )
}

resource "aws_kms_key" "codeartifact_domain" {
  count       = var.enable_codeartifact_domain_kms_key ? 1 : 0
  description = local.kms_key_description
  tags        = var.tags
}

# create codeartifact domain
locals {
  encryption_key_arn = (
    var.enable_codeartifact_domain_kms_key ?
    one(aws_kms_key.codeartifact_domain[*].arn) :
    var.codeartifact_domain_kms_key_arn
  )
}

resource "aws_codeartifact_domain" "domain" {
  count          = var.enable_codeartifact_domain ? 1 : 0
  domain         = var.codeartifact_domain_name
  encryption_key = local.encryption_key_arn
  tags           = var.tags
}

locals {
  domain = (
    var.enable_codeartifact_domain ?
    one(aws_codeartifact_domain.domain[*].domain) :
    var.codeartifact_domain_name
  )

  domain_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      for statement in var.domain_policy : {
        Action    = statement.action,
        Effect    = "Allow",
        Resource  = statement.resource,
        Principal = statement.principal,
      }
    ]
  })
}

# create policy for the domain
resource "aws_codeartifact_domain_permissions_policy" "policy" {
  domain          = aws_codeartifact_domain.domain[0].domain
  policy_document = local.domain_policy
}

resource "aws_codeartifact_repository" "repository" {
  count       = length(var.codeartifact_repositories)
  repository  = var.codeartifact_repositories[count.index].name
  description = var.codeartifact_repositories[count.index].description
  domain      = local.domain
  tags        = var.tags

  dynamic "external_connections" {
    for_each = var.codeartifact_repositories[count.index].external_connections != null ? var.codeartifact_repositories[count.index].external_connections : []

    content {
      external_connection_name = external_connections.value.external_connection_name
    }
  }

  dynamic "upstream" {
    for_each = var.codeartifact_repositories[count.index].upstream != null ? var.codeartifact_repositories[count.index].upstream : []

    content {
      repository_name = upstream.value.upstream_repository_name
    }
  }
}

# create policy for the repositories
resource "aws_codeartifact_repository_permissions_policy" "this" {
  for_each        = { for repo in var.codeartifact_repositories : repo.name => repo }
  repository      = each.value.name
  domain          = aws_codeartifact_domain.domain[0].domain
  policy_document = jsonencode({
    Version   = "2012-10-17",
    Statement = flatten([
      for statement in lookup(var.repository_policies, each.key, []) : [
        {
          Action    = statement.action,
          Effect    = "Allow",
          Resource  = statement.resource,
          Principal = statement.principal
        }
      ]
    ])
  })

  depends_on = [
    aws_codeartifact_repository.repository
  ]
}
