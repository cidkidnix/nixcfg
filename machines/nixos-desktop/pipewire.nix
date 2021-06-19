  { config, pkgs, lib, ... }:

  let 
    quantum = "128";
    loglevel = "2";
  in 
{

  services.pipewire = {
	  enable = true;
	  pulse.enable = true;
	  alsa.enable = true;
    alsa.support32Bit = true;
	  jack.enable = true;
    config.pipewire = {
      "context.properties" = {
        "link.max-buffers" = 16;
        "log.level" = "${loglevel}";
        "default.clock.rate" = 96000;
        "default.clock.quantum" = "${quantum}";
        "default.clock.min-quantum" = "${quantum}";
        "default.clock.max-quantum" = "${quantum}";
        "core.daemon" = true;
        "core.name" = "pipewire-0";
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -11;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }

        { name = "libpipewire-module-protocol-native"; }

        { name = "libpipewire-module-profiler"; }

        { name = "libpipewire-module-metadata"; }

        { name = "libpipewire-module-spa-device-factory"; }

        { name = "libpipewire-module-spa-node-factory"; }

        { name = "libpipewire-module-client-node"; }

        { name = "libpipewire-module-client-device"; }

        {
          name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }

        {
          name = "libpipewire-module-access";
          args = {};
        }

        { name = "libpipewire-module-adapter"; }

        { name = "libpipewire-module-link-factory"; }

        { name = "libpipewire-module-session-manager"; }
      ];
    };

    config.pipewire-pulse = {
      "context.properties" = {
        "log.level" = "${loglevel}";
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -11;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }

        { name = "libpipewire-module-protocol-native"; }

        { name = "libpipewire-module-client-node"; }

        { name = "libpipewire-module-adapter"; }

        { name = "libpipewire-module-metadata"; }

        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "${quantum}/96000";
            "pulse.default.req" = "${quantum}/96000";
            "pulse.max.req" = "${quantum}/96000";
            "pulse.min.quantum" = "${quantum}/96000";
            "pulse.max.quantum" = "${quantum}/96000";
	          "pulse.min.frag" = "48000/96000";
	          "pulse.default.frag" = "48000/96000";
            "pulse.max.frag" = "48000/96000";
            "pulse.min.tlength" = "48000/96000";
	          "pulse.default.tlength" = "48000/96000";
            "pulse.max.tlength" = "48000/96000";
            "pulse.default.format" = "F32";
            "pulse.default.position" = [ "FL" "FR" ];
	          "server.address" = [
	    	      "unix:native"
	          ];
          };
        }
      ];

      "stream.properties" = {
        "node.latency" = "${quantum}/96000";
        "resample.quality" = 0;
      };
    };


    config.client = {
        "filter.properties" = {
            "node.latency" = "${quantum}/96000";
        };

        "stream.properties" = {
            "node.latency" = "${quantum}/96000";
            "resample.quality" = 0;
        };
    };

    config.client-rt = {
        "filter.properties" = {
            "node.latency" = "${quantum}/96000";
        };

        "stream.properties" = {
            "resample.quality" = 0;
            "node.latency" = "${quantum}/96000";
        };
    };

    media-session = {
      config.alsa-monitor = {
        "rules" = [
          {
            "matches" = [
              {
                "device.name" = "~alsa_card.*";
              }
            ];
            "actions" = {
              "update-props" = {
                "api.alsa.use-acp" = true;
                "api.alsa.soft-mixer" = false;
                "api.acp.auto-profile" = false;
                "api.acp.auto-port" = false;
                "api.alsa.disable-batch" = false; ## maybe not needed for USB? Fuck if I know
              };
            };
          }
          {
            matches = [
              {
                "node.name" = "~alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K5_Pro-00.*";
              }
            ];
            "actions" = {
              "update-props" = {
                "node.nick" = "FiiO K5 Pro";
                "node.pause-on-idle" = false;
                "resample.quality" = 0;
                "channelmix.normalize" = false;
                "audio.channels" = 2;
                "audio.format" = "S32LE";
                "audio.rate" = 96000;
                "audio.position" = "FL,FR";
                "api.alsa.period-size" = 128;
                "api.alsa.headroom" = 0;
              };
            };
          }
        ];
      };
      config.media-session = {
        "context.properties" = {
          log.level = "${loglevel}";
        };
        "context.modules" = [
          {
            name = "libpipewire-module-rtkit";
            args = {
              "nice.level"   = -11;
              "rt.prio"      = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
            flags = [ "ifexists" "nofail" ];
          }

          { name = "libpipewire-module-protocol-native"; }

          { name = "libpipewire-module-client-node"; }

          { name = "libpipewire-module-client-device"; }

          { name = "libpipewire-module-adapter"; }

          { name = "libpipewire-module-metadata"; }

          { name = "libpipewire-module-session-manager"; }
        ];
      };
    };
  };
  }
