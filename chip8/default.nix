{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = {self, nixpkgs}: let
		system = "x86_64-linux";
		pkgs = import nixpkgs { inherit system; };
	in {
		packages.${system}.default =
			pkgs.stdenv.mkDerivation {
				pname = "chip8";
				version = "0.0.1";
				src = ./.;
				buildPhase = ''
					echo 'hello world!' > $out
				'';
			};
	};
}
