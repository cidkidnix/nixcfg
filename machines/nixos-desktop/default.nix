{ inputs }:

{
    modules = [
        ./configuration.nix
        ../cfg/home-manager/home-manager.nix
        ../cfg/profiles/anbox/default.nix
        ./containers.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.age
        inputs.flake-utils-plus.nixosModules.saneFlakeDefaults
        inputs.musnix.nixosModules.musnix
        ({pkgs, config, ... }: {
            nixpkgs.overlays = [
                inputs.musnix.overlay
            ];
        })
    ];

    system = "x86_64-linux";
}