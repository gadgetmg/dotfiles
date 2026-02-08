{
  perSystem = {pkgs, ...}: {
    packages.scx-loader = pkgs.callPackage (
      {
        rustPlatform,
        fetchFromGitHub,
        fetchpatch,
        scx,
      }:
        rustPlatform.buildRustPackage (finalAttrs: {
          pname = "scx_loader";
          version = "1.0.19";

          src = fetchFromGitHub {
            owner = "sched-ext";
            repo = "scx-loader";
            tag = "v${finalAttrs.version}";
            hash = "sha256-lF3kRDPGI5x3GlGlVzSA/U9SI0/KjUry/eXZpM12bIg=";
          };

          patches = [
            # Adds support for scx_cake scheduler
            (fetchpatch {
              url = "https://github.com/sched-ext/scx-loader/commit/28b682ab5dfa5750fec89023c5abe6a9433709a7.diff";
              hash = "sha256-e7hZIkoBlRheP1lIojepNfZegC1IASbIbvc5vHi7Ltg=";
            })
          ];

          postInstall = ''
            install -Dm444 configs/org.scx.Loader.policy $out/share/polkit-1/actions/org.scx.Loader.policy
          '';

          cargoHash = "sha256-JD/oAFA/2kBvWTKq6yYOX8dl/hixkJyo9BqhBUu9sM0=";

          meta =
            scx.rustscheds.meta
            // {
              description = "`scx_loader` system daemon and DBus-based loader for sched-ext schedulers";
              longDescription = ''
                This includes the `scx_loader` and `scxctl`, the command-line client for
                interacting with the loader.

                ::: {.note}
                Sched-ext schedulers are only available on kernels version 6.12 or later.
                It is recommended to use the latest kernel for the best compatibility.
                :::
              '';
              homepage = "https://github.com/sched-ext/scx-loader";
            };
        })
    ) {};
  };
}
