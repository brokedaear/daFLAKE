{
  description = "BROKE DA EAR's environment tools and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        funTools = with pkgs; [
          figlet # ASCII text generator
        ];

        buildTools = with pkgs; [
          upx # Binary shrinker
        ];

        qlTools = with pkgs; [
          tokei # CLOC counter
          reuse # License lint
          nixfmt-rfc-style # nix formatter
        ];
      in
      {
        lib = rec {
          ciPackages = qlTools ++ buildTools ++ funTools;

          devPackages =
            with pkgs;
            [
              git # VCS
              lazygit # TUI Git interface
              mprocs # Process runner
              zellij # Terminal multiplexer
              neovim # Better vim
              helix # Quick text editor
              go-task # Run tasks
              just # Makefile alternative
              jq # JSON manipulation
              yq # YAML manipulation
              ripgrep # Better grep
              openapi-generator-cli # Generate OpenAPI spec
              vegeta # HTTP Load Testing Tool
            ]
            ++ ciPackages;

          # Function that creates script from file path
          mkScript =
            { name, scriptPath }:
            (pkgs.writeScriptBin name (builtins.readFile scriptPath)).overrideAttrs (old: {
              buildCommand = "${old.buildCommand}\n patchShebangs $out";
            });

          # function that creates script from provided content
          mkScriptFromContent =
            { name, content }:
            (pkgs.writeScriptBin name content).overrideAttrs (old: {
              buildCommand = "${old.buildCommand}\n patchShebangs $out";
            });

          envVars = {
            # Default variables for the REUSE License compliance
            REUSE_COPYRIGHT = "BROKE DA EAR LLC <https://brokedaear.com>";
            REUSE_LICENSE = "Apache-2.0";
          };
        };
      }
    );
}
