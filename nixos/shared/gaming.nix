{
  pkgs,
  username,
  ...
}:
{
  users.users.${username}.packages = with pkgs; [
    (bottles.override { removeWarningPopup = true; }) # wine emulation organization
  ];
}
