#!/bin/sh
echo -ne '\033c\033]0;gout 4.1\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/gout-devtest041123-linux.exe" "$@"
