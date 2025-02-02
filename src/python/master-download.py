import sys
import requests
import os

VERSION = "master-download v1.0\nby PhateValleyman\nJonas.Ned@outlook.com"

HELP_MSG = """Usage: master-download [-u|--url] <GitHubUser/Repo> [-o|--output] <filename>
Options:
  -u, --url <GitHubUser/Repo>    Specify GitHub repository (e.g., PhateValleyman/ccat)
  -o, --output <filename>        Specify output filename (without extension)
  -v, --version                  Show script version
  -h, --help                     Show this help message"""

def print_help():
    print(HELP_MSG)

def url_exists(url):
    try:
        response = requests.head(url)
        return response.status_code == 200
    except requests.RequestException:
        return False

def download_file(url, filepath):
    response = requests.get(url, stream=True)
    with open(filepath, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

def main():
    args = sys.argv[1:]
    if not args:
        print_help()
        return

    github_repo = ""
    output_file = ""

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in ("-u", "--url"):
            if i + 1 < len(args):
                github_repo = args[i + 1]
                i += 1
        elif arg in ("-o", "--output"):
            if i + 1 < len(args):
                output_file = args[i + 1]
                i += 1
        elif arg in ("-v", "--version"):
            print(VERSION)
            return
        elif arg in ("-h", "--help"):
            print_help()
            return
        else:
            if not github_repo:
                github_repo = arg
            elif not output_file:
                output_file = arg
            else:
                print(f"Unknown argument: {arg}")
                print_help()
                return
        i += 1

    if not github_repo:
        print_help()
        return

    parts = github_repo.split('/')
    if len(parts) != 2:
        print("Invalid GitHub repository format. Expected: GitHubUser/Repo")
        return

    github_user, repo_name = parts

    tag_url = f"https://api.github.com/repos/{github_user}/{repo_name}/releases/latest"
    response = requests.get(tag_url)
    if response.status_code != 200:
        latest_tag = None
    else:
        latest_tag = response.json().get('tag_name')

    if latest_tag:
        download_url = f"https://github.com/{github_user}/{repo_name}/archive/refs/tags/{latest_tag}.tar.gz"
        extension = "tar.gz"
    else:
        download_url = f"https://github.com/{github_user}/{repo_name}/archive/refs/heads/master.zip"
        extension = "zip"

    if not url_exists(download_url):
        download_url = download_url.replace(".tar.gz", ".zip")
        extension = "zip"

    if not output_file:
        if latest_tag:
            output_file = f"{github_user}_{repo_name}_{latest_tag}"
        else:
            output_file = f"{github_user}_{repo_name}"

    print(f"Downloading: {download_url}")
    download_file(download_url, f"{output_file}.{extension}")

    print(f"File saved as: {output_file}.{extension}")

if __name__ == "__main__":
    main()
