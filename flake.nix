{
  description = "Library for Representing Recursive and Impure Programs in Coq";

  inputs = {
    rocq-nix.url = "github:mbrcknl/rocq-nix";

    rocq-nix-paco.url = "github:mbrcknl/rocq-nix-paco";
    rocq-nix-paco.inputs.rocq-nix.follows = "rocq-nix";

    itrees.url = "github:DeepSpec/InteractionTrees";
    itrees.flake = false;
  };

  outputs =
    inputs:
    inputs.rocq-nix.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        treefmt.programs.nixfmt.enable = true;

        rocq.dev.sources."itrees".input = "itrees";

        rocq.versions.default = "9.1.0";
        rocq.versions.supported = {
          "9.0.1" = true;
          "9.1.0" = true;
        };

        rocq.versions.foreach =
          {
            inputs',
            pkgs,
            rocq,
            ...
          }:
          let
            inherit (rocq.coqPackages) coq ExtLib stdlib;
            inherit (inputs'.rocq-nix-paco.packages) paco;

            itrees = pkgs.stdenv.mkDerivation {
              name = "rocq${coq.coq-version}-itrees";
              src = inputs.itrees;
              buildInputs = [
                coq
                ExtLib
                paco
                stdlib
              ];
              COQLIBINSTALL = "$(out)/lib/coq/${coq.coq-version}/user-contrib";
              enableParallelBuilding = true;
              meta = {
                inherit (coq.meta) platforms;
                homepage = "https://github.com/DeepSpec/InteractionTrees";
                description = "Library for Representing Recursive and Impure Programs in Coq";
                license = lib.licenses.mit;
              };
            };
          in
          {
            packages = { inherit itrees; };
            dev.env.lib = [
              ExtLib
              paco
              stdlib
            ];
          };
      }
    );
}
