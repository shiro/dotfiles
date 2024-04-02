{ lib, fetchPypi, buildPythonPackage }:

buildPythonPackage rec {
  version = "2.0.13";
  pname = "map2";
  src = fetchPypi {
    inherit pname version format;
    sha256 = "a66b6dc823ef40e43dfdba0d28f8eea59ccc86d85562ecf63508fb09cc145ffc";
    dist = "cp39";
    python = "cp39";
    platform = "manylinux2014_x86_64";
  };
}
