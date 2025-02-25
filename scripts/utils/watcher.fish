# Description: Repeats a script for X time in seconds
# Example: watcher [-n 2] "kubectl get pods -n sonarr"
function watcher
    check_command "watch"
    # Check if at least one argument (command) is provided
    if test (count $argv) -lt 1
        echo "Usage: watcher [interval] <command...>"
        return 1
    end

    # Default interval is 5 seconds
    set INTERVAL 5

    # If the first argument is a number, use it as the interval
    if echo $argv[1] | grep -qE '^[0-9]+$'
        set INTERVAL $argv[1]
        set argv (tail -n +2 $argv)  # Shift to remove interval argument, leaving only the command
    end

    # Run watch with the determined interval and command
    watch -n $INTERVAL $argv
end
