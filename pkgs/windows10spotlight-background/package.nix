{
  writeShellApplication,
  curl,
  gnugrep,
  jq,
  procps,
  sway,
  swaybg,
  ...
}:
writeShellApplication {
  name = "windows10spotlight-background";
  runtimeInputs = [curl gnugrep jq procps sway swaybg];
  bashOptions = ["nounset" "pipefail"];
  text = builtins.readFile ./windows10spotlight-background.sh;
}
