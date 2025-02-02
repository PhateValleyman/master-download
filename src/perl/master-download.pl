#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use JSON;

my $VERSION = "master-download v1.0\nby PhateValleyman\nJonas.Ned\@outlook.com";

my $HELP_MSG = <<'END_HELP';
Usage: master-download [-u|--url] <GitHubUser/Repo> [-o|--output] <filename>
Options:
  -u, --url <GitHubUser/Repo>    Specify GitHub repository (e.g., PhateValleyman/ccat)
  -o, --output <filename>        Specify output filename (without extension)
  -v, --version                  Show script version
  -h, --help                     Show this help message
END_HELP

sub print_help {
    print $HELP_MSG;
}

sub url_exists {
    my ($url) = @_;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->head($url);
    return $response->is_success;
}

sub download_file {
    my ($url, $filepath) = @_;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get($url);
    if ($response->is_success) {
        open(my $fh, '>', $filepath) or die "Could not open file '$filepath' $!";
        print $fh $response->decoded_content;
        close($fh);
    } else {
        die "Failed to download file: " . $response->status_line;
    }
}

my @args = @ARGV;
if (!@args) {
    print_help();
    exit;
}

my ($github_repo, $output_file);
for (my $i = 0; $i < @args; $i++) {
    my $arg = $args[$i];
    if ($arg eq '-u' || $arg eq '--url') {
        $github_repo = $args[++$i];
    } elsif ($arg eq '-o' || $arg eq '--output') {
        $output_file = $args[++$i];
    } elsif ($arg eq '-v' || $arg eq '--version') {
        print $VERSION;
        exit;
    } elsif ($arg eq '-h' || $arg eq '--help') {
        print_help();
        exit;
    } else {
        if (!$github_repo) {
            $github_repo = $arg;
        } elsif (!$output_file) {
            $output_file = $arg;
        } else {
            print "Unknown argument: $arg\n";
            print_help();
            exit 1;
        }
    }
}

if (!$github_repo) {
    print_help();
    exit 1;
}

my ($github_user, $repo_name) = split('/', $github_repo);
if (!$github_user || !$repo_name) {
    print "Invalid GitHub repository format. Expected: GitHubUser/Repo\n";
    exit 1;
}

my $tag_url = "https://api.github.com/repos/$github_user/$repo_name/releases/latest";
my $ua = LWP::UserAgent->new;
my $response = $ua->get($tag_url);
my $latest_tag;
if ($response->is_success) {
    my $json = decode_json($response->decoded_content);
    $latest_tag = $json->{'tag_name'};
}

my $download_url;
my $extension = "tar.gz";
if ($latest_tag) {
    $download_url = "https://github.com/$github_user/$repo_name/archive/refs/tags/$latest_tag.tar.gz";
} else {
    $download_url = "https://github.com/$github_user/$repo_name/archive/refs/heads/master.zip";
    $extension = "zip";
}

if (!url_exists($download_url)) {
    $download_url =~ s/\.tar\.gz$/.zip/;
    $extension = "zip";
}

if (!$output_file) {
    if ($latest_tag) {
        $output_file = "${github_user}_${repo_name}_${latest_tag}";
    } else {
        $output_file = "${github_user}_${repo_name}";
    }
}

print "Downloading: $download_url\n";
download_file($download_url, "$output_file.$extension");

print "File saved as: $output_file.$extension\n";
