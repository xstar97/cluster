# Description: Generates Alias commands
# Example: gen_alias [--config /path/to/alias.yaml]
function gen_alias
    # Default YAML file path
    set default_yaml_file "./aliases.yaml"
    set yaml_file $default_yaml_file

    # Flag to check if custom config was used
    set custom_config_used 0

    # Parse options
    for arg in $argv
        switch $arg
            case '--config'
                set yaml_file (string split '=' $argv[2]) # Fetch the config file path from the flag
                set custom_config_used 1
                break
            case '*'
                # Handle other flags or arguments if necessary
                echo "Unknown argument: $arg"
                break
        end
    end

    # Display which YAML file is being used
    if test $custom_config_used -eq 1
        echo "Using custom YAML file: $yaml_file"
    else
        echo "Using default YAML file: $yaml_file"
    end

    # Check if 'yq' command is available
    check_command "yq"
    
    # Read the YAML file and set aliases
    echo "Reading aliases from YAML file: $yaml_file"
    for key in (yq eval '.aliases | keys | .[]' $yaml_file)
        echo "Processing alias: $key"
        set value (yq eval ".aliases[\"$key\"]" $yaml_file)
        echo "Setting alias '$key' to '$value'"
        alias $key "$value" --save
    end

    echo "Aliases have been successfully set. Please verify."
    
    # List all aliases set
    alias
end
