let
  pinnedNixHash = "ec750fd01963ab6b20ee1f0cb488754e8036d89d";

  pinnedNix =
    builtins.fetchGit {
      name = "nixpkgs-pinned";
      url = "https://github.com/NixOS/nixpkgs.git";
      rev = "${pinnedNixHash}";
      };

  nixpkgs =
    import pinnedNix {
      overlays = [
#        (import erlangReleases)
        # (import purerlReleases)
        # (import id3asPackages)
      ];
    };


in

with nixpkgs;

mkShell {
  shellHook = ''
     PATH="${pkgs.clang-tools}/bin:$PATH"
  '';
  buildInputs = with pkgs; [
    clang-tools
    coreutils
    libiconv

    erlang
    rebar3
    erlang-ls
    gdb
    cmake

    curl
    (aws-sdk-cpp.override { apis = ["s3" "kinesis" "transfer"]; })
    rdkafka
    bzip2

  ];
}
