{
  pkgs,
  username,
  ...
}:
{
  users.users.${username}.packages = with pkgs; [
    discord # chat
    betterdiscordctl # discord modding
  ];
}
