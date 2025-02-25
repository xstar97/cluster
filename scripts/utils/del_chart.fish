function del_chart
    if test (count $argv) -lt 2
        echo "Usage: del_chart CHART_NAME -n NAMESPACE [--helm] [--flux] [-y]"
        return 1
    end

    # Default values
    set chart_name ""
    set namespace ""
    set confirm_delete 0
    set use_helm 0
    set use_flux 0

    # Parse arguments
    set i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case "-n"
                set i (math $i + 1)
                set namespace $argv[$i]
            case "--helm"
                set use_helm 1
            case "--flux"
                set use_flux 1
            case "-y"
                set confirm_delete 1
            case "*"
                if test -z "$chart_name"
                    set chart_name $argv[$i]
                else
                    echo "Invalid argument: $argv[$i]"
                    return 1
                end
        end
        set i (math $i + 1)
    end

    # Ensure required parameters are set
    if test -z "$chart_name" -o -z "$namespace"
        echo "Error: CHART_NAME and NAMESPACE are required."
        return 1
    end

    if test $use_helm -eq 0 -a $use_flux -eq 0
        echo "Error: Must specify at least one of --helm or --flux."
        return 1
    end

    # Confirmation prompt before deleting
    if test $confirm_delete -eq 0
        echo -n "Are you sure you want to delete '$chart_name' from namespace '$namespace' using"
        if test $use_helm -eq 1; echo -n " Helm"; end
        if test $use_flux -eq 1; echo -n " Flux"; end
        echo "? (y/N): "
        
        read -l confirm
        if not test "$confirm" = "y" -o "$confirm" = "Y"
            echo "Deletion canceled."
            return 0
        end
    end

    # Perform deletion
    if test $use_helm -eq 1
        echo "Uninstalling Helm release '$chart_name' from namespace '$namespace'..."
        helm uninstall $chart_name -n $namespace
    end

    if test $use_flux -eq 1
        echo "Deleting Flux HelmRelease '$chart_name' from namespace '$namespace'..."
        flux delete hr $chart_name -n $namespace
    end
end
