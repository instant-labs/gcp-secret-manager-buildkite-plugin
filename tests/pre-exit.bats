#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"
}

pre_exit_hook="$PWD/hooks/pre-exit"

@test "Removes the gcloud configuration of the job" {
  local config
  config="$(mktemp -d)"
  touch "${config}/credentials.db"

  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CLOUDSDK_CONFIG="${config}"

  run "${pre_exit_hook}"

  assert_success
  assert_output --partial "Removing the gcloud configuration of this job"
  refute [ -e "${config}" ]

  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_CLOUDSDK_CONFIG
}

@test "Does nothing when the plugin used the application default credentials" {
  run "${pre_exit_hook}"

  assert_success
  refute_output --partial "Removing the gcloud configuration of this job"
}
