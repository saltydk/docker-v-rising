#!/bin/sh
onExit() {
    kill -INT -$(ps -A | grep 'VRising' | awk '{print $1}') &>> /saves/wtf
    wait $!
}

check_req_vars() {
    if [ -z "${V_RISING_NAME}" ]; then
        echo "V_RISING_NAME has to be set"

        exit
    fi

    if [ -z "${V_RISING_SAVE_NAME}" ]; then
        echo "V_RISING_SAVE_NAME has to be set"

        exit
    fi

    if [ -z "${V_RISING_PUBLIC_LIST}" ]; then
        echo "V_RISING_PUBLIC_LIST has to be set"

        exit
    fi
}

setServerHostSettings() {
    check_req_vars

    echo "Using env vars for ServerHostSettings"
    envsubst < /templates/ServerHostSetting.templ > /saves/Settings/ServerHostSettings.json
}

setServerGameSettings() {

    echo "Using env vars for ServerGameSettings"
    envsubst < /templates/ServerGameSettings.templ > /saves/Settings/ServerGameSettings.json
}

# This logic is flawed and I don't have the energy to fix this
checkGameSettings() {
    if [ ! -f "/saves/Settings/ServerGameSettings.json" ]; then
        setServerGameSettings
    else
        echo "Using /saves/Settings/ServerGameSettings.json for settings"
    fi
}

# This logic is flawed and I don't have the energy to fix this
checkHostSettings() {
    if [ ! -f "/saves/Settings/ServerHostSettings.json" ]; then
        check_req_vars
        setServerHostSettings
    else
        echo "Using /saves/Settings/ServerHostSettings.json for settings"
    fi
}

./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +app_update 1829350 validate +quit

if [ ! -d "/saves/Settings" ]; then
    mkdir /saves/Settings
fi

checkGameSettings
checkHostSettings

trap onExit INT TERM KILL

cd $GAME_DIR
Xvfb :0 -screen 0 1024x768x16 &
setsid '/launch_server.sh' &

echo $!
wait $!