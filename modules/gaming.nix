{inputs, ...}: {
  flake = {
    modules.nixos.gaming = {
      pkgs,
      config,
      ...
    }: let
      # Patched AMDGPU to allow high priority queues for SteamVR
      # Ref: https://wiki.nixos.org/wiki/VR#Patching_AMDGPU_to_allow_high_priority_queues
      amdgpu = config.boot.kernelPackages.callPackage (
        {
          stdenv,
          lib,
          kernel,
          kernelModuleMakeFlags,
        }: let
          KDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
        in
          stdenv.mkDerivation {
            pname = "amdgpu";
            inherit (kernel) src version postPatch nativeBuildInputs;

            kernel_dev = kernel.dev;
            kernelVersion = kernel.modDirVersion;

            modulePath = "drivers/gpu/drm/amd/amdgpu";

            patches = [
              (pkgs.fetchpatch {
                name = "cap_sys_nice_begone.patch";
                url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
                hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
              })
            ];

            makeFlags =
              kernelModuleMakeFlags
              ++ [
                "KVER=${kernel.modDirVersion}"
                "KDIR=${KDIR}"
                "INSTALL_MOD_PATH=${placeholder "out"}"
                "INSTALL_MOD_DIR=updates"
              ];

            buildPhase = ''
              BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

              cp $BUILT_KERNEL/Module.symvers .
              cp $BUILT_KERNEL/.config        .
              cp $kernel_dev/vmlinux          .

              make "-j$NIX_BUILD_CORES" modules_prepare
              make "-j$NIX_BUILD_CORES" M=$modulePath modules
            '';

            installTargets = ["modules_install"];

            installFlags = [
              "-C"
              "${KDIR}"
              "M=$(PWD)"
            ];

            meta = {
              description = "AMD GPU kernel module";
              license = lib.licenses.gpl3;
            };
          }
      ) {inherit (config.boot.kernelPackages) kernel;};
    in {
      imports = [
        inputs.nix-gaming.nixosModules.pipewireLowLatency
        inputs.nix-gaming.nixosModules.platformOptimizations
      ];

      boot = {
        kernelParams = ["mitigations=off"];
        extraModulePackages = [amdgpu];
        extraModprobeConfig = ''
          options cfg80211 ieee80211_regdom=US
        '';
      };

      services = {
        envfs.enable = true;
        pipewire.lowLatency = {
          enable = true;
          quantum = 80;
        };
      };

      security.rtkit.enable = true;

      programs = {
        steam = {
          enable = true;
          extest.enable = true;
          platformOptimizations.enable = true;
          protontricks.enable = true;
          remotePlay.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          extraPackages = with pkgs; [gamescope];
          extraCompatPackages = with pkgs; [
            proton-cachyos-x86_64-v3
          ];
          gamescopeSession = {
            enable = true;
            args = ["--adaptive-sync"];
          };
        };
        gamescope.enable = true;
        gamemode.enable = true;
      };

      environment.systemPackages = with pkgs; [
        heroic
        mangohud
        protonup-qt
        moonlight
      ];

      users.users."matt".extraGroups = ["gamemode"];
    };
  };
}
