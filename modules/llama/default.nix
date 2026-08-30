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
      llama-cpp = {
        enable = true;
        package = with pkgs; llama-cpp-vulkan;
        extraFlags = [
          "--device"
          "Vulkan0"
          "--sleep-idle-seconds"
          "1800"
          "--cors-origins"
          "localhost"
        ];
        modelsPreset = let
          mkPreset = repo: overrides:
            {
              hf-repo = repo;
              n-gpu-layers = "all";
              fit-target = "256";
              mmproj-offload = "off";
            }
            // overrides;
          mkPresets = repos: overrides:
            lib.genAttrs repos (repo: mkPreset repo overrides);
        in
          mkPresets [
            "bartowski/Qwen_Qwen3.6-35B-A3B-GGUF:Q6_K"
            "bartowski/google_gemma-4-26B-A4B-it-GGUF:Q6_K"
          ] {
            cpu-moe = "on";
            ctx-size = "262144";
            spec-default = "on";
            spec-type = "draft-mtp";
            spec-draft-type-k = "q8_0";
            spec-draft-type-v = "q8_0";
            spec-draft-n-max = "3";
            spec-draft-p-min = "0.75";
          }
          // mkPresets [
            "bartowski/Qwen3.8-27B-GGUF:IQ2_S" # ~ full context (256k)
            "bartowski/Qwen3.8-27B-GGUF:IQ3_XXS" # ~ 1/2 context (128k)
            "bartowski/google_gemma-4-26B-A4B-it-GGUF:IQ3_M" # ~ full context (256k)
            "bartowski/google_gemma-4-26B-A4B-it-GGUF:IQ4_XS" # ~ 1/2 context (128k)
          ] {
            cache-type-k = "q4_0";
            cache-type-v = "q4_0";
          }
          // mkPresets [
            "bartowski/google_gemma-4-E4B-it-GGUF:Q6_K"
            "bartowski/google_gemma-4-E2B-it-GGUF:Q6_K"
          ] {};
      };

      caddy = {
        enable = true;
        package = with pkgs;
          caddy.withPlugins {
            plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
            hash = "sha256-PWadA5qr/gR2qDcT8l8u1Xku7LM2HIfWTLOkzezCYy0=";
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
  };
}
