# Security Policy

## Scope

This is a personal NixOS system configuration repository. It contains no application source code, no user data, and no API keys or credentials.

## Secret Management

All secrets (SSH keys, tokens, passwords) are managed outside this repository via system-level mechanisms and are never committed here. If you discover a secret accidentally committed to this repo, please report it immediately.

## Reporting

To report a sensitive finding, contact: erik@cyberworkforce.com

## Dependency Scanning

This repo uses Nix flakes with pinned inputs (`flake.lock`). To check for outdated inputs: `nix flake update --dry-run`.
