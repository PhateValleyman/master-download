package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

const version = "master-download v1.0\nby PhateValleyman\nJonas.Ned@outlook.com"

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		printHelp()
		return
	}

	var githubRepo, outputFile string
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "-u", "--url":
			if i+1 < len(args) {
				githubRepo = args[i+1]
				i++
			}
		case "-o", "--output":
			if i+1 < len(args) {
				outputFile = args[i+1]
				i++
			}
		case "-v", "--version":
			fmt.Println(version)
			return
		case "-h", "--help":
			printHelp()
			return
		default:
			if githubRepo == "" {
				githubRepo = args[i]
			} else if outputFile == "" {
				outputFile = args[i]
			} else {
				fmt.Println("Unknown argument:", args[i])
				printHelp()
				return
			}
		}
	}

	if githubRepo == "" {
		printHelp()
		return
	}

	parts := strings.Split(githubRepo, "/")
	if len(parts) != 2 {
		fmt.Println("Invalid GitHub repository format. Expected: GitHubUser/Repo")
		return
	}

	githubUser := parts[0]
	repoName := parts[1]

	tagURL := fmt.Sprintf("https://api.github.com/repos/%s/%s/releases/latest", githubUser, repoName)
	resp, err := http.Get(tagURL)
	if err != nil {
		fmt.Println("Error fetching latest tag:", err)
		return
	}
	defer resp.Body.Close()

	var release struct {
		TagName string `json:"tag_name"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&release); err != nil {
		fmt.Println("Error decoding JSON:", err)
		return
	}

	downloadURL := fmt.Sprintf("https://github.com/%s/%s/archive/refs/tags/%s.tar.gz", githubUser, repoName, release.TagName)
	extension := "tar.gz"

	if !urlExists(downloadURL) {
		downloadURL = fmt.Sprintf("https://github.com/%s/%s/archive/refs/heads/master.zip", githubUser, repoName)
		extension = "zip"
	}

	if outputFile == "" {
		if release.TagName != "" {
			outputFile = fmt.Sprintf("%s_%s_%s", githubUser, repoName, release.TagName)
		} else {
			outputFile = fmt.Sprintf("%s_%s", githubUser, repoName)
		}
	}

	fmt.Println("Downloading:", downloadURL)
	if err := downloadFile(downloadURL, outputFile+"."+extension); err != nil {
		fmt.Println("Error downloading file:", err)
		return
	}

	fmt.Println("File saved as:", outputFile+"."+extension)
}

func printHelp() {
	helpMsg := `Usage: master-download [-u|--url] <GitHubUser/Repo> [-o|--output] <filename>
Options:
  -u, --url <GitHubUser/Repo>    Specify GitHub repository (e.g., PhateValleyman/ccat)
  -o, --output <filename>        Specify output filename (without extension)
  -v, --version                  Show script version
  -h, --help                     Show this help message`
	fmt.Println(helpMsg)
}

func urlExists(url string) bool {
	resp, err := http.Head(url)
	if err != nil {
		return false
	}
	return resp.StatusCode == http.StatusOK
}

func downloadFile(url, filepath string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
}
