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

    environment.systemPackages = with pkgs; [llama-cpp];

    services = {
      llama-cpp = {
        enable = true;
        settings = {
          port = 9931;
          models-max = "1";
          device = "Vulkan0";
          spec-draft-device = "Vulkan0";
          sleep-idle-seconds = "1800";
          cors-origins = "localhost,llama.seigra.net";
          models-preset = let
            mkPreset = repo: overrides:
              {
                hf-repo = repo;
                n-gpu-layers = "all";
                fit-target = "256";
                mmproj-offload = "off";
                reasoning-preserve = "on";
              }
              // overrides;
            mkPresets = repos: overrides:
              lib.genAttrs repos (repo: mkPreset repo overrides);
          in
            pkgs.writeText "llama-models.ini" (lib.generators.toINI {} (
              mkPresets [
                "bartowski/Qwen_Qwen3.6-35B-A3B-GGUF:Q6_K"
                "bartowski/google_gemma-4-26B-A4B-it-GGUF:Q6_K"
              ] {
                cpu-moe = "on";
                ctx-size = "262144";
                spec-type = "draft-mtp";
                spec-draft-n-max = "3";
                spec-draft-p-min = "0.75";
              }
              // mkPresets [
                "ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF:IQ3_XXS"
              ] {
                cpu-moe = "on";
                lazy-mode = "on";
                override-tensor = "per_layer_token_embd=CPU";
                # cache-type-k = "q8_0";
                cache-type-v = "q8_0";
                chat-template-kwargs = ''{"reasoning_effort":"medium"}'';
              }
              // mkPresets [
                "ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_XXS"
              ] {
                cache-type-k = "q4_0";
                cache-type-v = "q4_0";
                chat-template-kwargs = ''{"reasoning_effort":"medium"}'';
              }
              // mkPresets [
                "bartowski/google_gemma-4-E4B-it-GGUF:Q6_K"
                "bartowski/google_gemma-4-E2B-it-GGUF:Q6_K"
              ] {}
            ));
        };
      };

      caddy = {
        enable = true;
        package = with pkgs;
          caddy.withPlugins {
            plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
            hash = "sha256-EXZTsf9KrIAi9gHsBHrYQ7oIQiYmLj6sYuQP5QihPcA=";
          };
        environmentFile = "/run/secrets/caddy.env";
        globalConfig = ''
          acme_dns cloudflare {env.CF_API_TOKEN}
        '';
        virtualHosts."llama.seigra.net".extraConfig = ''
          reverse_proxy http://localhost:9931
        '';
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
