{
  channels,
  inputs,
  ...
}: final: prev: {
  llama-cpp =
    (prev.llama-cpp.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "5606";
        src = final.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          tag = "b${finalAttrs.version}";
          hash = "sha256-sTfeGJ5Xm5oYi3E7FNdH4sxbs4Uen7shtNIIQtApgUg=";
          leaveDotGit = true;
          postFetch = ''
            git -C "$out" rev-parse --short HEAD > $out/COMMIT
            find "$out" -name .git -print0 | xargs -0 rm -rf
          '';
        };
        patches = [./revert-09d13d9.diff];
      }
    )).override
    {vulkanSupport = true;};
}
