((import <nixpkgs> {}).haskellPackages.override {
  overrides = self: super: {
        my-pkg = let
          buildDepends = with self; [
            protolude
            megaparsec
            tasty-th
            HUnit
            tasty-hunit
            tasty-quickcheck
            ansi-wl-pprint
            neat-interpolation
            either
          ];
          in super.mkDerivation {
            pname = "pkg-env";
            src = "/dev/null";
            version = "none";
            license = "none";
            inherit buildDepends;
            buildTools = with self; [
              ghcid
              cabal-install
              hpack
              (hoogleLocal {
                packages = buildDepends;
              })
            ];
          };
      };
}).my-pkg.env
