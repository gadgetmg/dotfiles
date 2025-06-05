{ channels, inputs, ... }:

final: prev: {
  llama-cpp =
    (prev.llama-cpp.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "5574";
        src = final.fetchFromGitHub {
          owner = "ggml-org";
          repo = "llama.cpp";
          tag = "b${finalAttrs.version}";
          hash = "sha256-0poXRmqnyVE3/qoo3LlTcN0peaGtRXO8cp1cq0XqB+c=";
          leaveDotGit = true;
          postFetch = ''
            git -C "$out" rev-parse --short HEAD > $out/COMMIT
            find "$out" -name .git -print0 | xargs -0 rm -rf
          '';
        };
        patches = [ ./revert-09d13d9.diff ];
      }
    )).override
      { vulkanSupport = true; };
}
