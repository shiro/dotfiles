let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};

buildPythonPackage = pkgs.python311Packages.buildPythonPackage;
fetchPypi = pkgs.python311Packages.fetchPypi;

cloudscale-sdk = buildPythonPackage
rec {
  pname = "map2";
  version = "2.0.13";
  # format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-iHsvxgUJctA//flSFqWyup2OBPX3Xc+hFUfv9vA2H1U=";
  };

  doCheck = false;

  propagatedBuildInputs = with pkgs.python311Packages; [
    requests
    xdg
  ];
};

# cloudscale-cli = buildPythonPackage
# rec {
#   pname = "cloudscale-cli";
#   version = "1.4.0";
#
#   doCheck = false;
#
#   src = fetchPypi {
#     inherit pname version;
#     sha256 = "sha256-YfdiyUZmBOXwPtOeT7JoZMt3X37oIf36a+TIPvGJV/U=";
#   };
#
#   propagatedBuildInputs = with pkgs.python311Packages; [
#     click
#       cloudscale-sdk
#       jmespath
#       natsort
#       pygments
#       tabulate
#       yaspin
#   ];
# };

# in
# {
#   home.packages = [
#     (pkgs.python311.withPackages (p: withp; [
#                                   cloudscale-cli
#     ]))
#   ];
# }
