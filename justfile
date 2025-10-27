set shell := ["bash", "-c"]

flake_path := "."

default:
    @just --list

build:
    nix build .#nixosConfigurations.xps.config.system.build.toplevel

switch:
    sudo nixos-rebuild switch --flake .#xps

update:
    nix flake update

check:
    nix flake check

fmt:
    nix run nixpkgs#alejandra -- .

clean:
    sudo nix-collect-garbage --delete-old

branch name:
    git checkout -b {{name}}

commit message:
    @echo "{{message}}" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore|build|ci)\([a-z]+\): .+' || (echo "Invalid format. Use: type(scope): description" && exit 1)
    git commit -m "{{message}}"

push:
    git push

pull:
    git pull

install package:
    nix-env -iA nixpkgs.{{package}}

info:
    nix flake show

test:
    nix build .#nixosConfigurations.xps.config.system.build.toplevel --dry-run

audit:
    bash -c scripts/token-audit.sh
