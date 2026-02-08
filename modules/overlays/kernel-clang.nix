{
  flake.overlays.kernel-clang = final: prev: {
    cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3 = prev.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3.extend (_: prevKernelPackages: {
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
    });
  };
}
