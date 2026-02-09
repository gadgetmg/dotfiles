{
  flake.overlays.kernel-lto-patches = final: prev: {
    cachyosKernels = let
      lto-patches = _: prevKernelPackages: {
        ryzen-smu = with prevKernelPackages;
          ryzen-smu.overrideAttrs (prevAttrs: let
            monitor-cpu = stdenv.mkDerivation {
              pname = "monitor-cpu";
              inherit (prevAttrs) version src;
              makeFlags = ["-C userspace"] ++ kernel.commonMakeFlags;
              installPhase = ''
                runHook preInstall
                install userspace/monitor_cpu -Dm755 -t $out/bin
                runHook postInstall
              '';
            };
          in {
            installPhase = ''
              runHook preInstall
              install ryzen_smu.ko -Dm444 -t $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/ryzen_smu
              install ${monitor-cpu}/bin/monitor_cpu -Dm755 -t $out/bin
              runHook postInstall
            '';
          });
      };
    in
      prev.cachyosKernels
      // {
        linuxPackages-cachyos-latest-lto = prev.cachyosKernels.linuxPackages-cachyos-latest-lto.extend lto-patches;
        linuxPackages-cachyos-latest-lto-x86_64-v2 = prev.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v2.extend lto-patches;
        linuxPackages-cachyos-latest-lto-x86_64-v3 = prev.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3.extend lto-patches;
        linuxPackages-cachyos-latest-lto-x86_64-v4 = prev.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v4.extend lto-patches;
        linuxPackages-cachyos-latest-lto-zen4 = prev.cachyosKernels.linuxPackages-cachyos-latest-lto-zen4 lto-patches;
        linuxPackages-cachyos-lts-lto = prev.cachyosKernels.linuxPackages-cachyos-lts-lto.extend lto-patches;
        linuxPackages-cachyos-bmq-lto = prev.cachyosKernels.linuxPackages-cachyos-bmq-lto.extend lto-patches;
        linuxPackages-cachyos-bore-lto = prev.cachyosKernels.linuxPackages-cachyos-bore-lto.extend lto-patches;
        linuxPackages-cachyos-deckify-lto = prev.cachyosKernels.linuxPackages-cachyos-deckify-lto.extend lto-patches;
        linuxPackages-cachyos-eevdf-lto = prev.cachyosKernels.linuxPackages-cachyos-eevdf-lto.extend lto-patches;
        linuxPackages-cachyos-hardened-lto = prev.cachyosKernels.linuxPackages-cachyos-hardened-lto.extend lto-patches;
        linuxPackages-cachyos-rc-lto = prev.cachyosKernels.linuxPackages-cachyos-rc-lto.extend lto-patches;
        linuxPackages-cachyos-rt-bore-lto = prev.cachyosKernels.linuxPackages-cachyos-rt-bore-lto.extend lto-patches;
        linuxPackages-cachyos-server-lto = prev.cachyosKernels.linuxPackages-cachyos-server-lto.extend lto-patches;
      };
  };
}
