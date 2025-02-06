#!/bin/sh

# Based off https://github.com/mbugert/tailscale-polybar-rofi/blob/98367fb6461621f5feaa224ef7dd28f72dfb1cb0/info-tailscale.sh

ICON_ACTIVE=""
ICON_INACTIVE=""

status=$(curl --silent --fail --unix-socket /var/run/tailscale/tailscaled.sock http://local-tailscaled.sock/localapi/v0/status)

# bail out if curl had non-zero exit code
if [ $? != 0 ]; then
    exit 0
fi

# check if it's stopped (down)
if [ "$(echo ${status} | jq --raw-output .BackendState)" = "Stopped" ]; then
    echo "${ICON_INACTIVE} VPN down"
    exit 0
fi

# if an exit node is active, show its hostname
exit_node_hostname="$(echo ${status} | jq --raw-output '.Peer[] | select(.ExitNode) | .HostName')"
if [ -n "${exit_node_hostname}" ]; then
    echo "${ICON_ACTIVE} VPN ${exit_node_hostname}"
else
    echo "${ICON_ACTIVE} VPN up"
fi
