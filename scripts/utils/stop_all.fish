# stop_all function to toggle the 'stopAll' value in HelmRelease
function stop_all
    check_command "kubectl"
    # Ensure chart name is provided
    if test (count $argv) -lt 1
        echo "Usage: stop_all <chart-name> -n <namespace>"
        return 1
    end

    set CHART_NAME $argv[1]
    set NAMESPACE $CHART_NAME

    # Parse namespace flag if provided
    for i in (seq 2 (count $argv))
        switch $argv[$i]
        case '-n'
            set NAMESPACE $argv[(math $i + 1)]
            break
        end
    end

    echo "...checking state"

    # Get current stopAll value
    set CURRENT_STATE (kubectl get helmrelease $CHART_NAME -n $NAMESPACE -o jsonpath='{.spec.values.global.stopAll}' 2>/dev/null)

    if test -z "$CURRENT_STATE"
        echo "Error: Could not retrieve stopAll value for $CHART_NAME in namespace $NAMESPACE"
        return 1
    end

    echo "stopAll is $CURRENT_STATE"

    # Toggle stopAll value
    set NEW_STATE "true"
    if test "$CURRENT_STATE" = "true"
        set NEW_STATE "false"
    end

    echo "setting stopAll to $NEW_STATE"

    # Apply the patch
    kubectl patch helmrelease $CHART_NAME -n $NAMESPACE --type='merge' -p \
      "{\"spec\":{\"values\":{\"global\":{\"stopAll\":$NEW_STATE}}}}"

    echo "stopAll is now $NEW_STATE"
end
