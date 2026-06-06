#!/bin/bash

LAPTOP_SCREEN="eDP1"
_external_screen() {
    echo "$(xrandr | grep ' connected' | grep -v $LAPTOP_SCREEN | awk '{ print $1 }')"
}

source ~/.conf_root

# Wrapping commands for startup apps. *_cc suffix is for ===============
# "custom config." =====================================================

alacritty_cc() {
    type alacritty && alacritty --config-file "${CONF_ROOT}/alacritty.toml"
    if [[ $# -ne 0 ]]; then
        $CONF_ROOT/../tools/alacritty/target/release/alacritty --config-file "${CONF_ROOT}/alacritty.toml" --class floating -e "$@"
    else
        $CONF_ROOT/../tools/alacritty/target/release/alacritty --config-file "${CONF_ROOT}/alacritty.toml"
    fi
}

dunst_cc() {
    # stop the dunst instance spawned by systemd, which is installed by i3.
    systemctl stop dunst --user
    dunst -conf "${CONF_ROOT}/dunstrc"
}

rofi_show() {
    rofi -config "${CONF_ROOT}/rofi/config" -show drun -modi drun
}

rofi_window() {
    rofi -config "${CONF_ROOT}/rofi/config" -show window
}

rofi_control() {
    declare -A actions=( \
        ["Turn off the screen"]="screen_turn_off" \
        ["Cover the screen"]="screen_cover" \
        ["Sleep"]="system_sleep" \
        ["Hibernate"]="system_hibernate" \
        ["Shutdown"]="system_shutdown" \
        ["Reboot"]="system_reboot" \
        ["Lock"]="lock" \
        ["English keyboard"]="kbd_en" \
        ["Swedish keyboard"]="kbd_sve" \
        ["Turkish keyboard"]="kbd_tr" \
        ["Screenshot"]="shot" \
        ["Switch to external screen"]="externalscreen" \
        ["Switch to main screen"]="noscreen" \
        ["Logout"]="i3_logout" \
    );
    actions_selection=( \
        'Turn off the screen' \
        'Cover the screen' \
        'Sleep' \
        'Hibernate' \
        'Shutdown' \
        'Reboot' \
        'Lock' \
        'English keyboard' \
        'Swedish keyboard' \
        'Turkish keyboard' \
        'Screenshot' \
        'Switch to external screen' \
        'Switch to main screen' \
        'Logout' \
    );
    pick_str=$(printf '%b\n' "${actions_selection[@]}" | \
        rofi -disable-history -config "${CONF_ROOT}/rofi/config" -dmenu -p 'Control' -i);
    eval ${actions[$pick_str]}
}

# Custom commands ======================================================
noscreen() {
    xrandr 2>&1 /dev/null
    sleep 0.5
    turn_others_off=$(xrandr | grep -oE '^[a-zA-Z0-9\-]+ (dis)?connected' | \
        awk '{print "--output " $1 " --off"}' ORS=' ');
    xrandr $turn_others_off
    xrandr --output ${LAPTOP_SCREEN} --auto --primary --dpi 72
}

externalscreen () {
    xrandr 2>&1 /dev/null
    sleep 0.5
    external=$(_external_screen)
    if [[ -z $(xrandr | grep "${external} connected") ]]; then
        # fallback
        noscreen
    fi

    turn_others_off=$(xrandr | grep -oE '^[a-zA-Z0-9\-]+ (dis)?connected' | \
        awk '{print "--output " $1 " --off"}' ORS=' ');
    xrandr $turn_others_off
    xrandr --output ${external} --auto --primary --dpi 72
}

volume_curr() {
    pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}' | grep -oE '[0-9]+'
}

volume_up() {
    notify-send "Volume" -h "int:value:$(volume_curr)"
    pactl set-sink-volume @DEFAULT_SINK@ +10%
}

volume_down() {
    notify-send "Volume" -h "int:value:$(volume_curr)"
    pactl set-sink-volume @DEFAULT_SINK@ -10%
}

volume_mute_toggle() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

mic_mute_toggle() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
}

brightness_curr() {
    printf '%0.f' $(xbacklight)
}

brightness_up() {
    notify-send "Brightness" -h "int:value:$(brightness_curr)"
    xbacklight -inc 10
}

brightness_down() {
    notify-send "Brightness" -h "int:value:$(brightness_curr)"
    xbacklight -dec 10
}

rename_window() {
    xdotool set_window --name "$2" $(xdotool getactivewindow)
}

shot() {
    FILENAME=$(date +'%F_%H-%M-%S');
    if [[ $1 != '' ]]; then
        FILENAME=$1
    fi
    mkdir -p  ~/Pictures/ss;
    scrot -s "${HOME}/Pictures/ss/${FILENAME}.png";
}

beep() {
    speaker-test -t sine -f 1000 -l 1 & sleep 1 && kill -9 $!
}

screen_turn_off() {
    sleep 1 && xset dpms force off
}

lock() {
    i3lock -i ~/Downloads/wp.png && screen_turn_off
}

screen_cover() {
    python3 "${CONF_ROOT}/screencover.py"
}

i3_logout() {
    i3-msg exit
}

kbd_toggle() {    
    kbd_init
    case \
        $(setxkbmap -query | grep layout | cut -f2 -d ':' | xargs echo | cut -f1 -d ',') \
        in
    us)
        setxkbmap -layout se
        notify-send 'kbd: se'
        ;;
    se)
        setxkbmap -layout tr;
        notify-send 'kbd: tr'
        ;;
    tr)
        setxkbmap -layout us;
        notify-send 'kbd: us'
        ;;
    *)
        notify-send "ERROR";
        ;;
    esac
}

kbd_init() {
    xset r rate 170 40  # time-out & repeat speed
    setxkbmap -option
}

kbd_en() {
    kbd_init
    setxkbmap -layout us
    notify-send 'keyboard layout: english'
}

kbd_sve() {
    kbd_init
    setxkbmap -layout se
    notify-send 'keyboard layout: swedish'
}

kbd_tr() {
    kbd_init
    setxkbmap -layout tr
    notify-send 'keyboard layout: turkish'
}

# systemctl suspend writes the state to ram
# + faster to wake up
# - no effect on disk
# - more power consumption
system_sleep() {
    systemctl suspend
}

# systemctl hibernate writes the state to disk
# + less power consumption
# - heavier on the disk
# - asks for disk password if there's one
system_hibernate() {
    systemctl hibernate
}

system_shutdown() {
    systemctl poweroff
}

system_reboot() {
    systemctl reboot
}
eval ${1} ${@:2}
