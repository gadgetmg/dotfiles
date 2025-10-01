{
  channels,
  inputs,
  ...
}: final: prev: {
  inherit (channels.trunk) caido llama-swap onedrive;
  inherit (channels.unstable) lact;
}
