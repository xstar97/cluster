# Description: This script checks if a command is available on the system.
# Example: check_command kubectl
function check_command
    if not command -v $argv[1] >/dev/null
        echo "Error: Command '$argv[1]' is not installed. Please install it before running this script."
        exit 1  # Exit script with error code
    end
    echo "Command '$argv[1]' is available."
end
