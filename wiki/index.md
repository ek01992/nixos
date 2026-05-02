# Wiki Index

Content catalog. Read this first to find relevant pages before drilling in.  
Last updated: 2026-05-01 (scaffolding concept added)

---

## Overview

| Page | Summary |
|---|---|
| [[overview]] | Full system synthesis: hosts, inputs, module graph, common commands |
| [[wiki-schema]] | Operational rules for ingest, query, and lint workflows |

---

## Hosts

| Page | Summary |
|---|---|
| [[hosts/nixos-wsl]] | WSL2 headless host — no GUI, shared `/mnt/d/wsl/shared`, wheel group only |
| [[hosts/nixxy]] | Bare-metal Intel desktop — niri + noctalia + pipewire + firefox |

---

## Features

| Page | Summary |
|---|---|
| [[features/niri]] | Scrollable tiling Wayland compositor; myNiri package with keybinds, xwayland, noctalia at startup |
| [[features/noctalia]] | Wayland shell (bar, launcher, control center); config via noctalia.json, Catppuccin Lavender theme |

---

## Concepts

| Page | Summary |
|---|---|
| [[concepts/dendritic-pattern]] | Every .nix file is a flake-parts module; no manual imports; cross-ref via self/self' |
| [[concepts/flake-parts]] | Modular flake framework; perSystem abstraction; option-based merging |
| [[concepts/import-tree]] | Auto-discovers modules/ recursively; git add required before nix flake check |
| [[concepts/wrapper-modules]] | BirdeeHub library; bundles app config into derivation; eliminates dotfile dependency |
| [[concepts/scaffolding]] | Three bash scripts + /nixos-scaffold skill for generating host/feature/devshell boilerplate |

---

## Modules

| Page | Summary |
|---|---|
| [[modules/common]] | Baseline imported by all hosts: flakes enabled, core pkgs, git, shell aliases, SSH, locale |

---

## Log

[[log]] — chronological record of all wiki operations (bootstrap, ingest, query, lint)
