function del_pod
    check_command "kubectl"
    
    set test_mode false

    # Check if the first argument is -t for test mode
    if test (count $argv) -gt 0; and test "$argv[1]" = "-t"
        set test_mode true
    end

    # Fetch pods in an error state
    kubectl get pods -A | grep -E "Error|UnexpectedAdmissionError|CrashLoopBackOff|ContainerStatusUnknown|Init:0/1|Completed|OOMKilled" | while read -l namespace pod_name rest
        echo "Pod in error state:"
        echo "Namespace: $namespace, Pod: $pod_name"

        if $test_mode
            echo "Test Mode: kubectl delete pod $pod_name -n $namespace"
        else
            kubectl delete pod "$pod_name" -n "$namespace"
            echo "Deleted pod $pod_name in namespace $namespace."
        end
    end
end
