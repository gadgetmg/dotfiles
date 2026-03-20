{
  flake.modules.nixos.atlantic = {
    pkgs,
    config,
    ...
  }: let
    atlantic = pkgs.callPackage (
      {
        stdenv,
        fetchzip,
        kernel,
      }:
        stdenv.mkDerivation {
          pname = "atlantic";
          version = "2.5.16";
          src = fetchzip {
            url = "https://www.marvell.com/content/dam/marvell/en/drivers/Marvell_Linux_2.5.16_02-10-26.zip";
            hash = "sha256-vpPQRBR3LznTMS/LfmNJ9kJvVA8MXYwZ77rCb3XFA8M=";
            # Necessary to satisfy Akamai WAF
            curlOptsList = [
              "-A"
              "Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0"
              "-H"
              "Accept-Encoding: *"
            ];
            postFetch = ''
              tar -xf $out/atlantic.tar.gz -C $out --strip-components=1
              rm $out/atlantic.tar.gz
            '';
          };

          postPatch = ''
            substituteInPlace Makefile \
              --replace '$(shell uname -r)' '${kernel.modDirVersion}'
            substituteInPlace Makefile \
              --replace '/lib' $out/lib
            sed -i '/depmod/d' Makefile
            sed -i '/updateramfs$/d' Makefile
          '';

          nativeBuildInputs = kernel.moduleBuildDependencies;

          makeFlags =
            kernel.commonMakeFlags
            ++ [
              "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
            ];
        }
    ) {inherit (config.boot.kernelPackages) kernel;};
  in {
    boot.extraModulePackages = [atlantic];
  };
}
