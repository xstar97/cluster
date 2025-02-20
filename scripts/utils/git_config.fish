# utils/git_config.fish

function git_config
    set CONFIG "$BASE_PATH/clusters/main/clusterenv.yaml"

    # Check if required commands are installed
    check_command "yq"
    check_command "git"
    check_command "clustertool"

    # Check if the YAML file exists
    if test ! -f "$CONFIG"
        echo "Error: $CONFIG not found!"
        exit 1
    end

    # Read values from the YAML file using yq
    set GITHUB_USER (yq eval '.GITHUB_USER' "$CONFIG")
    set GITHUB_EMAIL (yq eval '.GITHUB_EMAIL' "$CONFIG")

    # Check if the values are empty
    if test -z "$GITHUB_USER" -o -z "$GITHUB_EMAIL"
        echo "Error: GitHub username or email is missing in the YAML file!"
        exit 1
    end

    # decrypt the CONFIG file beforehand....
    clustertool decrypt

    # Echo the values to confirm
    echo "Setting Git username to: $GITHUB_USER"
    echo "Setting Git email to: $GITHUB_EMAIL"

    # Set the Git username and email globally
    git config --global user.name "$GITHUB_USER"
    git config --global user.email "$GITHUB_EMAIL"

    echo "Git username and email have been set successfully!"
end
