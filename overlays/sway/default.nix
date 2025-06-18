{
  channels,
  inputs,
  ...
}: final: prev: {
  sway-unwrapped = (prev.sway-unwrapped.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "1.10.1";
      src = final.fetchFromGitHub {
        owner = "swaywm";
        repo = "sway";
        rev = finalAttrs.version;
        hash = "sha256-uBtQk8uhW/i8lSbv6zwsRyiiImFBw1YCQHVWQ8jot5w=";
      };
    }
  )).override {wlroots = final.wlroots_0_18;};
}
