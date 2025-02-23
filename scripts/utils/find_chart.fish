function find_chart
    if test (count $argv) -ne 3; or test "$argv[1]" != "--check"; or test "$argv[2]" != "--keyword"
        echo "Usage: find_chart --check --keyword <keyword_to_search>"
        return 1
    end

    set keyword $argv[3]
    set search_dir "$BASE_PATH/clusters/main/kubernetes"

    if test -z "$keyword"
        echo "Error: Please provide a keyword to search using the --keyword flag."
        return 1
    end

    # Find all helm-release.yaml files in the search directory
    find "$search_dir" -type f -name "helm-release.yaml" | while read -l file
        # Extract the chart name based on directory structure
        set chart_name (basename (dirname (dirname "$file")))

        # Check if the keyword is present in the chart's YAML file
        if grep -q "$keyword" "$file"
            echo -e "Chart: $chart_name\nPath: $file\n"
        end
    end
end