_: final: prev: {
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
              hash = "sha256-5yjCYHzgCamvEQGbKsxYxsMW4u3OZH1leYkZxhJ0Avc=";
            })
          ];
        cargoPatches = finalAttrs.patches;
        cargoDeps = prevAttrs.cargoDeps.overrideAttrs (prevAttrs: {
          vendorStaging = prevAttrs.vendorStaging.overrideAttrs {
            inherit (finalAttrs) src;
            patches = finalAttrs.cargoPatches;
            outputHash = "sha256-jCUTmM54Yz3NQOHdANs6cQr8GVDVCzpRP/AOk1bE+I4=";
          };
        });
      });
    };
}
