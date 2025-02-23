# utils/hr_chart.fish

function hr_chart
    # Ensure a chart name is provided
    if test (count $argv) -lt 1
        echo "Usage: hr_chart <chart-name>"
        exit 1
    end

    set chart_name $argv[1]
    set base_path (pwd)  # Adjust this if BASE_PATH is defined elsewhere
    set matches (find "$base_path/clusters/main/kubernetes" -type f -path "*/helm-release.yaml" | grep -E "/$chart_name/")

    # Check how many matches were found
    if test (count $matches) -eq 0
        echo "No helm-release.yaml found for chart: $chart_name"
        exit 1
    else if test (count $matches) -eq 1
        set file $matches[1]
    else
        echo "Multiple matches found. Please select one:"
        for i in (seq (count $matches))
            echo "$i) $matches[$i]"
        end

        echo -n "Enter selection: "
        read selection

        if test -n "$selection" -a "$selection" -gt 0 -a "$selection" -le (count $matches)
            set file $matches[$selection]
        else
            echo "Invalid selection."
            exit 1
        end
    end

    echo "Selected file: $file"
end
