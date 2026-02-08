{
  flake.nixosModules.docker-idle-inhibitor = {
    lib,
    config,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.services.docker-idle-inhibitor;
      program = pkgs.writeShellScriptBin "docker-idle-inhibitor" ''
        #!/usr/bin/env bash
        set -euo pipefail

        LABEL="${cfg.label}"
        POLL_INTERVAL=${toString cfg.pollInterval}

        # Use docker CLI to list running containers with label
        has_label() {
          # Returns success (0) when at least one container matches
          ${getExe pkgs.docker} ps --filter "label=$LABEL" --format '{{.ID}}' | grep -q . || return 1
        }

        inhibit_pid=0
        inhibit_fds=()

        start_inhibit() {
          # Start systemd-inhibit in background to block sleep while label present.
          # Using "sleep" covers suspend/hibernate.
          # Run a sleep loop under the inhibitor so it's kept alive while label present.
          if [ "$inhibit_pid" -ne 0 ] 2>/dev/null; then
            return
          fi
          systemd-inhibit --what=sleep --why="Docker container with $LABEL running" sleep infinity &
          inhibit_pid=$!
        }

        stop_inhibit() {
          if [ "$inhibit_pid" -ne 0 ] 2>/dev/null; then
            kill "$inhibit_pid" >/dev/null 2>&1 || true
            wait "$inhibit_pid" 2>/dev/null || true
            inhibit_pid=0
          fi
        }

        main() {
          while true; do
            if has_label; then
              start_inhibit || true
            else
              stop_inhibit || true
            fi
            sleep "$POLL_INTERVAL"
          done
        }

        main
      '';
    in {
      options.services.docker-idle-inhibitor = {
        enable = mkEnableOption "monitor docker labels and inhibit sleep";
        label = mkOption {
          type = types.str;
          default = "inhibit-sleep=true";
          description = "Label to match (format key=value). Containers with this label will prevent sleep.";
        };
        pollInterval = mkOption {
          type = types.int;
          default = 10;
          description = "Seconds between checks.";
        };
      };

      config = mkIf cfg.enable {
        systemd.services.docker-idle-inhibitor = {
          description = "Monitor Docker containers for label and inhibit sleep";
          after = ["docker.service"];
          requires = ["docker.service"];
          wants = ["docker.service"];
          serviceConfig = {
            Type = "simple";
            Restart = "always";
            RestartSec = "5s";
            ExecStart = "${program}/bin/docker-idle-inhibitor";
          };
          wantedBy = ["multi-user.target"];
        };
      };
    };
}
