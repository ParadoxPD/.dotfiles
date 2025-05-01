#!/bin/bash

echo "DISABLE DOCK-TO-DASH EXTENSION KEB BINDS OR ELSE IT WILL OVERRIDE THIS SHIIII"

# Disable dynamic workspaces and set a fixed number
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10

# Loop through workspaces 1 to 9
for i in $(seq 1 9); do
    echo "Configuring workspace $i"

    # # Unset invalid keybindings (only if necessary)
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]" 2>/dev/null || true
    gsettings set org.gnome.shell.keybindings open-new-window-application-$i "[]" 2>/dev/null || true

    # Set workspace switching and moving shortcuts
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done

gsettings set org.gnome.shell.keybindings switch-to-application-10 "[]" 2>/dev/null || true
gsettings set org.gnome.shell.keybindings open-new-window-application-10 "[]" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-10 "['<Super>0']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-10 "['<Super><Shift>0']"

echo "Workspace configuration complete!"
