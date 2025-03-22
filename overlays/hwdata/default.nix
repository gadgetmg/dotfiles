{ channels, inputs, ... }:

final: prev: {
  upstream-hwdata = prev.hwdata.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.393";
      src = final.fetchFromGitHub {
        owner = "vcrhonek";
        repo = "hwdata";
        rev = "v${finalAttrs.version}";
        hash = "sha256-RDp5NY9VYD0gylvzYpg9BytfRdQ6dim1jJtv32yeF3k=";
      };
    }
  );
}
