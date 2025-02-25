function stop_all
    check_command "kubectl"
    
    # Ensure chart name is provided
    if test (count $argv) -lt 1
        echo "Usage: stop_all <chart-name> -n <namespace> [--status]"
        return 1
    end

    set CHART_NAME $argv[1]
    set NAMESPACE $CHART_NAME

    # Parse flags
    set status_flag 0

    for i in (seq 2 (count $argv))
        switch $argv[$i]
            case '-n'
                set NAMESPACE $argv[(math $i + 1)]
                break
            case '--status'
                set status_flag 1
            case '*'
                echo "Invalid argument: $argv[$i]"
                return 1
        end
    end

    # If --status is set, check current state
    if test $status_flag -eq 1
        echo "...checking state"
        set CURRENT_STATE (kubectl get helmrelease $CHART_NAME -n $NAMESPACE -o jsonpath='{.spec.values.global.stopAll}' 2>/dev/null)
        
        if test -z "$CURRENT_STATE"
            echo "Error: Could not retrieve stopAll value for $CHART_NAME in namespace $NAMESPACE"
            return 1
        end

        echo "stopAll is $CURRENT_STATE"
        return 0
    end

    # Get current stopAll value and toggle it
    echo "...checking current state"
    set CURRENT_STATE (kubectl get helmrelease $CHART_NAME -n $NAMESPACE -o jsonpath='{.spec.values.global.stopAll}' 2>/dev/null)

    if test -z "$CURRENT_STATE"
        echo "Error: Could not retrieve stopAll value for $CHART_NAME in namespace $NAMESPACE"
        return 1
    end

    echo "Current stopAll is $CURRENT_STATE"

    # Toggle stopAll value
    set NEW_STATE "true"
    if test "$CURRENT_STATE" = "true"
        set NEW_STATE "false"
    end

    echo "Setting stopAll to $NEW_STATE"

    # Apply the patch to toggle stopAll value
    kubectl patch helmrelease $CHART_NAME -n $NAMESPACE --type='merge' -p \
      "{\"spec\":{\"values\":{\"global\":{\"stopAll\":$NEW_STATE}}}}"

    echo "stopAll is now $NEW_STATE"
end
