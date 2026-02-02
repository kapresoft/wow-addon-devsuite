#!/usr/bin/env bash
_shasum()
{
  local file=$1
  local sum
  sum="$(shasum -a 256 $file | awk '{split($0,a); print a[1]}')"
  echo "${sum}"
}

_shasum $1

