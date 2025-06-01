{
  config,
  lib,
  pkgs,
  ...
}:
let
  yaml = pkgs.formats.yaml { };
  cfg = config.services.llama-swap;
  description = "Model swapping for llama.cpp (or any local OpenAPI compatible server)";
  file_name = "llama-swap/config.yaml";
in
{
  options.services.llama-swap = {
    enable = lib.mkEnableOption "llama-swap, ${description}.";

    package = lib.mkPackageOption pkgs "llama-swap" { };

    llama-cpp.package = lib.mkPackageOption pkgs "llama-cpp" { };

    config = lib.mkOption {
      type = yaml.type;
      description = ''
        Configuration written to /etc/${file_name}.
        See https://github.com/mostlygeek/llama-swap/wiki/Configuration
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "IP address llama-swap server listens on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Listen port for llama-swap.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open ports in the firewall for llama-swap.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."${file_name}".source = yaml.generate file_name cfg.config;

    systemd.services.llama-swap = {
      inherit description;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ cfg.llama-cpp.package ];
      environment.LLAMA_CACHE = "/var/cache/llama-swap";

      serviceConfig = {
        Type = "idle";
        KillSignal = "SIGINT";
        ExecStart = "${cfg.package}/bin/llama-swap -config /etc/${file_name} -listen ${cfg.host}:${builtins.toString cfg.port} -watch-config";
        Restart = "on-failure";
        RestartSec = 300;

        # for GPU acceleration
        PrivateDevices = false;

        # hardening
        DynamicUser = true;
        CacheDirectory = "llama-swap";
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        SystemCallErrorNumber = "EPERM";
        ProtectProc = "invisible";
        ProtectHostname = true;
        ProcSubset = "pid";
      };

      restartTriggers = [ config.environment.etc.${file_name}.source ];
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

  };
}
