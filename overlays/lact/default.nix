{ channels, inputs, ... }:

final: prev: with final; {
  lact = prev.lact.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.7.2";
      src = fetchFromGitHub {
        owner = "ilya-zlobintsev";
        repo = "LACT";
        rev = "v${finalAttrs.version}";
        hash = "sha256-6nNt/EnJKHdldjpCW2pLPBkU5TLGEaqtnUUBraeRa3I=";
      };
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname src version;
        hash = "sha256-NoWngD0LJ+cteoQIJ0iye0MZgmLuuxN2YHHyMqeEABc=";
      };
      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
        rustPlatform.bindgenHook
      ];
      postPatch =
        prevAttrs.postPatch
        + ''
          substituteInPlace lact-daemon/src/server/vulkan.rs \
            --replace-fail 'Command::new("vulkaninfo")' 'Command::new("${vulkan-tools}/bin/vulkaninfo")'

          substituteInPlace $cargoDepsCopy/pciid-parser-*/src/lib.rs \
            --replace-fail '@hwdata@' "${hwdata}"
        '';
      checkInputs = [ fuse3 ];
      checkFlags = prevAttrs.checkFlags ++ [
        "--skip=tests::snapshot_everything"
      ];
      postFixup =
        prevAttrs.postFixup
        + ''
          patchelf $out/bin/.lact-wrapped --add-needed libdrm.so.2 --add-rpath ${lib.makeLibraryPath [ libdrm ]}
        '';
    }
  );
}
