{
  flake.nixosModules.wolf = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.services.wolf;
    format = pkgs.formats.toml {};
  in {
    options.services.wolf = with lib; {
      enable = mkEnableOption "Enable Games on Whales Wolf";
      stateDir = mkOption {
        type = types.str;
        default = "/var/lib/wolf";
        description = "Directory to persist Wolf state";
      };
      configDir = mkOption {
        type = types.str;
        default = "/etc/wolf/cfg";
        description = "Directory to store Wolf configuration";
      };
      openFirewall = mkOption {
        type = types.bool;
        description = ''
          Open the firewall port(s).
        '';
        default = false;
      };
      config = mkOption {
        type = types.attrs;
        default = {
          config_version = 6;
          hostname = "Wolf";
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
              av1_encoders = [
                {
                  check_elements = [
                    "nvav1enc"
                    "cudaconvertscale"
                    "cudaupload"
                  ];
                  encoder_pipeline = ''
                    nvav1enc gop-size=-1 bitrate={bitrate} rc-mode=cbr zerolatency=true preset=p1 tune=ultra-low-latency multi-pass=two-pass-quarter !
                    av1parse !
                    video/x-av1, stream-format=obu-stream, alignment=frame, profile=main
                  '';
                  plugin_name = "nvcodec";
                }
                {
                  check_elements = [
                    "vaav1enc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    vaav1enc ref-frames=1 bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=6 !
                    av1parse !
                    video/x-av1, stream-format=obu-stream, alignment=frame, profile=main
                  '';
                  plugin_name = "va";
                }
                {
                  check_elements = [
                    "vaav1lpenc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    vaav1lpenc ref-frames=1 bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=6 !
                    av1parse !
                    video/x-av1, stream-format=obu-stream, alignment=frame, profile=main
                  '';
                  plugin_name = "va";
                }
                {
                  check_elements = [
                    "qsvav1enc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    qsvav1enc gop-size=0 ref-frames=1 bitrate={bitrate} rate-control=cbr low-latency=1 target-usage=6 !
                    av1parse !
                    video/x-av1, stream-format=obu-stream, alignment=frame, profile=main
                  '';
                  plugin_name = "qsv";
                }
                {
                  check_elements = [
                    "av1enc"
                  ];
                  encoder_pipeline = ''
                    av1enc usage-profile=realtime end-usage=vbr target-bitrate={bitrate} !
                    av1parse !
                    video/x-av1, stream-format=obu-stream, alignment=frame, profile=main
                  '';
                  plugin_name = "aom";
                  video_params = ''
                    videoconvertscale !
                    videorate !
                    video/x-raw, width={width}, height={height}, framerate={fps}/1, format=I420,
                    chroma-site={color_range}, colorimetry={color_space}
                  '';
                  video_params_zero_copy = ''
                    videoconvertscale !
                    videorate !
                    video/x-raw, width={width}, height={height}, framerate={fps}/1, format=I420,
                    chroma-site={color_range}, colorimetry={color_space}
                  '';
                }
              ];
              default_sink = ''
                rtpmoonlightpay_video name=moonlight_pay payload_size={payload_size} fec_percentage={fec_percentage} min_required_fec_packets={min_required_fec_packets} !
                appsink sync=false name=wolf_udp_sink

              '';
              default_source = "interpipesrc name=interpipesrc_{}_video listen-to={session_id}_video is-live=true stream-sync=restart-ts max-bytes=0 max-buffers=1 leaky-type=downstream";
              defaults = {
                nvcodec = {
                  video_params = ''
                    cudaupload !
                    cudaconvertscale add-borders=true !
                    video/x-raw(memory:CUDAMemory), width={width}, height={height}, chroma-site={color_range}, format=NV12, colorimetry={color_space}, pixel-aspect-ratio=1/1
                  '';
                  video_params_zero_copy = ''
                    cudaupload !
                    cudaconvertscale add-borders=true !
                    video/x-raw(memory:CUDAMemory),format=NV12, width={width}, height={height}, pixel-aspect-ratio=1/1
                  '';
                };
                qsv = {
                  video_params = ''
                    videoconvertscale !
                    video/x-raw, chroma-site={color_range}, width={width}, height={height}, format=NV12,
                    colorimetry={color_space}, pixel-aspect-ratio=1/1
                  '';
                  video_params_zero_copy = ''
                    vapostproc add-borders=true !
                    video/x-raw(memory:VAMemory), format=NV12, width={width}, height={height}, pixel-aspect-ratio=1/1
                  '';
                };
                va = {
                  video_params = ''
                    vapostproc add-borders=true !
                    video/x-raw, chroma-site={color_range}, width={width}, height={height}, format=NV12,
                    colorimetry={color_space}, pixel-aspect-ratio=1/1
                  '';
                  video_params_zero_copy = ''
                    vapostproc add-borders=true !
                    video/x-raw(memory:VAMemory), format=NV12, width={width}, height={height}, pixel-aspect-ratio=1/1
                  '';
                };
              };
              h264_encoders = [
                {
                  check_elements = [
                    "nvh264enc"
                    "cudaconvertscale"
                    "cudaupload"
                  ];
                  encoder_pipeline = ''
                    nvh264enc preset=low-latency-hq zerolatency=true gop-size=0 rc-mode=cbr-ld-hq bitrate={bitrate} aud=false !
                    h264parse !
                    video/x-h264, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "nvcodec";
                }
                {
                  check_elements = [
                    "vah264enc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    vah264enc aud=false b-frames=0 ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=6 !
                    h264parse !
                    video/x-h264, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "va";
                }
                {
                  check_elements = [
                    "vah264lpenc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    vah264lpenc aud=false b-frames=0 ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=6 !
                    h264parse !
                    video/x-h264, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "va";
                }
                {
                  check_elements = [
                    "qsvh264enc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    qsvh264enc b-frames=0 gop-size=0 idr-interval=1 ref-frames=1 bitrate={bitrate} rate-control=cbr target-usage=6 !
                    h264parse !
                    video/x-h264, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "qsv";
                }
                {
                  check_elements = [
                    "x264enc"
                  ];
                  encoder_pipeline = ''
                    x264enc pass=qual tune=zerolatency speed-preset=superfast b-adapt=false bframes=0 ref=1
                    sliced-threads=true threads={slices_per_frame} option-string="slices={slices_per_frame}:keyint=infinite:open-gop=0"
                    b-adapt=false bitrate={bitrate} aud=false !
                    video/x-h264, profile=high, stream-format=byte-stream
                  '';
                  plugin_name = "x264";
                }
              ];
              hevc_encoders = [
                {
                  check_elements = [
                    "nvh265enc"
                    "cudaconvertscale"
                    "cudaupload"
                  ];
                  encoder_pipeline = ''
                    nvh265enc gop-size=-1 bitrate={bitrate} aud=false rc-mode=cbr zerolatency=true preset=p1 tune=ultra-low-latency multi-pass=two-pass-quarter !
                    h265parse !
                    video/x-h265, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "nvcodec";
                }
                {
                  check_elements = [
                    "vah265enc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    vah265enc aud=false b-frames=0 ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=6 !
                    h265parse !
                    video/x-h265, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "va";
                }
                {
                  check_elements = [
                    "qsvh265enc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    qsvh265enc b-frames=0 gop-size=0 idr-interval=1 ref-frames=1 bitrate={bitrate} rate-control=cbr low-latency=1 target-usage=6 !
                    h265parse !
                    video/x-h265, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "qsv";
                }
                {
                  check_elements = [
                    "vah265lpenc"
                    "vapostproc"
                  ];
                  encoder_pipeline = ''
                    vah265lpenc aud=false b-frames=0 ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=6 !
                    h265parse !
                    video/x-h265, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "va";
                }
                {
                  check_elements = [
                    "x265enc"
                  ];
                  encoder_pipeline = ''
                    x265enc tune=zerolatency speed-preset=superfast bitrate={bitrate}
                    option-string="info=0:keyint=-1:qp=28:repeat-headers=1:slices={slices_per_frame}:aud=0:annexb=1:log-level=3:open-gop=0:bframes=0:intra-refresh=0" !
                    video/x-h265, profile=main, stream-format=byte-stream
                  '';
                  plugin_name = "x265";
                  video_params = ''
                    videoconvertscale !
                    videorate !
                    video/x-raw, width={width}, height={height}, framerate={fps}/1, format=I420,
                    chroma-site={color_range}, colorimetry={color_space}
                  '';
                  video_params_zero_copy = ''
                    videoconvertscale !
                    videorate !
                    video/x-raw, width={width}, height={height}, framerate={fps}/1, format=I420,
                    chroma-site={color_range}, colorimetry={color_space}
                  '';
                }
              ];
            };
          };
        };
        description = "Configuration represented as Nix attrset";
      };
    };

    config = let
      inherit (config.virtualisation.oci-containers) backend;
      dockerSocket =
        {
          "docker" = "/var/run/docker.sock";
          "podman" = "/run/podman/podman.sock";
        }."${backend}";
      dockerCommand =
        {
          "docker" = "${with pkgs; docker}/bin/docker";
          "podman" = "${with pkgs; podman}/bin/podman";
        }."${backend}";
      baseConfig = pkgs.writeTextFile {
        name = "wolf-base-config";
        text = format.generate "config.toml" cfg.config;
      };
    in
      lib.mkIf cfg.enable {
        virtualisation.oci-containers = {
          backend = "docker"; # currently, wolf-ui crashes when run under podman
          containers."wolf" = {
            serviceName = "wolf";
            image = "ghcr.io/games-on-whales/wolf:stable";
            pull = "always";
            networks = ["host"];
            devices = [
              "/dev/dri:/dev/dri:rwm"
              "/dev/uhid:/dev/uhid:rwm"
              "/dev/uinput:/dev/uinput:rwm"
            ];
            volumes = [
              "${cfg.configDir}:/etc/wolf/cfg"
              "${cfg.stateDir}:/etc/wolf"
              "${dockerSocket}:/var/run/docker.sock"
              "/dev/:/dev"
              "/run/udev:/run/udev"
            ];
            extraOptions = [
              "--device-cgroup-rule=c 13:* rmw"
            ];
          };
        };
        systemd.services.wolf = {
          description = "Games on Whales Wolf";
          serviceConfig = {
            # necessary as wolf is sometimes unable to connect to WolfPulseAudio after a restart
            ExecStartPre = "-${dockerCommand} rm --force WolfPulseAudio";
          };
          restartTriggers = [
            baseConfig
          ];
        };
        services.udev.packages = [
          # Ref: https://games-on-whales.github.io/wolf/stable/user/quickstart.html#_virtual_devices_support
          (pkgs.writeTextFile {
            name = "wolf-virtual-inputs-udev-rules";
            text = ''
              # Allows Wolf to acces /dev/uinput (only needed for joypad support)
              KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput", TAG+="uaccess"

              # Allows Wolf to access /dev/uhid (only needed for DualSense emulation)
              KERNEL=="uhid", GROUP="input", MODE="0660", TAG+="uaccess"

              # Joypads
              KERNEL=="hidraw*", ATTRS{name}=="Wolf PS5 (virtual) pad", GROUP="input", MODE="0660", ENV{ID_SEAT}="seat9"
              SUBSYSTEMS=="input", ATTRS{name}=="Wolf X-Box One (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9"
              SUBSYSTEMS=="input", ATTRS{name}=="Wolf PS5 (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9"
              SUBSYSTEMS=="input", ATTRS{name}=="Wolf gamepad (virtual) motion sensors", MODE="0660", ENV{ID_SEAT}="seat9"
              SUBSYSTEMS=="input", ATTRS{name}=="Wolf Nintendo (virtual) pad", MODE="0660", ENV{ID_SEAT}="seat9"
            '';
            destination = "/etc/udev/rules.d/85-wolf-virtual-inputs.rules";
          })
        ];
        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [47984 47989 48010];
          allowedUDPPorts = [47999 48010 48100 48200];
        };
        system.activationScripts.wolfConfig.text = ''
          ${with pkgs; yq}/bin/tomlq -t -s '.[0] * .[1]' ${cfg.configDir}/config.toml $(cat ${baseConfig}) > ${cfg.configDir}/config.toml.new
          mv ${cfg.configDir}/config.toml.new ${cfg.configDir}/config.toml
        '';
      };
  };
}
