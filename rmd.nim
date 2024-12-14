import os, strutils, re, tables, json, times
import std/paths
import argparse

let activePath = Path(getHomeDir()) / Path(".renimders") / Path("notifications")

const help_message = "help message"
const timeTable = {
    "s": 1,
    "m": 60,
    "h": 3600,
    "d": 86400,
    "w": 604800,
    "M": 2592000,
    "y": 31536000
}.toTable

let pattern = re"(\d\d*)\s*([hmsdwMy])"

type Notification = object
    description: string
    time: int
    urgency: int


let p = newParser:
    option("-t", "--time", help = "Option to specify time (if not provided the program will try to parse it from the input), supported formats are: h-> hours, m-> minutes, s-> seconds, d-> days, w-> weeks, M-> months, y-> years, Ex: 12h -> 12 hours")
    flag("-i", "--important", help = "Flag to raise urgency level of the notification")
    arg("input", nargs = -1, help="Input for the notification description")
    help(help_message)

proc parseTime(time: string) : int =
    var matches: array[2, string]
    discard re.match(time, pattern, matches)

    let value = parseInt(matches[0])
    return value * timeTable[matches[1]]

proc notificationToJson(notification: Notification) : JsonNode =
    return %*{
        "description": notification.description,
        "time": notification.time,
        "urgency": notification.urgency,
        "creationTime": $now()
    }

proc parseInput(input: string) : (string, string) = 
    let seqInput = input.split(" ")
    
    if len(seqInput) < 2:
        raise newException(ValueError, "Unable to parse the input")
    
    let firstWord = seqInput[0]
    let lastWord = seqInput[len(seqInput) - 1]
    
    if re.match(firstWord, pattern):
        return (firstWord, input.replace(firstWord & " ", ""))
    
    if re.match(lastWord, pattern):
        return (lastWord, input.replace(" " & lastWord, ""))
    
    for word in seqInput:
        if re.match(word, pattern):
            return (word, input.replace(word & " ", ""))
    
    raise newException(ValueError, "Unable to parse time from the input")

proc main() =
    try:
        let opts = p.parse(commandLineParams())
        let input = opts.input.join(" ")
        let (timeString, description) = parseInput(input)
        let time = parseTime(timeString)


        let notif = Notification(
            description: description,
            time: time + now().toTime().toUnix(),
            urgency: if opts.important: 3 else: 2
        )

        let json = notificationToJson(notif)
        
        let name = ($getTime().toUnixFloat()).replace(".", "") & ".json"

        writeFile($activePath / name, pretty(json))


    except ShortCircuit as err:
        if err.flag == "argparse_help":
            echo err.help
            quit(1)
    except UsageError:
        stderr.writeLine getCurrentExceptionMsg()
        quit(1)

main()

