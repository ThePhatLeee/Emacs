{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # PostgreSQL
    postgresql
    pgcli          # PostgreSQL CLI with autocomplete
    
    # SQL tools
    sqls           # SQL language server
    sqlfluff       # SQL linter
    
    # Database management
    dbeaver-bin    # Universal database tool
  ];

  # Enable PostgreSQL service (optional - for local development)
  # Uncomment if you want a local PostgreSQL instance
   services.postgresql = {
     enable = true;
     package = pkgs.postgresql;
     enableTCPIP = true;
     authentication = pkgs.lib.mkOverride 10 ''
       local all all trust
       host all all 127.0.0.1/32 trust
       host all all ::1/128 trust
     '';
     initialScript = pkgs.writeText "backend-initScript" ''
       CREATE DATABASE devdb;
       CREATE USER postgres WITH PASSWORD 'postgres';
       GRANT ALL PRIVILEGES ON DATABASE devdb TO postgres;
     '';
   };
}
