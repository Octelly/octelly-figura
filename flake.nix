{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};
	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem
			(system:
				let
					pkgs = import nixpkgs {
						inherit system;
					};
					yuescript = with pkgs.lua52Packages; buildLuarocksPackage {
						pname = "yuescript";
						version = "0.17.14-1";
						knownRockspec = (pkgs.fetchurl {
							url    = "https://luarocks.org/manifests/pigpigyyy/yuescript-0.17.14-1.rockspec";
							sha256 = "sha256-tUUaUqIc3OCqym2+CdtEEbMWJx0IqtDvzl5rpXRYp34=";
						}).outPath;
						src = pkgs.fetchzip {
							url    = "https://github.com/pigpigyyy/Yuescript/archive/refs/tags/v0.17.14.zip";
							sha256 = "sha256-q2JOFJuJQaHAqtShgozoEg6EpMhhFReYJ7YBacFfgKU=";
						};
						propagatedBuildInputs = [lua];
					};
				in
				with pkgs;
				{
					devShells.default = mkShell {
						packages = [
							python3Minimal
							yuescript
						];
					};
				}
			);

}
