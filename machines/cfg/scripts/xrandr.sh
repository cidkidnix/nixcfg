#!/usr/bin/env bash
while :
do
    base=`xrandr | grep 143 -B5`
    isprimary=`echo $base | grep -o primary`
    xwldisplay=`echo $base | grep -ow "X\w*"`
    if [[ $isprimary == "primary" ]]
    then
        sleep 1
    else
        echo "Not primary"
        echo "Setting Primary Screen: $xwldisplay"
        xrandr --output $xwldisplay --primary

        sleep 20
    fi
done
