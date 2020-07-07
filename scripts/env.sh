#!/usr/bin/env bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

log() { echo "$1" >&2; }

ZONE="europe-west1-b"

export PROJECT_1=PROJECTA
export PROJECT_2=PROJECTB

ISTIO_VERSION=${ISTIO_VERSION:=1.4.2}
NODE_TYPE="n1-standard-4"

if [[ ! -f CLUSTER_PREFIX ]]; then
	PREFIX=$(head /dev/urandom | tr -dc a-z | head -c 6)
	echo $PREFIX > CLUSTER_PREFIX
else
	PREFIX=$(cat CLUSTER_PREFIX)
fi

PROJECT_1="${PROJECT_1:?PROJECT_1 env variable must be specified}"
CLUSTER_1="$PREFIX-dual-cluster1"
CTX_1="gke_${PROJECT_1}_${ZONE}_${CLUSTER_1}"

PROJECT_2="${PROJECT_2:?PROJECT_2 env variable must be specified}"
CLUSTER_2="$PREFIX-dual-cluster2"
CTX_2="gke_${PROJECT_2}_${ZONE}_${CLUSTER_2}"
