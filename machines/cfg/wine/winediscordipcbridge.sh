#!/usr/bin/env bash
BRIDGE="/persist/etc/nixos/machines/cfg/wine/winediscordipcbridge.exe" # Set BRIDGE to the path of winediscordipcbridge.exe
DELAY=5

# Extract and run the proton command without the steam runtime container (see #8)
runtimecmd=()
protoncmd=()
for arg in "$@"; do
    if [ "${runtimecmd[-1]}" == "--" ]; then
        protoncmd+=("$arg");
    else
        runtimecmd+=("$arg");
    fi
done

gamecmd=("${protoncmd[@]:2}")
protoncmd=("${protoncmd[@]:0:2}")

# If no -- is detected, we're probably running Proton 5.0-10 or older
if [ -z "${protoncmd}" ]; then
    protoncmd=("${@:1:2}")
    gamecmd=("${@:3}")
fi

"${protoncmd[@]}" "$BRIDGE" &
sleep $DELAY
"${protoncmd[@]//waitforexitandrun/run}" "${gamecmd[@]}"