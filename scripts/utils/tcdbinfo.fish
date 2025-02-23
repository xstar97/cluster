function tcdbinfo
    check_command "kubectl"
    # Get namespaces and secret names
    set namespaces (kubectl get secrets -A | grep -E "dbcreds|cnpg-main-urls" | awk '{print $1, $2}')

    # Prepare the table header
    set table_header "Application | Username | Password | Address | Port"

    # Initialize an empty list for storing rows
    set table_rows ""

    for namespace_secret in $namespaces
        set ns (echo $namespace_secret | awk '{print $1}')
        set secret (echo $namespace_secret | awk '{print $2}')

        # Extract application name
        set app_name $ns

        # Retrieve secret data
        if test "$secret" = "dbcreds"
            set creds (kubectl get secret $secret --namespace $ns -o jsonpath='{.data.url}' | base64 -d 2>/dev/null)
        else
            set creds (kubectl get secret $secret --namespace $ns -o jsonpath='{.data.std}' | base64 -d 2>/dev/null)
        end

        # Skip if creds are empty
        if test -z "$creds"
            continue
        end

        # Extract username
        set username (echo $creds | sed -E 's#^.*://([^:@]+):.*@\S+#\1#')

        # Extract password
        set password (echo $creds | sed -E 's#^.*://[^:@]+:([^@]+)@\S+#\1#')

        # Extract host address
        set addresspart (echo $creds | sed -E 's#^.*@([^:/]+):?.*#\1#')

        # Extract port
        set port (echo $creds | sed -E 's#^.*:([0-9]+)/.*#\1#')

        # Construct full address
        set full_address "$addresspart.$ns.svc.cluster.local"

        # Add this row to the table rows variable
        set table_rows "$table_rows\n$app_name | $username | $password | $full_address | $port"
    end

    # Output the table header and rows, and format it into columns
    echo -e "$table_header$table_rows" | column -t -s "|"
end
