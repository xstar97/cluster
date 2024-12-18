#!/bin/bash

# Define variables
GITHUB_REPO="truecharts/public"
DOWNLOAD_DIR="/home/tmp"
INSTALL_DIR="/usr/local/bin"
BACKUP_DIR="/home/backup"
VERSION_FILE="$DOWNLOAD_DIR/latest.txt"
FORCE_UPDATE=false
SPECIFIC_VERSION=""
CLUSTER_TOOL="clustertool"

# Check for flags
while getopts "fv:" option; do
    case $option in
        f) FORCE_UPDATE=true ;;
        v) SPECIFIC_VERSION="$OPTARG" ;;
        *) echo "Usage: $0 [-f] [-v version]"; exit 1 ;;
    esac
done

# Function to fetch the latest tag from GitHub
fetch_latest_tag() {
    if [[ -n "$SPECIFIC_VERSION" ]]; then
        echo "Using specified version: $SPECIFIC_VERSION"
        LATEST_TAG="$SPECIFIC_VERSION"
    else
        echo "Fetching the latest tag..."
        LATEST_TAG=$(curl -s https://api.github.com/repos/$GITHUB_REPO/tags | grep 'name' | head -n 1 | cut -d '"' -f 4)
        if [[ -z "$LATEST_TAG" ]]; then
            echo "Error: Could not fetch the latest tag. Exiting."
            exit 1
        fi
        echo "Latest tag is: $LATEST_TAG"
    fi
}

# Function to check the last downloaded version
check_last_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        LAST_VERSION=$(cat "$VERSION_FILE")
        echo "Last downloaded version: $LAST_VERSION"
    else
        echo "No previous version found. This is the first download."
        LAST_VERSION=""
    fi
}

# Function to download and install the new version
download_and_install() {
    # Construct the download URL
    ARCHIVE_NAME="clustertool_${LATEST_TAG//v/}_linux_amd64.tar.gz" # Remove 'v' from the tag
    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$LATEST_TAG/$ARCHIVE_NAME"

    echo "Downloading $ARCHIVE_NAME from $DOWNLOAD_URL..."
    curl -L -o "$DOWNLOAD_DIR/$ARCHIVE_NAME" "$DOWNLOAD_URL"

    # Check if the file was successfully downloaded
    if [[ $? -ne 0 || ! -f "$DOWNLOAD_DIR/$ARCHIVE_NAME" ]]; then
        echo "Error: Download failed. Exiting."
        exit 1
    fi

    # Check if the downloaded file is large enough to be a valid tar.gz (e.g., not a 404 page)
    FILE_SIZE=$(stat -c%s "$DOWNLOAD_DIR/$ARCHIVE_NAME")
    if [[ $FILE_SIZE -lt 1000 ]]; then
        echo "Error: The downloaded file is too small and likely invalid. Exiting."
        exit 1
    fi

    # Verify that the file is a valid tar.gz
    FILE_TYPE=$(file "$DOWNLOAD_DIR/$ARCHIVE_NAME" | grep 'gzip compressed data')
    if [[ -z "$FILE_TYPE" ]]; then
        echo "Error: The downloaded file is not a valid gzip archive. Exiting."
        exit 1
    fi

    # Backup existing clustertool if it exists (any case: clustertool, ClusterTool, etc.)
    echo "Checking for existing clustertool files..."
    EXISTING_TOOL=$(find "$INSTALL_DIR" -iname "$CLUSTER_TOOL")
    if [[ -n "$EXISTING_TOOL" ]]; then
        echo "Backing up existing clustertool..."
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        mv "$EXISTING_TOOL" "$BACKUP_DIR/clustertool_$TIMESTAMP"
        if [[ $? -eq 0 ]]; then
            echo "Backup created at $BACKUP_DIR/clustertool_$TIMESTAMP"
        else
            echo "Error: Failed to create backup. Exiting."
            exit 1
        fi
    fi

    # Unarchive the downloaded file
    echo "Extracting $ARCHIVE_NAME..."
    tar -xvzf "$DOWNLOAD_DIR/$ARCHIVE_NAME" -C "$DOWNLOAD_DIR"

    # Check if extraction was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Extraction failed. Exiting."
        exit 1
    fi

    # Find the downloaded clustertool file (case insensitive) and rename to lowercase
    DOWNLOADED_TOOL=$(find "$DOWNLOAD_DIR" -iname "$CLUSTER_TOOL")
    if [[ -z "$DOWNLOADED_TOOL" ]]; then
        echo "Error: Could not find the clustertool binary after extraction. Exiting."
        exit 1
    fi

    LOWERCASE_TOOL="$DOWNLOAD_DIR/$CLUSTER_TOOL"
    mv "$DOWNLOADED_TOOL" "$LOWERCASE_TOOL"

    # Move the new clustertool to /usr/local/bin
    echo "Installing the new version of clustertool..."
    mv "$LOWERCASE_TOOL" "$INSTALL_DIR/"

    if [[ $? -eq 0 ]]; then
        echo "Installation complete. clustertool is available in $INSTALL_DIR."
    else
        echo "Error: Installation failed."
        exit 1
    fi

    # Store the latest version in latest.txt
    echo "$LATEST_TAG" > "$VERSION_FILE"
    echo "Stored the latest version ($LATEST_TAG) in $VERSION_FILE."

    # Cleanup downloaded files
    echo "Cleaning up..."
    rm -f "$DOWNLOAD_DIR/$ARCHIVE_NAME"

    echo "Done!"
}

# Main script execution
fetch_latest_tag
check_last_version

# Compare versions and download if necessary, or force download if -f is passed
if [[ "$FORCE_UPDATE" = true ]]; then
    echo "Force update enabled. Proceeding with download and installation..."
    download_and_install
elif [[ "$LATEST_TAG" != "$LAST_VERSION" ]]; then
    echo "A new version is available. Proceeding with download and installation..."
    download_and_install
else
    echo "The latest version ($LATEST_TAG) is already installed. No update needed."
fi
