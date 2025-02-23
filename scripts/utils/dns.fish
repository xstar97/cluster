# dns function to fetch and format DNS details for services
function dns
    check_command "kubectl"
    
    set app_names $argv

    # Get all namespaces and services
    if test (count $app_names) -eq 0
        set services (kubectl get service --no-headers -A | sort -u)
    else
        set pattern (string join '|' $app_names)
        set services (kubectl get service --no-headers -A | grep -E "^($pattern)[[:space:]]" | sort -u)
    end

    if test -z "$services"
        echo "No services found"
        return 1
    end

    set output ""

    # Iterate through each namespace and service
    for service in (string split "\n" $services)
        set namespace (echo $service | awk '{print $1}')
        set svc_name (echo $service | awk '{print $2}')
        set ports (echo $service | awk '{print $6}')

        # Print namespace header only when it changes
        if test "$namespace" != "$prev_namespace"
            set output "$output\n$namespace:"
        end
        
        # Construct the DNS URL format without http(s)
        set dns_name "$svc_name.$namespace.svc.cluster.local"

        # Split ports on comma and iterate through each port/protocol
        for port in (string split "," $ports)
            set port_number (echo $port | cut -d'/' -f1)
            set protocol (echo $port | cut -d'/' -f2)
            set output "$output\n  $dns_name:$port_number | $protocol"
        end

        # Update previous namespace for comparison
        set prev_namespace "$namespace"
    end

    # Format and display the output
    echo -e (string trim -c ' ' $output)
end
