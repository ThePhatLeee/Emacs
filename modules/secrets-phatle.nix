{ config, lib, ... }:
{
  age.identityPaths = [
    "/home/phatle/.config/age/keys.txt"
  ];

  age.secrets = {
    canlock = {
      file = ../secrets/canlock.age;
      owner = "phatle";
      mode = "400";
    };
    gnus-name = {
      file = ../secrets/gnus-name.age;
      owner = "phatle";
      mode = "400";
    };
    gnus-email = {
      file = ../secrets/gnus-email.age;
      owner = "phatle";
      mode = "400";
    };
  };
}
