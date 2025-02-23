# utils/check_command.fish

# Function to check if a command is available
function check_command
    if not command -v $argv[1] >/dev/null
        echo "Error: Command '$argv[1]' is not installed. Please install it before running this script."
        exit 1  # Exit script with error code
    end
    echo "Command '$argv[1]' is available."
end
