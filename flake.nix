{
  description = "Basic shell for garmin-otp-authenticator";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "garmin-otp-authenticator";
        buildInputs = with pkgs; [
          xorg.xhost
          gnumake
        ];
      };

    };
}
