# Flake outputs for this repository.
#
# flake.nix stays a thin manifest (description/nixConfig/inputs/outputs), which
# the set-and-setting flake-manifest guard requires, so everything that is not a
# literal manifest attribute lives here.
#
# mkConsumerFlake builds the standard packages/devShells/checks/apps. It has no
# hook for putting a repository's OWN package into its dev shell, and this
# repository's specs invoke `lefthook-xmllint`, so the dev shells it returns are
# extended with the package built from this source rather than the copy
# set-and-setting pins.
{
  self,
  nixpkgs,
  set-and-setting,
  ...
}:
let
  # The detector adds `actions` (workflows present) and `bats` (specs present)
  # on its own, but confirm's materialization is rebuilt below and has to see
  # the same list, so every fragment is spelled out here in detector order.
  fragments = [
    "base"
    "actions"
    "nix"
    "shell"
    "ascii"
    "bats"
    "markdown"
    "yaml"
  ];

  confirmMaterialization =
    pkgs:
    let
      materialization = set-and-setting.lib.materializationFor { inherit pkgs fragments; };
    in
    materialization
    // {
      packages = materialization.packages ++ [
        self.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  xmllintPackage =
    pkgs:
    pkgs.writeShellApplication {
      name = "lefthook-xmllint";
      runtimeInputs = [ pkgs.libxml2 ];
      text = builtins.readFile ../lefthook-xmllint.sh;
    };

  batsWithLibraries =
    pkgs:
    pkgs.bats.withLibraries (p: [
      p.bats-assert
      p.bats-file
      p.bats-support
    ]);

  outputs = set-and-setting.lib.mkConsumerFlake {
    inherit
      self
      nixpkgs
      set-and-setting
      fragments
      ;
    src = ../.;
    extraPackages = pkgs: { default = xmllintPackage pkgs; };
    extraChecks = pkgs: {
      unit =
        pkgs.runCommand "unit-tests"
          {
            nativeBuildInputs = [
              (xmllintPackage pkgs)
              (batsWithLibraries pkgs)
              pkgs.git
            ];
          }
          ''
            cp -r ${../.} source
            chmod -R u+w source
            cd source
            bats tests/unit
            touch $out
          '';
    };
  };
in
outputs
// {
  devShells = builtins.mapAttrs (
    system:
    builtins.mapAttrs (
      _name: shell:
      shell.overrideAttrs (previous: {
        buildInputs = (previous.buildInputs or [ ]) ++ [ self.packages.${system}.default ];
        # Specs live under tests/unit here; tdd-order-bats looks under `tests`
        # unless told otherwise, and both the hook and CI read it from the
        # shell.
        LEFTHOOK_TDD_SPEC_DIR = "tests/unit";
      })
    )
  ) outputs.devShells;

  # `lefthook-repo.yml` keeps an xmllint hook that runs THIS repository's
  # wrapper, and confirm's coherence check requires every command named in
  # lefthook.yml to be on confirm's own PATH. mkConsumerFlake builds that app
  # from the materialized fragments alone, so confirm is rebuilt here from a
  # materialization that carries the package too.
  apps = builtins.mapAttrs (
    system: systemApps:
    systemApps
    // {
      confirm = set-and-setting.lib.mkConfirmApp {
        pkgs = nixpkgs.legacyPackages.${system};
        standard = set-and-setting;
        setting = outputs.packages.${system}.setting;
        materialization = confirmMaterialization nixpkgs.legacyPackages.${system};
        confirmRev = set-and-setting.rev or set-and-setting.dirtyRev or "unknown";
      };
    }
  ) outputs.apps;
}
