#!/bin/bash
# code generally taken from https://github.com/Heavybullets8/heavy_script/blob/main/functions/pod/container_shell_or_logs.sh
# ./containers.sh -s shell
# ./containers.sh -l logs
# ./containers.sh -h
# ./containers.sh -s|l NAMESPACE

# Display usage information
pod_help() {
    echo "Usage: pod_handler [option] [app_name]"
    echo
    echo "Options:"
    echo "  -l, --logs [app_name]    Show logs for a specific application's container"
    echo "  -s, --shell [app_name]   Open a shell in a specific application's container"
    echo "  -h, --help               Display this help message"
    echo
}

# Main function to handle pod-related commands
pod_handler() {
    local args=("$@")

    case "${args[0]}" in
        -l | --logs) container_shell_or_logs "logs" "${args[1]}" ;;
        -s | --shell) container_shell_or_logs "shell" "${args[1]}" ;;
        -h | --help) pod_help ;;
        *) 
            echo "Invalid option: ${args[0]}"
            pod_help
            exit 1
            ;;
    esac
}

# Helper function to display container logs or open a shell based on the mode
container_shell_or_logs() {
    mode="$1"
    cmd_get_app_names
    cmd_check_app_names
    cmd_header "$mode"

    if [[ -z $2 ]]; then
        cmd_display_app_menu
    else
        app_name=$2
    fi

    cmd_get_pod
    cmd_get_container

    if [[ $mode == "logs" ]]; then
        cmd_execute_logs
    else
        cmd_execute_shell
    fi
}

# Retrieve a list of application names
cmd_get_app_names() {
    app_names=$(kubectl get pods --field-selector=status.phase=Running -A |
                sed -E 's/[[:space:]]([0-9]*|About)[a-z0-9 ]{5,12}ago[[:space:]]//' |
                sed '1d' | awk '{print $2}' | sort -u)
    local num=1
    for app in $app_names; do
        app_map[num]=$app
        num=$((num+1))
    done
}
export -f cmd_get_app_names

# Check if there are any apps available
cmd_check_app_names() {
    if [ -z "$app_names" ]; then
        echo -e "${yellow}There are no applications available"
        exit 0
    fi
}

# Display header based on the mode
cmd_header() {
    clear -x
    title
    if [[ $1 == "logs" ]]; then
        echo -e "${bold}Logs to Container Menu${reset}"
    else
        echo -e "${bold}Command to Container Menu${reset}"
    fi
    echo -e "${bold}------------------------${reset}"
}

# Print selected application, pod, and container details
cmd_print_app_pod_container() {
    clear -x
    title
    [[ -n $app_name ]] && echo -e "${bold}App Name:${reset}  ${blue}${app_name}${reset}"
    [[ -n $pod ]] && echo -e "${bold}Pod:${reset}       ${blue}${pod}${reset}"
    [[ -n $container ]] && echo -e "${bold}Container:${reset} ${blue}${container}${reset}"
}

# Display application menu and let the user select an app
cmd_display_app_menu() {
    local selection
    while true; do
        for i in "${!app_map[@]}"; do
            printf "%d) %s\n" "$i" "${app_map[$i]}"
        done | sort -n
        echo -e "0) Exit"
        read -r -t 120 -p "Please type a number: " selection || { echo -e "${red}\nFailed to make a selection in time${reset}"; exit; }

        if [[ $selection == 0 ]]; then
            echo "Exiting..."
            exit
        elif ! [[ $selection =~ ^[0-9]+$ ]] || ! [[ ${app_map[$selection]} ]]; then
            echo -e "${red}Invalid selection: \"$selection\". Try again.${reset}"
            sleep 3
        else
            app_name=${app_map[$selection]}
            break
        fi
    done
}
export -f cmd_display_app_menu

# Retrieve a list of pods for the selected application
cmd_get_pod() {
    local pods
    mapfile -t pods < <(kubectl get pods --namespace "$app_name" -o custom-columns=NAME:.metadata.name --no-headers | sort)

    if [[ ${#pods[@]} -eq 0 ]]; then
        echo -e "${red}No pods available${reset}"
        exit
    elif [[ ${#pods[@]} -eq 1 ]]; then
        pod=${pods[0]}
    else
        cmd_print_app_pod_container
        echo -e "${bold}Available Pods:${reset}"
        for i in "${!pods[@]}"; do
            echo "$((i+1))) ${pods[$i]}"
        done
        echo "0) Exit"
        read -r -p "Choose a pod by number: " pod_selection
        [[ $pod_selection == 0 ]] && { echo "Exiting..."; exit; }
        pod=${pods[$((pod_selection-1))]}
    fi
}
export -f cmd_get_pod

# Retrieve a list of containers for the selected pod
cmd_get_container() {
    local containers
    mapfile -t containers < <(kubectl get pods "$pod" --namespace "$app_name" -o jsonpath='{range.spec.containers[*]}{.name}{"\n"}{end}' | sort)

    if [[ ${#containers[@]} -eq 0 ]]; then
        echo -e "${red}No containers available${reset}"
        exit
    elif [[ ${#containers[@]} -eq 1 ]]; then
        container=${containers[0]}
    else
        cmd_print_app_pod_container
        echo -e "${bold}Available Containers:${reset}"
        for i in "${!containers[@]}"; do
            echo "$((i+1))) ${containers[$i]}"
        done
        echo "0) Exit"
        read -r -p "Choose a container by number: " container_selection
        [[ $container_selection == 0 ]] && { echo "Exiting..."; exit; }
        container=${containers[$((container_selection-1))]}
    fi
}
export -f cmd_get_container

# Execute shell in selected container
cmd_execute_shell() {
    while true; do
        cmd_print_app_pod_container
        echo -e "Press Enter/Spacebar to confirm, or Ctrl+C to exit"
        read -rsn1 -d ' ' ; echo
        kubectl exec -n "$app_name" "$pod" -c "$container" -it -- sh -c '[ -e /bin/bash ] && exec /bin/bash || exec /bin/sh'
        [[ $? -ne 130 ]] || break
    done
}
export -f cmd_execute_shell

# Display logs from selected container
cmd_execute_logs() {
    local lines=500
    while true; do
        cmd_print_app_pod_container
        read -rt 120 -p "How many lines of logs? (Default 500, \"-1\" for all): " lines_input || { echo -e "${red}\nTimed out${reset}"; exit; }
        lines=${lines_input:-500}
        [[ $lines =~ ^-1$|^[0-9]+$ ]] && break || echo -e "${red}Invalid number. Try again.${reset}"
    done
    kubectl logs --namespace "$app_name" --tail "$lines" -f "$pod" -c "$container" || echo -e "${red}Failed to retrieve logs${reset}"
}
export -f cmd_execute_logs

# Run pod_handler if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pod_handler "$@"
fi
