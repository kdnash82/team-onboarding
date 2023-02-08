#!/bin/bash

# Define variables
namespace="$NAMESPACE"
gitlab_token="$GITLAB_TOKEN"
gitlab_url="$GITLAB_URL"
group_id="$GROUP_ID"
project_id="$PROJECT_ID"

# Get the group name from GitLab API using curl and jq
group_name=$(curl -k --header "PRIVATE-TOKEN: $gitlab_token" "$gitlab_url/api/v4/groups/$group_id" | jq -r '.name')

# Check if the group name is compliant with the pattern
if [[ ! "$group_name" =~ ^[a-z0-9_-]+$ ]]; then
  echo "Error: $group_name is non-compliant, exiting"
  exit 1
fi

# Loop through all the files in the directory
for file in ../team-onboarding.tmp/GROUP_"$namespace"*; do
  # Check if the file is a regular file
  if [[ -f "$file" ]]; then
    # Generate kubeconfig files using the group name
    kubeconfig_file=$(./generate-kubeconfigs.sh "${namespace}" < "$file")
    # Check if kubeconfig file is generated
    if [[ -n "$kubeconfig_file" ]]; then
      # Upload kubeconfig files to GitLab API using curl
      curl -k --header "PRIVATE-TOKEN: $gitlab_token" --header "Content-Type: multipart/form-data" --data-binary "@<(echo "$kubeconfig_file")" "$gitlab_url/api/v4/groups/$group_id/variables"
    fi
  fi
done

# Set the project name based on the namespace
template_name="${namespace}"

# Create a new project in GitLab API using curl 
new_project_id=$(curl -k --request POST --header "PRIVATE-TOKEN: $gitlab_token" \
"$gitlab_url/api/v4/projects?name=$namespace&namespace_id=$group_id&group_with_project_templates_id=$group_id&use_custom_template=true&template_project_id=$project_id" \
| jq '.id')


# Wait for 20 seconds
echo "Creating Git Repository $template_name"
sleep 20

# Set the build path for the newly created project
echo "Adding Variables to $template_name"
curl -k --request POST --header "PRIVATE-TOKEN: $gitlab_token" \
"$gitlab_url/api/v4/projects/$new_project_id/variables" \
--form "key=KUBE_CONFIG" \
--form "value=$KUBECONFIG_VARIABLE" 
