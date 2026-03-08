{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = {self, nixpkgs}:
	let
		system = "x86_64-linux";
		pkgs = import nixpkgs { inherit system; };
	in {
			# devShells.${system} = {
			# default = pkgs.mkShell {
			#	buildInputs = [
			#		pkgs.sdl3
						# self.packages.${system}.chip8
			#	];
			#};
			#};

		packages.${system} = {

			chip8 = pkgs.stdenv.mkDerivation (finalAttrs: {
				name = "chip8";
				pname = "chip8";
				version = "0.0.1";
				src = ./chip8;

				nativeBuildInputs = [
					pkgs.makeWrapper
					pkgs.pkg-config
					pkgs.zig.hook
						# pkgs.zig
				];

				buildInputs = [
					pkgs.sdl3
				];

					# buildPhase = ''
					# zig build --system ${finalAttrs.deps}
					# '';

					# installPhase = ''
					# mv ./zig-out/bin/chip8 $out
					# '';

				zigBuildFlags = [
					"--system"
					"${finalAttrs.deps}"
				];

				deps = pkgs.callPackage ./chip8/deps.nix {};
				# strictDeps = true;
			});
		};
	};
}
