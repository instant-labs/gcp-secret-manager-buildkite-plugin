#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  # Uncomment to enable stub debugging
  # export GCLOUD_STUB_DEBUG=/dev/tty
}

pre_exit_hook="$PWD/hooks/pre-exit"

@test "Revokes the account which the environment hook activated" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ACTIVATED_ACCOUNT="test@test-project.iam.gserviceaccount.com"

  stub gcloud \
    "auth revoke test@test-project.iam.gserviceaccount.com : echo 'Revoked credentials'"

  run "${pre_exit_hook}"

  assert_success
  assert_output --partial "Revoking the GCP Secret Manager credentials"

  unstub gcloud
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ACTIVATED_ACCOUNT
}

@test "Fails when the account cannot be revoked" {
  export BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ACTIVATED_ACCOUNT="test@test-project.iam.gserviceaccount.com"

  stub gcloud \
    "auth revoke test@test-project.iam.gserviceaccount.com : exit 1"

  run "${pre_exit_hook}"

  assert_failure
  assert_output --partial "Failed to revoke the credentials for test@test-project.iam.gserviceaccount.com"
  assert_output --partial "The credentials stay active in the gcloud configuration on this agent."

  unstub gcloud
  unset BUILDKITE_PLUGIN_GCP_SECRET_MANAGER_ACTIVATED_ACCOUNT
}

@test "Does nothing when the plugin used the application default credentials" {
  run "${pre_exit_hook}"

  assert_success
  refute_output --partial "Revoking the GCP Secret Manager credentials"
}
