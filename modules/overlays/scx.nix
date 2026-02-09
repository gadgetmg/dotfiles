{
  flake.overlays.scx = final: prev: {
    scx =
      prev.scx
      // {
        rustscheds = prev.scx.rustscheds.overrideAttrs (finalAttrs: prevAttrs: {
          patches =
            (prevAttrs.patches or [])
            ++ [
              # Adds scx_cake scheduler
              (final.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/sched-ext/scx/pull/3202.diff";
                hash = "sha256-COClnvd+diDB8Oin3kfBJGd/TKYLglNEchgCj1Tivdc=";
              })
            ];
          cargoPatches = finalAttrs.patches;
          cargoDeps = prevAttrs.cargoDeps.overrideAttrs (prevAttrs: {
            vendorStaging = prevAttrs.vendorStaging.overrideAttrs {
              inherit (finalAttrs) src;
              patches = finalAttrs.cargoPatches;
              outputHash = "sha256-OAYpelpGxU5EyCb4QG0f8EPXcP+EblhFmDXw0I3BxTQ=";
            };
          });
        });
        loader = prev.scx.loader.overrideAttrs (finalAttrs: prevAttrs: {
          patches = [
            # Adds support for scx_cake scheduler
            (final.fetchpatch {
              url = "https://github.com/sched-ext/scx-loader/commit/28b682ab5dfa5750fec89023c5abe6a9433709a7.diff";
              hash = "sha256-e7hZIkoBlRheP1lIojepNfZegC1IASbIbvc5vHi7Ltg=";
            })
          ];
        });
      };
  };
}
