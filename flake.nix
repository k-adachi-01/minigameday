{
  description = "Development shell for mini GameDay (Nix + sandbox isolation)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              pnpm
              awscli2
              jq
              ripgrep
              git
            ];

            shellHook = ''
              echo "minigameday devShell"
              echo "Install: pnpm install"
              echo "Validate: pnpm agent:check"
              echo "AWS mutations: use \$aws-sandbox-run / \$aws-agent-lease (see docs/deployment.md)"
              echo "Pass scenarios: 01 (stop-task) and 05 (scale-to-zero)"
            '';
          };
        }
      );
    };
}
