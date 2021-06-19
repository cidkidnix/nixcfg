{config, pkgs, lib, home-manager, ... }:
{
  home-manager.users.cidkid = {
      programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        https-everywhere
        privacy-badger
        darkreader
        ublock-origin
      ];
      profiles.cidkid = {
        name = "cidkid";
        id = 0;
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://google.com";
          "browser.search.isUS" = true;
          "browser.link.open_newwindow" = 1;
          "browser.link.open_newwindow.restriction" = 0;
          "browser.link.open_newwindow.override.external" = 3;
          "browser.proton.enabled" = true;
          "browser.proton.appmenu.enabled" = true;
          "browser.proton.tabs.enabled" = true;
          "browser.proton.toolbar.enabled" = true;
          "browser.proton.urlbar.enabled" = true;
          "browser.proton.contextmenus.enabled" = true;
          "browser.aboutwelcome.design" = true;
          "browser.proton.modals.enabled" = true;
          "browser.proton.infobars.enabled" = true;
          "general.useragent.locale" = "en-US";
          "gfx.webrender.all" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = '' 
          ${builtins.readFile ./userChrome.main.css} 
          ${builtins.readFile ./userChrome.megabarstyler.css}
        '';
        userContent = builtins.readFile ./userContent.css;
      };
    };
  };
}