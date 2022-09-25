#!/bin/sh -e

warn() {
  echo "$@" >&2
}

clean() {
  rm -f .include .githublist .fulllist .filter .results
}
trap clean EXIT INT
clean

grep -v '^[# ].*' filter | sort -u > .filter
grep -v '^[# ].*' include | sort -u > .include

command -v gh >/dev/null || warn 'gh commandline not found, please install to discover kiss-repo repositories on github'
gh auth status 2>/dev/null || warn 'gh auth status error, please login with gh auth login'
gh auth status 2>/dev/null && {
  gh api graphql --field query=@github_kiss-repo.gql > .results
  echo "$(jq -r '.data.search.repositoryCount' .results)" repositories found >&2
  jq -r '.data.search.edges[].node.url' .results >> .include
}

sort -u .include >_
mv _ .include

comm -23 .include .filter
