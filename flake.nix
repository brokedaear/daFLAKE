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
          dotacat # rainbow output
        ];

        buildTools = with pkgs; [
          upx # Binary shrinker
          uutils-coreutils-noprefix # coreutils rewritten in Rust
        ];

        qlTools = with pkgs; [
          tokei # CLOC counter
          reuse # License lint
          nixfmt-rfc-style # nix formatter
          nixd # nix language server
        ];
      in
      {
        lib = {
          ciPackages = qlTools ++ buildTools ++ funTools;

          devPackages = with pkgs; [
            fish # shell
            nushell # data oriented shell
            git # VCS
            lazygit # TUI Git interface
            procs # ps replacement
            mprocs # Process runner
            zellij # Terminal multiplexer
            neovim # Better vim
            helix # Quick text editor
            go-task # Run tasks
            just # Makefile alternative
            jq # JSON manipulation
            jc # turn CLI output into JSON
            gron # make JSON greppable
            yq # YAML manipulation
            ripgrep # Better grep
            ripgrep-all # Grep for other types of files, has fzf integration
            fzf # fast file searcher
            sd # simple sed
            openapi-generator-cli # Generate OpenAPI spec
            vegeta # HTTP load testing tool
            xh # HTTP request tool
            hyperfine # benchmarking tool
            ast-grep # AST grepper
            imagemagick # Image tool
          ];

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
