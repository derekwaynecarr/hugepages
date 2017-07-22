#!/bin/bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is for dynamically allocating huge pages on a Kubernetes node.

set -o errexit
#set -o pipefail
set -u
set -x

# The script must be run as a root.
# Input:
#
# Environment Variables
# NR_HUGEPAGES - Number of 2MB huge pages to allocate on the machine.  Defaults to 0
#

NR_HUGEPAGES=${NR_HUGEPAGES:-"0"}

allocate_huge_pages() {
    echo "$NR_HUGEPAGES" > /proc/sys/vm/nr_hugepages
}

verify_huge_pages() {
    nr_huge_pages=$(cat /proc/sys/vm/nr_hugepages)
    if [ "$NR_HUGEPAGES" -eq "$nr_huge_pages" ]
    then
        echo "huge pages allocated."
    else
        echo "huge pages not allocated."
        exit 1        
    fi    
}

exit_if_allocation_not_needed() {
    nr_huge_pages=$(cat /proc/sys/vm/nr_hugepages)
    if [ "$NR_HUGEPAGES" -eq "$nr_huge_pages" ]
    then
      echo "huge pages already allocated.  skipping allocation"
      exit 0
    fi
}

restart_kubelet() {
    echo "Sending SIGTERM to kubelet"
    if pidof kubelet &> /dev/null; then
        pkill -SIGTERM kubelet
    fi
}

post_allocation_sequence() {
    # Restart the kubelet for it to pick up the huge pages.
    restart_kubelet
}

main() {
    # Exit if installation is not required (for idempotency)
    exit_if_allocation_not_needed
    # Allocate the huge pages
    allocate_huge_pages
    # Verify the huge pages are allocated.
    verify_huge_pages
    # Perform post allocation steps
    post_allocation_sequence
}

main "$@"