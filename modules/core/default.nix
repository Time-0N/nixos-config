{
  inputs,
  host,
  ...
}:
let
  vars = import ../../hosts/${host}/variables.nix;
in
{
  imports = [
    ./displaymanager.nix
  ];
}
