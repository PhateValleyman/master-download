#!/data/data/com.termux/files/usr/bin/bash

# Function to download the latest tagged release or master archive from a GitHub repository
master-download() {
    # Define script version
    local VERSION="master-download v1.0\nby PhateValleyman\nJonas.Ned@outlook.com"

    # Print help message
    local HELP_MSG="Usage: master-download [-u|--url] <GitHubUser/Repo> [-o|--output] <filename>
Options:
  -u, --url <GitHubUser/Repo>    Specify GitHub repository (e.g., PhateValleyman/ccat)
  -o, --output <filename>        Specify output filename (without extension)
  -v, --version                  Show script version
  -h, --help                     Show this help message"

    # Parse arguments
    local GITHUB_REPO=""
    local OUTPUT_FILE=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--url)
                GITHUB_REPO="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -v|--version)
                echo -e "$VERSION"
                return 0
                ;;
            -h|--help)
                echo -e "$HELP_MSG"
                return 0
                ;;
            *)
                if [[ -z "$GITHUB_REPO" ]]; then
                    GITHUB_REPO="$1"
                elif [[ -z "$OUTPUT_FILE" ]]; then
                    OUTPUT_FILE="$1"
                else
                    echo "Unknown argument: $1"
                    echo -e "$HELP_MSG"
                    return 1
                fi
                shift
                ;;
        esac
    done

    # If no repository is provided, show help
    if [[ -z "$GITHUB_REPO" ]]; then
        echo -e "$HELP_MSG"
        return 1
    fi

    # Extract GitHub username and repository name
    local GITHUB_USER=${GITHUB_REPO%%/*}  # Get the part before '/'
    local REPO_NAME=${GITHUB_REPO##*/}    # Get the part after '/'

    # Get the latest tag from GitHub API
    local TAG_URL="https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/releases/latest"
    local LATEST_TAG=$(curl -s "$TAG_URL" | grep -Po '"tag_name": "\K.*?(?=")')

    # Determine the archive to download
    local DOWNLOAD_URL=""
    local EXTENSION="tar.gz"  # Default to tar.gz

    if [[ -n "$LATEST_TAG" ]]; then
        # Use the latest tag if available
        DOWNLOAD_URL="https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/tags/$LATEST_TAG.tar.gz"
    else
        # Use the master branch if no tags are found
        DOWNLOAD_URL="https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/heads/master.tar.gz"
    fi

    # Check if tar.gz is available, otherwise try zip
    if ! curl --head --silent --fail "$DOWNLOAD_URL" >/dev/null; then
        DOWNLOAD_URL="${DOWNLOAD_URL%.tar.gz}.zip"
        EXTENSION="zip"
    fi

    # Define output file name if not provided
    if [[ -z "$OUTPUT_FILE" ]]; then
        if [[ -n "$LATEST_TAG" ]]; then
            OUTPUT_FILE="${GITHUB_USER}_${REPO_NAME}_${LATEST_TAG}"
        else
            OUTPUT_FILE="${GITHUB_USER}_${REPO_NAME}"
        fi
    fi

    # Download the file
    echo "Downloading: $DOWNLOAD_URL"
    curl -L "$DOWNLOAD_URL" -o "$OUTPUT_FILE.$EXTENSION"

    echo "File saved as: $OUTPUT_FILE.$EXTENSION"
}

# Call the function with passed arguments
master-download "$@"
