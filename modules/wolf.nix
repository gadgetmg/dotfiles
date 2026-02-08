{inputs, ...}: {
  flake.modules.nixos.wolf = {config, ...}: {
    imports = [
      inputs.self.nixosModules.wolf
      inputs.self.nixosModules.docker-idle-inhibitor
    ];

    services = {
      docker-idle-inhibitor.enable = true;

      wolf = let
        hosts = {
          carbon.uuid = "00a6a114-f021-4f76-bb7a-7d3e5ce35b5b";
        };
        thisHost = hosts."${config.networking.hostName}";
      in {
        enable = true;
        openFirewall = true;
        config = {
          inherit (thisHost) uuid;
          hostname = config.networking.hostName;
          gstreamer = {
            audio = {
              default_audio_params = "queue max-size-buffers=3 leaky=downstream ! audiorate ! audioconvert";
              default_opus_encoder = "opusenc bitrate={bitrate} bitrate-type=cbr frame-size={packet_duration} bandwidth=fullband audio-type=restricted-lowdelay max-payload-size=1400";
              default_sink = ''
                rtpmoonlightpay_audio name=moonlight_pay packet_duration={packet_duration} encrypt={encrypt} aes_key="{aes_key}" aes_iv="{aes_iv}" !
                appsink name=wolf_udp_sink
              '';
              default_source = "interpipesrc name=interpipesrc_{}_audio listen-to={session_id}_audio is-live=true stream-sync=restart-ts max-bytes=0 max-buffers=3 block=false";
            };
            video = {
              default_sink = ''
                rtpmoonlightpay_video name=moonlight_pay payload_size={payload_size} fec_percentage={fec_percentage} min_required_fec_packets={min_required_fec_packets} !
                appsink sync=false name=wolf_udp_sink
              '';
              default_source = "interpipesrc name=interpipesrc_{}_video listen-to={session_id}_video is-live=true stream-sync=restart-ts max-bytes=0 max-buffers=1 leaky-type=downstream";
              defaults = {
                va = {
                  video_params_zero_copy = ''
                    vapostproc add-borders=true !
                    video/x-raw(memory:VAMemory), width={width}, height={height}, pixel-aspect-ratio=1/1
                  '';
                };
              };
              av1_encoders = [
                {
                  check_elements = ["vaav1enc" "vapostproc"];
                  encoder_pipeline = "vaav1enc ref-frames=1 bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=2";
                  plugin_name = "va";
                }
              ];
              h264_encoders = [
                {
                  check_elements = ["vah264enc" "vapostproc"];
                  encoder_pipeline = "vah264enc ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=2";
                  plugin_name = "va";
                }
              ];
              hevc_encoders = [
                {
                  check_elements = ["vah265enc" "vapostproc"];
                  encoder_pipeline = "vah265enc ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=2";
                  plugin_name = "va";
                }
              ];
            };
          };
          profiles = [
            {
              id = "moonlight-profile-id";
              apps = [
                {
                  title = "Wolf UI";
                  start_virtual_compositor = true;
                  icon_png_path = "https://raw.githubusercontent.com/games-on-whales/wolf-ui/refs/heads/main/src/Icons/wolf_ui_icon.png";
                  runner = {
                    base_create_json = ''
                      {
                        "HostConfig": {
                          "IpcMode": "host",
                          "CapAdd": ["NET_RAW", "MKNOD", "NET_ADMIN", "SYS_ADMIN", "SYS_NICE"],
                          "Privileged": false,
                          "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                        },
                        "Labels": {
                          "inhibit-sleep": "true"
                        }
                      }
                    '';
                    devices = [];
                    env = [
                      "GOW_REQUIRED_DEVICES=/dev/input/event* /dev/dri/* /dev/nvidia*"
                      "WOLF_SOCKET_PATH=/var/run/wolf/wolf.sock"
                      "WOLF_UI_AUTOUPDATE=False"
                      "LOGLEVEL=INFO"
                    ];
                    image = "ghcr.io/games-on-whales/wolf-ui:main";
                    mounts = [
                      "/var/run/wolf/wolf.sock:/var/run/wolf/wolf.sock"
                    ];
                    name = "Wolf-UI";
                    ports = [];
                    type = "docker";
                  };
                }
              ];
            }
            {
              id = "matt";
              name = "Matt";
              apps = [
                {
                  title = "RetroArch";
                  start_virtual_compositor = true;
                  icon_png_path = "https://games-on-whales.github.io/wildlife/apps/retroarch/assets/icon.png";
                  runner = {
                    base_create_json = ''
                      {
                        "HostConfig": {
                          "IpcMode": "host",
                          "CapAdd": ["NET_RAW", "MKNOD", "NET_ADMIN", "SYS_ADMIN", "SYS_NICE"],
                          "Privileged": false,
                          "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                        }
                      }
                    '';
                    devices = [];
                    env = [
                      "RUN_SWAY=1"
                      "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
                    ];
                    image = "ghcr.io/games-on-whales/retroarch:edge";
                    mounts = ["/opt/roms:/mnt:ro"];
                    name = "WolfRetroarch";
                    ports = [];
                    type = "docker";
                  };
                }
                {
                  start_virtual_compositor = true;
                  title = "Steam";
                  icon_png_path = "https://games-on-whales.github.io/wildlife/apps/steam/assets/icon.png";
                  runner = {
                    base_create_json = ''
                      {
                        "HostConfig": {
                          "IpcMode": "host",
                          "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
                          "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
                          "Ulimits": [{"Name":"nofile", "Hard":10240, "Soft":10240}],
                          "Privileged": false,
                          "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                        }
                      }
                    '';
                    devices = [];
                    env = [];
                    image = "ghcr.io/gadgetmg/steam:sway";
                    mounts = ["/opt/steam/steamapps:/home/retro/.local/share/Steam/steamapps:rw"];
                    name = "WolfSteam";
                    ports = [];
                    type = "docker";
                  };
                }
                {
                  title = "Heroic";
                  start_virtual_compositor = true;
                  icon_png_path = "https://games-on-whales.github.io/wildlife/apps/heroic-games-launcher/assets/icon.png";
                  runner = {
                    base_create_json = ''
                      {
                        "HostConfig": {
                          "IpcMode": "host",
                          "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
                          "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
                          "Ulimits": [{"Name":"nofile", "Hard":10240, "Soft":10240}],
                          "Privileged": false,
                          "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                        }
                      }
                    '';
                    devices = [];
                    env = [
                      "RUN_SWAY=1"
                      "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
                    ];
                    image = "ghcr.io/games-on-whales/heroic-games-launcher:edge";
                    mounts = ["/opt/heroic:/home/retro/Games/Heroic:rw"];
                    name = "WolfHeroic";
                    ports = [];
                    type = "docker";
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
