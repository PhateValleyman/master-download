#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'open-uri'

VERSION = "master-download v1.0\nby PhateValleyman\nJonas.Ned@outlook.com"

HELP_MSG = <<~END_HELP
  Usage: master-download [-u|--url] <GitHubUser/Repo> [-o|--output] <filename>
  Options:
    -u, --url <GitHubUser/Repo>    Specify GitHub repository (e.g., PhateValleyman/ccat)
    -o, --output <filename>        Specify output filename (without extension)
    -v, --version                  Show script version
    -h, --help                     Show this help message
END_HELP

def print_help
  puts HELP_MSG
end

def url_exists?(url)
  uri = URI(url)
  request = Net::HTTP.new(uri.host, uri.port)
  request.use_ssl = true if uri.scheme == 'https'
  response = request.request_head(uri.path)
  response.code == '200'
rescue
  false
end

def download_file(url, filepath)
  File.open(filepath, 'wb') do |file|
    URI.open(url) do |uri|
      file.write(uri.read)
    end
  end
end

args = ARGV
if args.empty?
  print_help
  exit
end

github_repo = nil
output_file = nil

i = 0
while i < args.length
  arg = args[i]
  case arg
  when '-u', '--url'
    github_repo = args[i + 1]
    i += 1
  when '-o', '--output'
    output_file = args[i + 1]
    i += 1
  when '-v', '--version'
    puts VERSION
    exit
  when '-h', '--help'
    print_help
    exit
  else
    if github_repo.nil?
      github_repo = arg
    elsif output_file.nil?
      output_file = arg
    else
      puts "Unknown argument: #{arg}"
      print_help
      exit 1
    end
  end
  i += 1
end

if github_repo.nil?
  print_help
  exit 1
end

parts = github_repo.split('/')
if parts.length != 2
  puts "Invalid GitHub repository format. Expected: GitHubUser/Repo"
  exit 1
end

github_user, repo_name = parts

tag_url = "https://api.github.com/repos/#{github_user}/#{repo_name}/releases/latest"
uri = URI(tag_url)
response = Net::HTTP.get(uri)
latest_tag = JSON.parse(response)['tag_name'] rescue nil

download_url = if latest_tag
                "https://github.com/#{github_user}/#{repo_name}/archive/refs/tags/#{latest_tag}.tar.gz"
              else
                "https://github.com/#{github_user}/#{repo_name}/archive/refs/heads/master.zip"
              end
extension = latest_tag ? 'tar.gz' : 'zip'

unless url_exists?(download_url)
  download_url = download_url.sub('.tar.gz', '.zip')
  extension = 'zip'
end

output_file ||= if latest_tag
                 "#{github_user}_#{repo_name}_#{latest_tag}"
               else
                 "#{github_user}_#{repo_name}"
               end

puts "Downloading: #{download_url}"
download_file(download_url, "#{output_file}.#{extension}")

puts "File saved as: #{output_file}.#{extension}"
