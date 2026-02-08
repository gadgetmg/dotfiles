# Source: https://github.com/NixOS/nixpkgs/pull/445224
#
# Added option for specifying seperate packages for scx_loader vs schedulers as
# they were split into different repositories.
#
# Added both packages to `environment.systemPackages` for the service to catch
# the new polkit policy for scx_loader.
#
# Added "scx_beerland" and "scx_cake" to the enum for default scheduler options.
#
{inputs, ...}: {
  flake.nixosModules.scx-loader = {
    lib,
    pkgs,
    config,
    ...
  }: let
    utils = import "${inputs.nixpkgs}/nixos/lib/utils.nix" {
      inherit config lib;
      pkgs = null;
    };
    cfg = config.services.scx_loader;
    tomlFormat = pkgs.formats.toml {};
  in {
    options.services.scx_loader = {
      enable = lib.mkEnableOption "Enable scx_loader";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.scx.loader;
        defaultText = lib.literalExpression "pkgs.scx.loader";
        description = ''
          `scx_loader` package to use.
        '';
      };

      scxPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.scx.full;
        defaultText = lib.literalExpression "pkgs.scx.full";
        example = lib.literalExpression "pkgs.scx.rustscheds";
        description = ''
          `scx` package to use. `scx.full`, which includes all schedulers, is the default.
          You may choose a minimal package, such as `pkgs.scx.rustscheds`.

          ::: {.note}
          Overriding this does not change the default scheduler; you should set `services.scx_loader.default_sched` for it.
          :::
        '';
      };

      default_sched = lib.mkOption {
        type = lib.types.enum [
          "scx_beerland"
          "scx_bpfland"
          "scx_cake"
          "scx_cosmos"
          "scx_flash"
          "scx_lavd"
          "scx_p2dq"
          "scx_tickless"
          "scx_rustland"
          "scx_rusty"
        ];
        default = "scx_flash";
        example = "scx_lavd";
        description = ''
          Which scheduler to use. See [SCX documentation](https://github.com/sched-ext/scx/tree/main/scheds)
          for details on each scheduler and guidance on selecting the most suitable one.
        '';
      };

      default_mode = lib.mkOption {
        type = lib.types.enum [
          "Auto"
          "Gaming"
          "LowLatency"
          "PowerSave"
          "Server"
        ];
        default = "Auto";
        example = "Gaming";
        description = ''
          Which mode to use. See [scx_loader documentation](https://github.com/sched-ext/scx/blob/main/tools/scx_loader/configuration.md)
          for details on how to the different modes.
        '';
      };

      scheduler_config = lib.mkOption {
        type = tomlFormat.type;
        default = {};
        example = {
          scheds = {
            scx_rustland = {
              auto_mode = [];
              gaming_mode = [];
              lowlatency_mode = [];
              powersave_mode = [];
              server_mode = [];
            };
            scx_lavd = {
              auto_mode = [];
              gaming_mode = ["--performance"];
              lowlatency_mode = ["--performance"];
              powersave_mode = ["--powersave"];
              server_mode = [];
            };
            scx_flash = {
              auto_mode = [];
              gaming_mode = [
                "-m"
                "all"
              ];
              lowlatency_mode = [
                "-m"
                "performance"
                "-w"
                "-C"
                "0"
              ];
              powersave_mode = [
                "-m"
                "powersave"
                "-I"
                "10000"
                "-t"
                "10000"
                "-s"
                "10000"
                "-S"
                "1000"
              ];
              server_mode = [
                "-m"
                "all"
                "-s"
                "20000"
                "-S"
                "1000"
                "-I"
                "-1"
                "-D"
                "-L"
              ];
            };
          };
        };
        description = ''
          Scheduler configuration. This will be added to the generated TOML config file
          after the default_sched and default_mode settings.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package cfg.scxPackage];
      environment.etc."scx_loader/config.toml".source = tomlFormat.generate "config.toml" (
        cfg.scheduler_config
        // {
          default_sched = cfg.default_sched;
          default_mode = cfg.default_mode;
        }
      );

      systemd.services.scx_loader = {
        path = [cfg.scxPackage];
        description = "DBUS on-demand loader of sched_ext schedulers";

        # SCX service should be started only if the kernel supports sched-ext
        unitConfig.ConditionPathIsDirectory = "/sys/kernel/sched_ext";

        serviceConfig = {
          Type = "dbus";
          BusName = "org.scx.Loader";
          Environment = "RUST_LOG=trace";
          ExecStart = utils.escapeSystemdExecArgs [
            (lib.getExe' cfg.package "scx_loader")
          ];
          KillSignal = "SIGINT";
        };

        wantedBy = ["graphical.target"];
      };

      # D-Bus service configuration
      services.dbus = {
        enable = true;
        packages = [
          (pkgs.writeTextFile {
            name = "scx-loader-dbus-service";
            destination = "/share/dbus-1/system-services/org.scx.Loader.service";
            text = ''
              [D-BUS Service]
              Name=org.scx.Loader
              Exec=${
                utils.escapeSystemdExecArgs [
                  (lib.getExe' cfg.package "scx_loader")
                ]
              }
              User=root
              SystemdService=scx_loader.service
            '';
          })
          (pkgs.writeTextFile {
            name = "scx-loader-dbus-conf";
            destination = "/share/dbus-1/system.d/org.scx.Loader.conf";
            text = ''
              <!DOCTYPE busconfig PUBLIC
               "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
               "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
              <busconfig>
                  <policy user="root">
                      <allow own="org.scx.Loader"/>
                      <allow send_destination="org.scx.Loader"/>
                      <allow receive_sender="org.scx.Loader"/>
                  </policy>
                  <policy context="default">
                      <allow send_destination="org.scx.Loader"/>
                      <allow receive_sender="org.scx.Loader"/>
                  </policy>
              </busconfig>
            '';
          })
        ];
      };

      # Polkit rule for "scx" group to manage schedulers
      users.groups.scx = {};
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.scx.loader.manage-schedulers" &&
                subject.isInGroup("scx")) {
                return polkit.Result.YES;
            }
        });
      '';
      assertions = [
        {
          assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.12";
          message = "SCX is only supported on kernel version >= 6.12.";
        }
        {
          assertion = !(cfg.enable && config.services.scx.enable);
          message = "services.scx_loader and services.scx cannot be enabled simultaneously. Please enable only one.";
        }
      ];
    };

    meta = {
      inherit (pkgs.scx.full.meta) maintainers;
    };
  };
}
