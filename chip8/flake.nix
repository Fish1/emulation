{
	description = "chip8";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, utils }:
	utils.lib.eachDefaultSystem(system:
		let
			pkgs = nixpkgs.legacyPackages.${system};
		in {
			devShells.default = pkgs.mkShell {
				buildInputs = [
					pkgs.pkg-config
					pkgs.zig
					pkgs.sdl3

					pkgs.alsa-lib
					pkgs.libjack2
					pkgs.pipewire
					pkgs.libpulseaudio
						# pkgs.xorg.libX11
					pkgs.xorg.libXcursor
					pkgs.xorg.libXext
					pkgs.xorg.libXi
					pkgs.xorg.libXrandr
					pkgs.xorg.libXScrnSaver
					pkgs.xorg.libXxf86vm
					pkgs.wayland
					pkgs.wayland-protocols
					pkgs.libxkbcommon
					pkgs.libGL
				];

				LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
						# pkgs.sdl3

						# pkgs.alsa-lib
						# pkgs.libjack2
						# pkgs.pipewire
						# pkgs.libpulseaudio
						pkgs.xorg.libX11
						pkgs.xorg.libXcursor
						pkgs.xorg.libXext
						pkgs.xorg.libXi
						pkgs.xorg.libXrandr
						pkgs.xorg.libXScrnSaver
						pkgs.xorg.libXxf86vm
						pkgs.wayland
						pkgs.wayland-protocols
						pkgs.libxkbcommon
						pkgs.libGL
				];
			};
		}
	);
}
