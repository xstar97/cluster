#!/usr/bin/env fish

# Set the base path for the cluster
set BASE_PATH "$PWD"

# Source all .fish files in the utils directory
for script in ./scripts/utils/*.fish
    source $script
end

# Function to handle unknown commands
function handle_unknown_command
    echo "Error: Unknown function '$argv[1]'."
    echo "Available functions: check_command, nvidia_smi"
    exit 1
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

# Get a list of all function files in the utils directory
set utils_dir ./scripts/utils
set function_files (ls $utils_dir/*.fish 2>/dev/null)

# Extract function names from files
set available_functions
for file in $function_files
    set func_name (basename $file .fish)
    set available_functions $available_functions $func_name
end

# Main logic to handle function calls based on arguments
if test (count $argv) -gt 0
    call_function $argv
else
    echo "Usage: utils.sh <function> [args...]"
    echo "Available functions:"
    
    # Print the list of discovered functions
    for func in $available_functions
        echo "    - $func"
    end

    exit 1
end