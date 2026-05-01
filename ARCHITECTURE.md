# NixOS Flake Architecture: Dendritic Pattern & Modular Frameworks

This document serves as a comprehensive source of truth for architecting a NixOS environment using the **dendritic pattern**, **flake-parts**, and **application wrappers**. It integrates specialized configurations for the **niri** compositor and the **noctalia** shell.

## 1. Core Architectural Principles

### 1.1 The Dendritic Pattern

The dendritic pattern is a structural philosophy where every Nix file in a project is treated as a **flake-parts module**.

- **Modularity:** Instead of complex "glue code" or manual imports, files follow a consistent and predictable structure
- **Recursive Discovery:** The `import-tree` flake is utilized to import the `modules/` directory recursively, eliminating the need for manual relative imports
- **Cross-Referencing:** Every output (packages, modules, systems) is exported to the flake's top level, allowing files to reference each other via self or self' without knowing their relative filesystem paths

### 1.2 Flake-parts Framework

flake-parts provides a modular framework that mirrors the standard Nix flake schema.

- **System Abstraction:** It handles system architectures (e.g., `x86_64-linux`) through the `perSystem` attribute, reducing boilerplate for multi-platform support
- **Type Safety:** It defines standard flake attributes (like packages or `nixosConfigurations`) as options, bringing NixOS-style type checking and error messages to flakes
- **Merging:** It allows automatic merging of options defined across different modules, similar to how `environment.systemPackages` works in NixOS

## 2. System and Host Management

### 2.1 Multi-Host Strategy

A common convention is to maintain a `hosts/` directory where each subdirectory represents a specific machine.

- **Entry Point:** Each machine has a `default.nix` that uses the nixosSystem function to define the host
- **Shared vs. Specific:** Common configurations (e.g., hardware settings or UI features) are defined as separate modules and imported into the host configuration by name via `self.nixosModules`

### 2.2 The "Modules as Outputs" Workflow

By wrapping every configuration file (including `hardware-configuration.nix`) in a flake-parts module, your entire system configuration becomes an exportable output of the flake. This allows users to share specific modules or configurations externally with ease.

## 3. Application Portability & Nix Wrappers

### 3.1 "Homeless" Dotfiles

Wrapping involves bundling a program with its configuration file into a single, portable package. This removes the dependency on Home Manager or a specific `~/.config` directory.

### 3.2 The wrappers Library

The wrappers library by Lassulus provides tools for declarative wrapping.

- `lib.wrapPackage`: A low-level function to add flags, environment variables, and runtime dependencies to an executable
- `lib.wrapModule`: A high-level function that provides a type-safe module system for creating pre-configured applications
- **Key Attributes:**  
  - **Flags:** Attribute set of CLI arguments (e.g., `--theme "dark"`)
  - `wlib.types.file`: A specialized type for programmatically creating configuration files within the wrapper

## 4. Specialized Desktop Environment

### 4.1 Niri Wayland Compositor

Niri is a scrollable tiling compositor that can be configured through a wrapped package for portability.

- **Dynamic KDL Generation:** Using the `neri.wrap` function, Niri settings are translated into the required KDL format at build time
- **Dependency Management:** Utilize `lib.getExe` within the configuration to make the Niri package depend directly on the programs it spawns (e.g., bar, launcher), ensuring they are always available
- **Xwayland:** Niri does not handle Xwayland by itself; `xwayland-satellite` must be configured separately if X11 support is needed

### 4.2 Noctalia Shell

Noctalia is a minimal, "quiet by design" Wayland shell built with Quickshell.

- **GUI-to-Code Workflow:** Users can configure Noctalia via its graphical settings panel and then export the resulting JSON to their Nix configuration using `builtins.fromJSON`
- **Integration:** Noctalia is typically added to Niri's spawn-at-startup settings as a wrapped dependency
- **Features:** Includes dynamic theming, multi-compositor support (Niri, Hyprland, Sway), and a widget system for bars and panels

## 5. Technical Implementation Details

### 5.1 Standard Boilerplate

A dendritic flake-parts module typically follows this structure:

```nix
{ self, inputs, ... }: {  
  perSystem = { config, self', inputs', pkgs, system, ... }: {  
    # System-specific outputs (packages, shells)  
  };  
  flake = {  
    # Top-level outputs (NixOS configurations, modules)  
  };  
}
```

### 5.2 Efficiency & Reproducibility

- **Flake Lock Files:** Pins all inputs to specific commits, ensuring the environment remains reproducible across different machines
- **Pure Evaluation:** Flakes require all files to be staged in Git; unstaged files will be ignored during evaluation
- **Input Inheritance:** To save disk space, a flake can force its inputs to inherit their own dependencies (e.g., nixpkgs) from the primary flake
