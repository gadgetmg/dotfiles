# source: github.com/lina-bh/flake.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  toml = pkgs.formats.toml { };
  cfg = config.services.scx;
  description = "DBUS on-demand loader of sched-ext schedulers";
  file_name = "scx_loader.toml";
in
{
  options.services.scx.loader = {
    enable = lib.mkEnableOption "scx_loader, ${description}.";

    config = lib.mkOption {
      type = toml.type;
      description = ''
        Configuration written to /etc/${file_name}.
        See https://github.com/sched-ext/scx/blob/main/rust/scx_loader/configuration.md
      '';
    };
  };

  config = lib.mkIf cfg.loader.enable {
    assertions = [
      {
        assertion = !(cfg.enable && cfg.loader.enable);
        message = "services.scx.enable and .loader.enable conflict. Choose one or the other.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    environment.etc.${file_name}.source = toml.generate file_name cfg.loader.config;

    systemd.services.scx_loader = {
      inherit description;

      path = [ cfg.package ];

      unitConfig.ConditionPathIsDirectory = "/sys/kernel/sched_ext";

      serviceConfig = {
        Type = "dbus";
        BusName = "org.scx.Loader";
        ExecStart = "${lib.getExe' cfg.package "scx_loader"}";
        KillSignal = "SIGINT";
      };

      restartTriggers = [ config.environment.etc.${file_name}.source ];
      wantedBy = [ "graphical.target" ];
    };

    services.dbus.packages = [
      (pkgs.stdenvNoCC.mkDerivation {
        inherit (cfg.package) version;
        pname = "scx_loader_dbus";
        dontUnpack = true;
        installPhase = ''
          install -D -m 0644 \
                  ${cfg.package.src}/rust/scx_loader/org.scx.Loader.conf \
                  $out/share/dbus-1/system.d/org.scx.Loader.conf
        '';
      })
    ];
  };
}
