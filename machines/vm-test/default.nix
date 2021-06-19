{ flakes, ... }:
{
    modules = [
        ./configuration.nix
    ];

    system = "aarch64-linux";
}