let
  # Your personal age key (from ~/.config/age/keys.txt
  phatle = "age1krccquqdzltve5qa5mtl2e44jtkhvfpe9g8wrkutk69w675tg3ysneq4l4";

  # Machine age keys
  nixos = "age1tv9ws7tdvqm2k035766qmnwg5av7hxqkcegt68gwt6cyphs68fmsf82tdt";

  # Groups for convenience
  users = [ phatle ];
  servers = [ nixos ];
  allSystems = users ++ servers;
in
{
  "canlock.age".publicKeys = users;
  "gnus-name.age".publicKeys = users;
  "gnus-email.age".publicKeys = users;
  "restic-password.age".publicKeys = users;
  "storagebox.age".publicKeys = users;
  "github.age".publicKeys = users;
  "codeberg.age".publicKeys = users;
  }
