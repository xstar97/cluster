# Description: Gets the Chart and value data for a TC helm repo chart.
# Example: get_tc_info plex
function get_tc_info
    check_command "yq"
    check_command "helm"
    # Check if the chart name is provided
    if test (count $argv) -lt 1
        echo "Error: Chart name is required."
        echo "Usage: get_tc_info <chart_name> [--repo <repo_url>] [--values]"
        return 1
    end

    # Set chart name and repo defaults
    set chart_name $argv[1]
    set repo_url "oci://tccr.io/truecharts"  # Default repo URL
    set show_values 0  # Default to not show values

    # Parse the arguments for --repo and --values flags
    for arg in $argv[2..-1]  # Skip the chart_name argument
        switch $arg
            case "--repo"
                set repo_url $argv[(math (count $argv) - 1)]
            case "--values"
                set show_values 1
            case "--help"
                echo "Usage: get_tc_info <chart_name> [--repo <repo_url>] [--values]"
                echo "Options:"
                echo "  --repo <repo_url>  The repository URL (defaults to oci://tccr.io/truecharts)"
                echo "  --values           Show the default values of the chart"
                return 0
            case '*'
                echo "Error: Unknown option $arg"
                echo "Usage: get_tc_info <chart_name> [--repo <repo_url>] [--values]"
                return 1
        end
    end

    # Fetch chart details and parse it correctly into JSON
    set chart_info (helm show chart $repo_url/$chart_name | yq -o json)

    # Extract fields
    set chart_name (echo $chart_info | yq '.name')
    set chart_version (echo $chart_info | yq '.version')
    set chart_description (echo $chart_info | yq '.description')
    set chart_home (echo $chart_info | yq '.home')
    set chart_sources (echo $chart_info | yq '.sources[]')

    # Display the table
    begin
        echo "Chart Information:"
        echo "------------------------------------"
        echo "Name:          $chart_name"
        echo "Version:       $chart_version"
        echo "Description:   $chart_description"
        echo "Home:          $chart_home"
        echo "Sources:"
        
        # Print each source URL on a new line
        for source in $chart_sources
            echo "  - $source"
        end

        echo "------------------------------------"

        # If --values flag is set, show the values of the chart
        if test $show_values -eq 1
            echo "Values Information:"
            echo "------------------------------------"
            helm show values $repo_url/$chart_name
            echo "------------------------------------"
        end
    end
end
