mkdir -p "$HOME/.renimders/notifications"
mkdir "$HOME/.renimders/archive"
echo "Created directories: ~/.renimders/notifications and ~/.renimders/archive"

nim c -d:release "rmd.nim"
nim c -d:release "rmd_daemon.nim"
echo "Compiled rmd.nim and rmd_daemon.nim"


FILE="rmd.service"

USERNAME=$(whoami)
GROUPNAME=$(id -gn)

cp "$FILE" "$FILE.bak"
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

sed -i "s/User=/User=$USERNAME/g" "$FILE"
sed -i "s/Group=/Group=$GROUPNAME/g" "$FILE"
echo "Updated User and Group in $FILE"

echo "Running as sudo to install the commands and enable the service"
sudo cp "rmd" "/usr/local/bin/rmd"
sudo cp "rmd_daemon" "/usr/local/bin/rmd_daemon"
echo "Copied rmd and rmd_daemon to /usr/local/bin"

sudo chown $USERNAME:$GROUPNAME /usr/local/bin/rmd_daemon
sudo chmod u+x /usr/local/bin/rmd_daemon
echo "Changed permissions on /usr/local/bin/rmd_daemon"

sudo cp "rmd.service" "/etc/systemd/system/rmd.service"
sudo systemctl enable --now rmd&
mv "$FILE.bak" "$FILE"
echo "Enabled and started rmd.service"

echo "Finished the installing, you can use rmd --help for more information about usage"