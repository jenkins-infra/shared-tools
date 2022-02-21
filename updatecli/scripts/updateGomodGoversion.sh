#!/bin/sh
## This script updates the go version of a go mod file and prints the resulting content in the stdout
## Please note that it will NEVER change the go.mod file (works in a temp directory)
##
## Expected arguments:
## - 1: the path to the go.mod file
## - 2: the new golang version in semver format (major.minor.patch)

set -eux

go_mod_dir="$(dirname "${1}")"
go_version="${2}"
new_version="$(echo "${go_version}" | cut -d. -f1,2)"
tmp_dir="$(mktemp -d)"

## Ensure a golang version is installed
{
  if ! command -v go
  then
    echo "NO GO INSTALLED"
    exit 1
  fi
  echo "using go version: $(go version)"
} >&2

## Copies go mod's directory to a temp directory an starts working from this temp. dir.
cp -r "${go_mod_dir}"/* "${tmp_dir}" >&2
cd "${tmp_dir}" >&2
GOPATH="$(mktemp -d)"
export GOPATH

## Updates go mod properly
go mod edit -go="${new_version}" >&2
go mod tidy >&2
echo "" >> go.mod # Add empty endline to be POSIX compliant

## Shows new go mod
cat go.mod
exit 0
