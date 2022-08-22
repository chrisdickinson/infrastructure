data "github_repositories" "deployable" {
  query = "org:chrisdickinson topic:deployable"
}

data "github_repository" "deployable" {
  full_name = element(data.github_repositories.deployable.full_names, count.index)
  count = length(data.github_repositories.deployable.full_names)
}

data "external" "ensure_deploy" {
  program = ["/bin/bash", "${path.module}/scripts/ensure-deploy.sh"]
  query = {
    url = element(data.github_repository.deployable, count.index).ssh_clone_url
    deploy = "${path.module}/files/github-actions"
  }

  count = length(data.github_repository.deployable)
}
