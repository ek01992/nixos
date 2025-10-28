HOST := "HOST_NAME_HERE"
FORMATTER := "alejandra"
COMMIT_GREP := "^(feat|fix|docs|style|refactor|perf|test|chore|build|ci)\([a-z]+\): .+"

set shell := ["bash", "-c"]

flake_path := "."

default:
    @just --list

build:
    nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel

switch:
    sudo nixos-rebuild switch --flake .#{{HOST}}

update:
    nix flake update

check:
    nix flake check

fmt:
    nix run nixpkgs#{{FORMATTER}} -- .

clean:
    sudo nix-collect-garbage --delete-old

branch name:
    git checkout -b {{name}}

commit message:
    @echo "{{message}}" | grep -qE '{{COMMIT_GREP}}' || (echo "Invalid format. Use: type(scope): description" && exit 1)
    git commit -m "{{message}}"

push:
    git push

pull:
    git pull

info:
    nix flake show

test:
    nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel --dry-run

audit:
    bash -c scripts/token-audit.sh
