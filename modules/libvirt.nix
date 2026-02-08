{inputs, ...}: {
  flake.modules.nixos.libvirt = {
    config,
    lib,
    ...
  }: let
    hosts = {
      carbon = {
        pool.uuid = "f0e6f7ac-1743-4a6d-a039-0ef1d72c78f7";
        network.default = {
          uuid = "704742fd-87cc-4391-aaf0-1ac32fb1a951";
          mac.address = "52:54:00:e3:f5:2d";
          ip = {
            address = "192.168.74.1";
            netmask = "255.255.255.0";
            dhcp = {
              range = {
                start = "192.168.74.2";
                end = "192.168.74.254";
              };
            };
          };
        };
      };
    };
    thisHost = hosts.${config.networking.hostName};
  in {
    imports = [
      inputs.nixvirt.nixosModules.default
    ];
    virtualisation = {
      libvirtd.enable = true;
      libvirt.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;
    users.users."matt".extraGroups = ["libvirtd"];
    virtualisation.libvirt = {
      connections."qemu:///system" = {
        pools = [
          {
            definition = inputs.nixvirt.lib.pool.writeXML {
              inherit (thisHost.pool) uuid;
              name = "default";
              type = "dir";
              target = {path = "/var/lib/libvirt/images";};
            };
            active = true;
          }
        ];
        networks = [
          {
            definition = inputs.nixvirt.lib.network.writeXML {
              inherit (thisHost.network.default) uuid mac ip;
              name = "default";
              bridge.name = "virbr0";
              forward = {
                mode = "nat";
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
              };
            };
            active = true;
          }
        ];
      };
    };
  };
}
