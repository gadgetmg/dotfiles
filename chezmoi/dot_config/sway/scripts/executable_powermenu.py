#!/usr/bin/env python3
import subprocess
import sys

# Define options
options = [
    "󰗽 Logout",
    " Reboot",
    "󰐥 Shutdown",
    "󰒲 Suspend",
    "󰤄 Hibernate"
]

# Show menu with fuzzel
try:
    fuzzel = subprocess.run(
        ["fuzzel", "--dmenu", "--lines", "5"],
        input="\n".join(options).encode("utf-8"),
        stdout=subprocess.PIPE,
        check=True
    )
    chosen = fuzzel.stdout.decode("utf-8").strip()
except subprocess.CalledProcessError:
    sys.exit(0)

# Handle chosen option
if chosen == "󰒲 Suspend":
    subprocess.run(["systemctl", "suspend"])
elif chosen == "󰤄 Hibernate":
    subprocess.run(["systemctl", "hibernate"])
elif chosen == " Reboot":
    subprocess.run(["systemctl", "reboot"])
elif chosen == "󰐥 Shutdown":
    subprocess.run(["systemctl", "poweroff"])
elif chosen == "󰗽 Logout":
    subprocess.run(["uwsm", "stop"])
else:
    sys.exit(0)
