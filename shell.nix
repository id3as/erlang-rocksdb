let
  pinnedNixHash = "57610d2f8f0937f39dbd72251e9614b1561942d8";

  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "${pinnedNixHash}";
      };

  erlangReleases =
    builtins.fetchGit {
      name = "nixpkgs-nixerl";
      url = "https://github.com/id3as/nixpkgs-nixerl.git";
      rev = "e042d541f3d229e1a4c6830a1228d434c6f919bf";
    };

  nixpkgs =
    import pinnedNix {
      overlays = [
        (import erlangReleases)
      ];
    };

  erlang = nixpkgs.nixerl.erlang-26-2-5;
  patchedErlang =  erlang.erlang.override({
        version = "patched";
        rev = "OTP-patched-26";
        src =  nixpkgs.fetchFromGitHub {
          owner = "robashton";
          repo = "otp";
          rev = "maint-26";
          sha256 = "qJqW73HeXAZ8JsoVnLBCK0av1E6YFi/EzviH3eZuoVY=";
        };
      });

  patchedRebar = erlang.rebar3.override({ erlang = patchedErlang; });

in

with nixpkgs;

mkShell {
  shellHook = ''
    export NIX_ERL_DIR=$(nix-store --query ${patchedErlang})/lib/erlang
  '';
  buildInputs = with pkgs; [

    patchedErlang
    patchedRebar.rebar3
    llvmPackages.libcxxClang
    rocksdb

  ];
}
