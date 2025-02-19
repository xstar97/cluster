#!/bin/bash
# code generally taken from https://github.com/Heavybullets8/heavy_script/blob/main/functions/dns/dns_verbose.sh
# adapted for kubernetes/talos
# ./dns.sh to list all charts
# ./dns.sh namespace to list a namespace chart(s)

# Set the base path for the cluster
BASE_PATH="$PWD"

# Source the utility file
source $BASE_PATH/scripts/utils.sh

# Check if the following are installed
check_command "kubectl"

dns_verbose(){
    app_names=("${@}")

    # Get all namespaces and services
    if [[ ${#app_names[@]} -eq 0 ]]; then
        services=$(kubectl get service --no-headers -A | sort -u)
    else
        pattern=$(IFS='|'; echo "${app_names[*]}")
        services=$(kubectl get service --no-headers -A | grep -E "^($pattern)[[:space:]]" | sort -u)
    fi

    if [[ -z $services ]]; then
        echo "No services found"
        exit 1
    fi

    output=""

    # Iterate through each namespace and service
    while IFS=$'\n' read -r service; do
        namespace=$(echo "$service" | awk '{print $1}')
        svc_name=$(echo "$service" | awk '{print $2}')
        ports=$(echo "$service" | awk '{print $6}')

        # Print namespace header only when it changes
        if [[ "$namespace" != "$prev_namespace" ]]; then
            output+="\n${namespace}:\n"
        fi
        
        # Construct the DNS URL format without http(s)
        dns_name="${svc_name}.${namespace}.svc.cluster.local"

        # Split ports on comma and iterate through each port/protocol
        IFS=',' read -ra port_list <<< "$ports"
        for port in "${port_list[@]}"; do
            port_number=$(echo "$port" | cut -d'/' -f1)
            protocol=$(echo "$port" | cut -d'/' -f2)
            output+="  ${dns_name}:${port_number} | ${protocol}\n"
        done

        # Update previous namespace for comparison
        prev_namespace="$namespace"
    done <<< "$services"

    # Format and display the output
    echo -e "$output" | sed '1d;$d'
}

# Run the function with provided arguments
dns_verbose "$@"
