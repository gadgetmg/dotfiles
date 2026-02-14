{
  flake.modules.nixos.scx = _: {
    services.scx-loader = {
      enable = true;
      settings.default_sched = "scx_cake";
    };

    # Polkit rule for "scx" group to manage schedulers
    users.groups.scx = {};
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.scx.loader.manage-schedulers" &&
              subject.isInGroup("scx")) {
              return polkit.Result.YES;
          }
      });
    '';

    users.users."matt".extraGroups = ["scx"];
  };
}
