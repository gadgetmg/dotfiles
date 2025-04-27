{ channels, inputs, ... }:

final: prev: with final; {
  lact = prev.lact.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.7.3";
      src = fetchFromGitHub {
        owner = "ilya-zlobintsev";
        repo = "LACT";
        rev = "v${finalAttrs.version}";
        hash = "sha256-R8VEAk+CzJCxPzJohsbL/XXH1GMzGI2W92sVJ2evqXs=";
      };
      cargoDeps = rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname src version;
        hash = "sha256-SH7jmXDvGYO9S5ogYEYB8dYCF3iz9GWDYGcZUaKpWDQ=";
      };
      nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
        rustPlatform.bindgenHook
      ];
      postPatch = ''
        substituteInPlace lact-daemon/src/server/system.rs \
          --replace-fail 'Command::new("uname")' 'Command::new("${coreutils}/bin/uname")'

        substituteInPlace res/lactd.service \
          --replace-fail ExecStart={lact,$out/bin/lact}

        substituteInPlace res/io.github.ilya_zlobintsev.LACT.desktop \
          --replace-fail Exec={lact,$out/bin/lact}

        substituteInPlace lact-daemon/src/server/vulkan.rs \
          --replace-fail 'Command::new("vulkaninfo")' 'Command::new("${vulkan-tools}/bin/vulkaninfo")'

        substituteInPlace $cargoDepsCopy/pciid-parser-*/src/lib.rs \
          --replace-fail '@hwdata@' "${hwdata}"
      '';
      postInstall = ''
        install -Dm444 res/lactd.service -t $out/lib/systemd/system
        install -Dm444 res/io.github.ilya_zlobintsev.LACT.desktop -t $out/share/applications
        install -Dm444 res/io.github.ilya_zlobintsev.LACT.png -t $out/share/pixmaps
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
