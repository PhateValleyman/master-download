# master-download

**master-download**
is a Bash function that allows you to download the
latest tagged release or the master archive of a
GitHub repository in `.tar.gz` or `.zip` format.

## Usage:
master-download [-u|--url] <GitHubUser/Repo> [-o|--output] <filename>
Options
-u, --url <GitHubUser/Repo>: Specify the GitHub repository (e.g., PhateValleyman/ccat).
-o, --output <filename>: Define the output filename (without extension).
-v, --version: Show script version.
-h, --help: Display help information.

## Examples:
Download the latest release of ccat from PhateValleyman:

master-download -u PhateValleyman/ccat

Download and specify a filename:

master-download -u PhateValleyman/ccat -o my_download

