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

    environment.systemPackages = with pkgs; [llama-cpp-vulkan];

    services = {
      llama-swap = {
        enable = true;
        settings = let
          llama-server = lib.getExe' (with pkgs; llama-cpp-vulkan) "llama-server";
        in {
          healthCheckTimeout = 1200;
          macros.llama-server = "${llama-server} --device Vulkan0 --port \${PORT} --jinja";
          models = {
            gemma-4-26b-a4b-it = {
              cmd = "\${llama-server} -hf bartowski/google_gemma-4-26B-A4B-it-GGUF:IQ3_XS -ngl 31 -ctk q4_1 -ctv q4_1";
              ttl = 1800;
            };
            gemma-4-e4b-it = {
              cmd = "\${llama-server} -hf bartowski/google_gemma-4-E4B-it-GGUF:Q6_K -ngl 43";
              ttl = 1800;
            };
            gemma-4-e2b-it = {
              cmd = "\${llama-server} -hf bartowski/google_gemma-4-E2B-it-GGUF:Q6_K -ngl 36";
              ttl = 1800;
            };
          };
        };
      };

      caddy = {
        enable = true;
        package = with pkgs;
          caddy.withPlugins {
            plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
            hash = "sha256-vNSHU7txQLs0m0UChuszURXjEoMj4r1902+1ei0/DaI=";
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
