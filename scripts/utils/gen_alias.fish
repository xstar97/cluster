# utils/gen_alias.fish

function gen_alias
    check_command "yq"
    # Path to YAML file
    set yaml_file "$PWD/scripts/aliases.yaml"

    # Check if yq (YAML processor) is installed
    if not command -q yq
        echo "Error: 'yq' is required to parse YAML. Install it using 'brew install yq' or 'sudo apt install yq'"
        exit 1
    end

    # Read the YAML file and set aliases
    for key in (yq eval '.aliases | keys | .[]' $yaml_file)
        set value (yq eval ".aliases[\"$key\"]" $yaml_file)
        alias $key "$value" --save
    end

    echo "Aliases set, verify."

    alias
end
