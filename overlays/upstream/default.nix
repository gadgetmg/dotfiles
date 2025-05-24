{ channels, inputs, ... }:

final: prev: with final; {
  upstream = lib.makeScope newScope (_: {
    mesa =
      let
        extraRustDeps = [
          {
            pname = "rustc-hash";
            version = "2.1.1";
            hash = "sha256-3rQidUAExJ19STn7RtKNIpZrQUne2VVH7B1IO5UY91k=";
          }
        ];

        copyRustDep = dep: ''
          cp -R --no-preserve=mode,ownership ${fetchCrate dep} subprojects/${dep.pname}-${dep.version}
          cp -R subprojects/packagefiles/${dep.pname}/* subprojects/${dep.pname}-${dep.version}/
        '';

        copyExtraRustDeps = lib.concatStringsSep "\n" (builtins.map copyRustDep extraRustDeps);
      in
      (prev.mesa.override {
        directx-headers =
          # https://gitlab.freedesktop.org/mesa/mesa/-/issues/13126
          final.directx-headers.overrideAttrs (_prevAttrs: {
            src = final.fetchFromGitHub {
              owner = "microsoft";
              repo = "DirectX-Headers";
              rev = "v1.614.1";
              hash = "sha256-CDmzKdV40EExLpOHPAUnytqG9x1+IGW4AZldfYs5YJk=";
            };
          });
      }).overrideAttrs
        (prevAttrs: {
          version = builtins.substring 0 (builtins.stringLength prev.mesa.version) inputs.mesa.rev;
          src = inputs.mesa;
          patches = [
            ./opencl.patch
          ];
          postPatch =
            prevAttrs.postPatch
            + ''
              ${copyExtraRustDeps}
            '';
        });
  });
}
