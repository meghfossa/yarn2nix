{ pkgs }:

let
  inherit (pkgs) lib;

  licensesJson = pkgs.writeText "licenses.json"
    (builtins.toJSON (lib.filterAttrs (n: v: v ? spdxId) lib.licenses));
in

pkgs.haskellPackages.override {
  overrides =
    (self: super: {
      yarn-lock =
        let
          pkg = self.callPackage ./yarn-lock/yarn-lock.nix {};
        in pkgs.haskell.lib.overrideCabal pkg (old: {
          src = builtins.filterSource
            (path: type:
               if lib.any (p: lib.hasPrefix (toString ./yarn-lock + "/" + p) path) [
                 "package.yaml"
                 "LICENSE"
                 "CHANGELOG.md"
                 "src"
                 "tests"
               ]
               then true
               else false
            ) ./yarn-lock;
        });


      yarn2nix =
        let
          pkg = pkgs.haskell.lib.overrideCabal
            (self.callPackage ./yarn2nix/yarn2nix.nix {})
            (old: {
              prePatch = ''
                ${pkgs.hpack}/bin/hpack
                # we depend on the git prefetcher
                substituteInPlace \
                  src/Distribution/Nixpkgs/Nodejs/ResolveLockfile.hs \
                  --replace '"nix-prefetch-git"' \
                    '"${pkgs.nix-prefetch-git.override { git = pkgs.gitMinimal; }}/bin/nix-prefetch-git"'
                sed -i '/license-data/a \ <> O.value "${licensesJson}"' \
                  src/Distribution/Nixpkgs/Nodejs/Cli.hs
              '';
            });
        in pkgs.haskell.lib.overrideCabal pkg (old: {
          src = builtins.filterSource
            (path: type:
               if lib.any (p: lib.hasPrefix (toString ./yarn2nix + "/" + p) path) [
                 "package.yaml"
                 "README.md"
                 "nix-lib"
                 "LICENSE"
                 "src"
                 "NodePackageTool.hs"
                 "Main.hs"
                 "tests"
               ]
               then true
               else false
            ) ./yarn2nix;
        });
    });
 }

