{
  lib,
  python3Packages,
  fetchPypi,
  mopidy,
}:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-autoplay";
  version = "0.2.3";

  src = fetchPypi {
    inherit version;
    pname = "Mopidy-Autoplay";
    hash = "sha256-E2Q+Cn2LWSbfoT/gFzUfChwl67Mv17uKmX2woFz/3YM=";
  };

  propagatedBuildInputs = with python3Packages; [
    mopidy
    pykka
  ];

  meta = with lib; {
    description = "Mopidy extension to automatically pick up where you left off and start playing the last track from the position before Mopidy was shut down.";
    homepage = "https://codeberg.org/sph/mopidy-autoplay";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
