{inputs, ...}: {
  flake.modules.nixos.llama = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.secrets."caddy.env" = {
      sopsFile = ./secrets.yaml;
      group = "caddy";
      mode = "440";
    };

    services = {
      llama-swap = {
        enable = true;
        settings = let
          llama-server = lib.getExe' (with pkgs; llama-cpp-vulkan) "llama-server";
        in {
          healthCheckTimeout = 1200;
          macros.llama-server = "${llama-server} --device Vulkan0 --port \${PORT} --jinja";
          models = {
            gpt-oss-20b = {
              cmd = "\${llama-server} -hf ggml-org/gpt-oss-20b-GGUF -ngl 25 -c 131072 --temp 1.0 --top-k 0 --top-p 1.0";
              ttl = 1800;
            };
          };
        };
      };

      caddy = {
        enable = true;
        package = with pkgs; caddy.withPlugins {
          plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
          hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
        };
        environmentFile = "/run/secrets/caddy.env";
        globalConfig = ''
          acme_dns cloudflare {env.CF_API_TOKEN}
        '';
        virtualHosts."llama.seigra.net".extraConfig = ''
          reverse_proxy http://localhost:8080
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    # Configure cache directory for llama.cpp (via llama-swap) to download internet models
    systemd.services.llama-swap = {
      environment.LLAMA_CACHE = "/var/cache/llama-swap";
      serviceConfig.CacheDirectory = "llama-swap";
    };
  };
}
