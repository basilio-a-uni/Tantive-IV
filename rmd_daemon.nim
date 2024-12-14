import os, json, times
import std/dirs, std/paths, std/files
import libnotify

let client = newNotifyClient("renimders")
client.set_app_name("renimders")

const activePath = Path(getHomeDir()) / Path(".renimders") / Path("notifications")
const archivePath = Path(getHomeDir()) / Path(".renimders") / Path("archived")

# object that hold the name, the time in seconds and the optional description of the notification
type Notification = object
    description: string
    time: int
    urgency: int

proc intToUrgencty(urgency: int) : NotificationUrgency =
    case urgency
    of 1: NotificationUrgency.Low
    of 2: NotificationUrgency.Normal
    of 3: NotificationUrgency.Critical
    else: NotificationUrgency.Normal

proc jsonToNotification(json: JsonNode) : Notification =
    return Notification(
        description: json["description"].getStr(),
        time: json["time"].getInt(),
        urgency: json["urgency"].getInt()
    )

func notif(client : NotifyClient, notification : Notification, timeout: int) = 
    client.send_new_notification("Timer's Up", notification.description, "STOCK_YES", urgency=intToUrgencty(notification.urgency))

assert expandTilde(Path("~") / Path("appname.cfg")) == Path(getHomeDir()) / Path("appname.cfg")

echo typeof getHomeDir()
proc main() =
    while true:
        if not dirExists(activePath):
            break
        for kind, jsonPath in walkDir(activePath):
            if kind == pcFile:
                let fileData = readFile($jsonPath)
                let notificationData = parseJson(fileData)
                let notification = jsonToNotification(notificationData)
                if notification.time < getTime().toUnix():
                    moveFile(jsonPath, archivePath / extractFilename(jsonPath))
                    notif(client, notification, 0)
        sleep(2000)


main()
