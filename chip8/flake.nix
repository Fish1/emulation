{
	description = "chip8";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		utils.url = "github:numtide/flake-utils";
		zig-overlay = {
			url = "github:mitchellh/zig-overlay";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zls-overlay = {
			url = "github:zigtools/zls";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, utils, zig-overlay, zls-overlay }:
	utils.lib.eachDefaultSystem(system:
		let
			pkgs = nixpkgs.legacyPackages.${system};
			zig = zig-overlay.packages.${system}.master;
			zls = zls-overlay.packages.${system}.zls.overrideAttrs (
				old: {
					nativeBuildInputs = [
						zig
					];
				}
			);
		in {
			devShells.default = pkgs.mkShell {
				buildInputs = [
					pkgs.pkg-config
					pkgs.sdl3
					
					zig
					zls
				];
			};
		}
	);
}
