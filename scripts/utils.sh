# Function to check if a command is available
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 is not installed. Please install it before running this script."
    exit 1
  fi
}
