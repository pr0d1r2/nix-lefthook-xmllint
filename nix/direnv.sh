# shellcheck shell=bash
watch_file flake.nix
watch_file flake.lock
watch_file dev.sh
watch_file lefthook-xmllint.sh
watch_file nix/lefthook-nix-no-embedded-shell.sh
use flake
