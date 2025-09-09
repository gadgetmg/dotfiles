{
  channels,
  inputs,
  ...
}: final: prev: {
  inherit (channels.trunk) llama-swap;
  inherit (channels.unstable) lact;
}
