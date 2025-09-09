

source /usr/share/cachyos-fish-config/cachyos-config.fish
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -x --universal MESA_SHADER_CACHE_MAX_SIZE '12G'
alias cat='bat'
alias hdmi='xrandr --output HDMI-A-0 --mode 1440x900 --rate 75'
alias tearingoff='xrandr --output HDMI-A-0 --set TearFree off'
alias tearingon='xrandr --output HDMI-A-0 --set TearFree on'
alias 1080p='xrandr --output HDMI-A-0 --mode 1920x1080 --rate 60'
alias 900p='xrandr --output HDMI-A-0 --mode 1440x900 --rate 75'
alias 1080pw='wlr-randr --output HDMI-A-1 --mode 1920x1080@60'
alias 900pw='wlr-randr --output HDMI-A-1 --mode 1440x900@74.984001'
alias exitwm='pkill -U $USER'
alias audio='systemctl --user restart pipewire pipewire-pulse wireplumber'
alias setpath='set -x PATH $PWD $PATH'
alias plasmaservices='kcmshell6 kcm_kded'
alias mouseaccel='xinput set-prop "8" "libinput Accel Profile Enabled" 0 1 0'
alias startplasma='/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland'
alias kill='pkill'
alias monitor='xset s off && xset -dpms'
alias buildscx='cargo build --release --target-dir /tmp/scx'
alias usb='sudo ~array/./resetusb.sh'
alias sleepmon='xset dpms force standby'
alias sleepwayland='~array/turn-off-monitors.sh'
alias dns='systemctl restart dhcpcd && systemctl restart adguardhome'
alias checkcpufreq='watch -n.5 "grep \"^[c]pu MHz\" /proc/cpuinfo"'
alias whichpackage='pacman -Qo'
alias auracheck='aura -Syu && aura -Akaxu'
alias ff='fzf_file_search'
set -U EDITOR subl

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
end

function config_ssh_agent
  # Start the SSH agent and capture the socket path
  set agent_socket (ssh-agent -s)

  # Check for successful start (exit code 0)
  if test $status -eq 0
    # Set the SSH_AUTH_SOCK environment variable
    set -gx SSH_AUTH_SOCK $agent_socket
    echo "SSH agent started and configured for Fish shell."
  else
    echo "Error starting SSH agent."
  end
end

