#!/usr/bin/bash

set -eux

container_policy_dir="/etc/containers"

jq -s 'reduce .[] as $x ({}; . * $x)' \
    "$container_policy_dir"/policy.json \
    "$container_policy_dir"/policy-mods.json | \
    tee "$container_policy_dir"/policy.json.tmp && \
    mv "$container_policy_dir"/policy.json.tmp "$container_policy_dir"/policy.json
