#!/usr/bin/env fish

# Configurable Paths
set BASE_PATH "$PWD"
set UTILS_DIR "./scripts/utils"
set AVAILABLE_FUNCTIONS ""

# Function to source all .fish files in the utils directory
function source_utils
    for script in (find $UTILS_DIR -type f -name "*.fish" 2>/dev/null)
        source $script
    end
end

# Function to get all available functions from the utils directory
function get_available_functions
    set available_functions ""
    for script in (find $UTILS_DIR -type f -name "*.fish" 2>/dev/null)
        set func_name (basename $script .fish)
        set available_functions $available_functions $func_name
    end
    # Clean up any leading/trailing spaces from the list and return
    echo (string trim $available_functions)
end

# Function to handle unknown commands
function handle_unknown_command
    echo "Error: Unknown function '$argv[1]'."
    echo "Available functions: (get_available_functions)"
    exit 1
end

# Function to display the function details (Description & Example)
function show_function_details
    set func_name $argv[1]
    set func_file (find $UTILS_DIR -type f -name "$func_name.fish" 2>/dev/null)

    if test -z "$func_file"
        echo "Error: Function '$func_name' not found."
        exit 1
    end

    set description (grep -m 1 "# Description:" $func_file | string replace -r "# Description: " "" | string trim)
    set example (grep -m 1 "# Example:" $func_file | string replace -r "# Example: " "" | string trim)

    echo "Function: $func_name"
    echo "Description: " (test -n "$description"; and echo "$description"; or echo "No description available.")
    echo "Example: " (test -n "$example"; and echo "$example"; or echo "No example available.")
end

# Function to call the requested function dynamically
function call_function
    set FUNCTION $argv[1]
    set FUNCTION_ARGS $argv[2..-1]

    if functions -q $FUNCTION
        $FUNCTION $FUNCTION_ARGS
    else
        handle_unknown_command $FUNCTION
    end
end

# Source the utils functions
source_utils

# Get the list of available functions
set available_functions (get_available_functions)

# Split the string into an array of function names and remove any empty entries
set available_functions_array (string split ' ' (string trim $available_functions))

# Main logic to handle function calls based on arguments
if test (count $argv) -gt 0
    # Check if -h flag is passed
    if test "$argv[1]" = "-h"
        if test (count $argv) -lt 2
            echo "Usage: utils.sh -h <function_name>"
            echo "Use '-h' to get details for a specific function."
            exit 1
        end
        show_function_details $argv[2]
        exit 0
    end

    # Otherwise, call the requested function
    call_function $argv
else
    echo "Usage: utils.sh <function> [args...]"
    echo "Available functions:"

    # Print the list of discovered functions (one per line)
    for func in $available_functions_array
        if test -n "$func" # Only print non-empty functions
            echo "- $func"
        end
    end

    exit 1
end
