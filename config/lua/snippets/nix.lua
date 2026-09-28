local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

--ls.add_snippets("nix", {
return{

	--------------------------------------------------------------------
	-- shells
	--------------------------------------------------------------------

	s("shell", fmt(
		[[
		{{ pkgs ? import <nixpkgs> {{}} }}:
		pkgs.mkShell {{

			name = "{}";

			packages = with pkgs; [
				{}
			];

			{}
		}}
		]],
		{
			i(1), i(2), i(0),
		}
	)),

	s("shelllib", fmt(
		[[

		env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
			{}
		];
		]],
		{
			i(0,"pkgs.libz pkgs.stdenv.cc.cc.lib")
		}
	)),

	s("pypkgs", fmt(
		[[

		(python3.withPackages(pypkgs: with pypkgs; [
			{}
		]))
		{}
		]],
		{
			i(1),i(0)
		}
	)),

	s("hook", fmt(
		[[

		shellHook = ''
			{}
		'';
		]],
		{
			i(0)
		}
	)),

	--------------------------------------------------------------------
	-- flakes
	--------------------------------------------------------------------

	s("flake", fmt(
		[[
		{{
			description = "{}";

			inputs = {{
				nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
			}};

			outputs = {{ self, nixpkgs, ... }}@inputs:
				let
					systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
					forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
						f nixpkgs.legacyPackages.${{system}});
				in
				{{
					{}
				}};
		}}
		]],
		{
			i(1), i(0),
		}
	)),

	s("flakeshell", fmt(
		[[
		{{
			description = "{}";

			inputs = {{
				nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
				flake-utils.url = "github:numtide/flake-utils";
			}};

			outputs = {{ self, nixpkgs, flake-utils }}:
				flake-utils.lib.eachDefaultSystem (system:
					let
						pkgs = nixpkgs.legacyPackages.${{system}};
					in
					{{
						devShells.default = pkgs.mkShell {{
							packages = with pkgs; [
								{}
							];

							{}
						}};
					}}
				);
		}}
		]],
		{
			i(1), i(2), i(0),
		}
	)),

	s("flakepkg", fmt(
		[[
		{{
			description = "{}";

			inputs = {{
				nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
			}};

			outputs = {{ self, nixpkgs }}:
				let
					systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
					forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
						f nixpkgs.legacyPackages.${{system}});
				in
				{{
					packages = forAllSystems (pkgs: {{
						default = pkgs.callPackage ./default.nix {{ }};
					}});

					devShells = forAllSystems (pkgs: {{
						default = pkgs.mkShell {{
							inputsFrom = [ self.packages.${{pkgs.system}}.default ];
							packages = with pkgs; [
								{}
							];
						}};
					}});

					formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
				}};
		}}
		]],
		{
			i(1), i(0),
		}
	)),

	s("input", fmt(
		[[
		{}.url = "github:{}";
		{}.inputs.nixpkgs.follows = "nixpkgs";
		]],
		{
			i(1), i(2), rep(1),
		}
	)),

	s("nixossystem", fmt(
		[[
		nixosConfigurations.{} = nixpkgs.lib.nixosSystem {{
			system = "{}";
			specialArgs = {{ inherit inputs; }};
			modules = [
				./hosts/{}/configuration.nix
				{}
			];
		}};
		]],
		{
			i(1), i(2,"x86_64-linux"), rep(1), i(0),
		}
	)),

	--------------------------------------------------------------------
	-- packages
	--------------------------------------------------------------------

	s("drv", fmt(
		[[
		{{ lib, stdenv, fetchFromGitHub }}:

		stdenv.mkDerivation (finalAttrs: {{
			pname = "{}";
			version = "{}";

			src = fetchFromGitHub {{
				owner = "{}";
				repo = "{}";
				rev = "v${{finalAttrs.version}}";
				hash = {};
			}};

			nativeBuildInputs = [ {} ];
			buildInputs = [ {} ];

			{}

			meta = {{
				description = "{}";
				homepage = "https://github.com/{}/{}";
				license = lib.licenses.{};
				maintainers = with lib.maintainers; [ ];
				platforms = lib.platforms.unix;
			}};
		}})
		]],
		{
			i(1), i(2), i(3), i(4), i(5,"lib.fakeHash"),
			i(6), i(7), i(8), i(9), rep(3), rep(4), i(0,"mit"),
		}
	)),

	s("pyapp", fmt(
		[[
		{{ lib, python3Packages, fetchPypi }}:

		python3Packages.buildPythonApplication rec {{
			pname = "{}";
			version = "{}";
			pyproject = true;

			src = fetchPypi {{
				inherit pname version;
				hash = {};
			}};

			build-system = with python3Packages; [ {} ];
			dependencies = with python3Packages; [ {} ];

			pythonImportsCheck = [ "{}" ];

			meta = {{
				description = "{}";
				license = lib.licenses.{};
			}};
		}}
		]],
		{
			i(1), i(2), i(3,"lib.fakeHash"), i(4,"setuptools"), i(5),
			rep(1), i(6), i(0,"mit"),
		}
	)),

	s("rustpkg", fmt(
		[[
		{{ lib, rustPlatform, fetchFromGitHub }}:

		rustPlatform.buildRustPackage rec {{
			pname = "{}";
			version = "{}";

			src = fetchFromGitHub {{
				owner = "{}";
				repo = pname;
				rev = "v${{version}}";
				hash = {};
			}};

			cargoHash = {};

			meta = {{
				description = "{}";
				license = lib.licenses.{};
				mainProgram = "{}";
			}};
		}}
		]],
		{
			i(1), i(2), i(3), i(4,"lib.fakeHash"), i(5,"lib.fakeHash"),
			i(6), i(7,"mit"), rep(1),
		}
	)),

	s("gopkg", fmt(
		[[
		{{ lib, buildGoModule, fetchFromGitHub }}:

		buildGoModule rec {{
			pname = "{}";
			version = "{}";

			src = fetchFromGitHub {{
				owner = "{}";
				repo = pname;
				rev = "v${{version}}";
				hash = {};
			}};

			vendorHash = {};

			ldflags = [ "-s" "-w" ];

			meta = {{
				description = "{}";
				license = lib.licenses.{};
				mainProgram = "{}";
			}};
		}}
		]],
		{
			i(1), i(2), i(3), i(4,"lib.fakeHash"), i(5,"lib.fakeHash"),
			i(6), i(7,"mit"), rep(1),
		}
	)),

	s("meta", fmt(
		[[
		meta = {{
			description = "{}";
			homepage = "{}";
			license = lib.licenses.{};
			maintainers = with lib.maintainers; [ {} ];
			mainProgram = "{}";
			platforms = lib.platforms.{};
		}};
		]],
		{
			i(1), i(2), i(3,"mit"), i(4), i(5), i(0,"unix"),
		}
	)),

	s("override", fmt(
		[[
		{}.overrideAttrs (finalAttrs: previousAttrs: {{
			{}
		}})
		]],
		{
			i(1), i(0),
		}
	)),

	s("overlay", fmt(
		[[
		final: prev: {{
			{} = prev.{}.overrideAttrs (old: {{
				{}
			}});
		}}
		]],
		{
			i(1), rep(1), i(0),
		}
	)),

	--------------------------------------------------------------------
	-- fetchers / trivial builders
	--------------------------------------------------------------------

	s("fetchgh", fmt(
		[[
		fetchFromGitHub {{
			owner = "{}";
			repo = "{}";
			rev = "{}";
			hash = {};
		}}
		]],
		{
			i(1), i(2), i(3), i(0,"lib.fakeHash"),
		}
	)),

	s("fetchurl", fmt(
		[[
		fetchurl {{
			url = "{}";
			hash = {};
		}}
		]],
		{
			i(1), i(0,"lib.fakeHash"),
		}
	)),

	s("wsa", fmt(
		[[
		(pkgs.writeShellApplication {{
			name = "{}";
			runtimeInputs = with pkgs; [ {} ];
			text = ''
				{}
			'';
		}})
		]],
		{
			i(1), i(2), i(0),
		}
	)),

	s("runcmd", fmt(
		[[
		pkgs.runCommand "{}" {{ }} ''
			{}
		''
		]],
		{
			i(1), i(0),
		}
	)),

	--------------------------------------------------------------------
	-- modules
	--------------------------------------------------------------------

	s("module", fmt(
		[[
		{{ config, lib, pkgs, ... }}:

		let
			cfg = config.{};
		in
		{{
			options.{} = {{
				enable = lib.mkEnableOption "{}";

				{}
			}};

			config = lib.mkIf cfg.enable {{
				{}
			}};
		}}
		]],
		{
			i(1,"services.foo"), rep(1), i(2), i(3), i(0),
		}
	)),

	s("opt", fmt(
		[[
		{} = lib.mkOption {{
			type = lib.types.{};
			default = {};
			example = {};
			description = "{}";
		}};
		]],
		{
			i(1), i(2,"str"), i(3,"null"), i(4), i(0),
		}
	)),

	s("enable", fmt(
		[[{} = lib.mkEnableOption "{}";]],
		{
			i(1), i(0),
		}
	)),

	s("mkif", fmt(
		[[
		lib.mkIf {} {{
			{}
		}}
		]],
		{
			i(1), i(0),
		}
	)),

	s("service", fmt(
		[[
		systemd.services.{} = {{
			description = "{}";
			wantedBy = [ "multi-user.target" ];
			after = [ "network.target" ];

			serviceConfig = {{
				Type = "simple";
				ExecStart = "${{pkgs.{}}}/bin/{}";
				Restart = "on-failure";
			}};

			{}
		}};
		]],
		{
			i(1), i(2), i(3), rep(1), i(0),
		}
	)),

	--------------------------------------------------------------------
	-- language bits
	--------------------------------------------------------------------

	s("let", fmt(
		[[
		let
			{} = {};
		in
		{}
		]],
		{
			i(1), i(2), i(0),
		}
	)),

	s("func", fmt(
		[[
		{{ {}, ... }}:
		{}
		]],
		{
			i(1,"pkgs"), i(0),
		}
	)),

	s("if", fmt(
		[[if {} then {} else {}]],
		{
			i(1), i(2), i(0),
		}
	)),

	s("inh", fmt(
		[[inherit ({}) {};]],
		{
			i(1), i(0),
		}
	)),

	s("interp", fmt(
		[[${{{}}}]],
		{
			i(0),
		}
	)),

	s("optionals", fmt(
		[[
		lib.optionals {} [
			{}
		]
		]],
		{
			i(1), i(0),
		}
	)),

}
--})
