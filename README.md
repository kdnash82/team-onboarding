# TEAM ONBOARDING
## Purpose
This repository can be used to quickly onboard a new developer teams.  It will create a namespace, service account, role and role binding, generate a kubeconfig for the specified namespace, and create a git repository from a gitlab template repository.  Once the newly created repo is created, a variable will be added to it that contains the base 64 encoded kubeconfig.
## VARIABLES
### These variables should be placed in Settings-CI/CD/Variables
- <b>GITLAB_TOKEN</b> - token that allows you the ability to create Git Repositories
- <b>GITLAB_URL</b> - URL to Gitlab
- <b>GROUP_ID</b> - ID of group that contains the template repository
- <b>KUBECONFIG</b> - Kubeconfig that allows for the creation of namespaces, service accounts, roles, and rolebinding.
- <b>PROJECT_ID</b> - ID of the template repository

## How to use this Repository
1. From the `team-onboarding` repository in Gitlab, select `CI/CD-Pipelines`
1. Choose the branch you would like to run the pipeline from.
1. Under the `Variables` section, enter a key of `NAMESPACE` and value of the teams name
1. Add a new variable with a key of `CONTEXT` and value of the cluster you wish to target
1. Select `Run Pipeline`

## Did it work? 
### Conduct the following from your terminal using the context you specified
1. `kubectl get ns <namespace>`
1. `kubectl get sa,role,rolebinding -n <namespace>`
### Conduct the following in Gitlab
1. Navigate to the Group and search for the newly created project
1. Select `Settings-CI/CD-Variables` and verify the `Kubeconfig` variable is present with a base64 encoded value
1. From the left dashboard, select `CI/CD-Pipelines` then select `Run Pipeline`

