If(Find("hello", Text(Topic.JsonInput)) > 0, true, false )


IsMatch(Text(Topic.JsonInput), "follow-up|follow-up call|follow up meeting|another meeting|meeting", IgnoreCase)



With(
    { phrases: ["follow-up", "follow-up call", "follow up meeting", "another meeting", "meeting"] },
    CountIf(phrases, Search(Value, MyVar) > 0) > 0
)
``


Concatenate(Topic.varAttendees.email, ",")

ForAll(Topic.varAttendees, Topic.varAttendees.email)


IsMatch(
    Text(Topic.JsonInput),
    "\b(follow-?up( call| meeting)?|another meeting|meeting)\b",
    MatchOptions.IgnoreCase
)


vitor.x.antonio@gsk.com, ana.x.ocarizsanchez@gsk.com, dilawar.x.mansoori@gsk.com
vitor.x.antonio@gsk.com, ana.x.ocarizsanchez@gsk.com, Dilawar Mansoori

vitor.x.antonio@gsk.com, dilawar.x.mansoori@gsk.com
ana.x.ocarizsanchez@gsk.com

ForAll(
    ParseJSON(Topic.JsonInput).attendees.required,
    {
        email: Text(ThisRecord.email),
        name: Text(ThisRecord.name)
    }
)

Concat(
    Topic.varAttendeesTyped,
    email,
    ", "
)




Concat(
    ForAll(
    ParseJSON(Topic.JsonInput).attendees.required,
        {
            email: Text(ThisRecord.email),
            name: Text(ThisRecord.name)
        }
    ),
    email,
    ", "
)


Concat(
    ForAll(
        Topic.mandatoryAttendees,
        {
            email: Text(ThisRecord.email),
            name: Text(ThisRecord.name)
        }
    ),
    email,
    ", "
)



ForAll(
        ParseJSON(Topic.detectedAttendees).mandatoryNames,
        Text(ThisRecord)
)



If(
    !IsBlank(ParseJSON(Topic.generativeAnswer.Text.Content).mandatory),
    ParseJSON(Topic.generativeAnswer.Text.Content).mandatory,
    Topic.mandatoryAttendees
)


ParseJSON(Topic.generativeAnswer.Text.Content).mandatory


Concat(
    ForAll(Topic.mandatoryAttendees,
        {
            email: Text(ThisRecord.email),
            name: Text(ThisRecord.name)
        }
    ),
    email,
    ", "
)



items('Apply_to_each')?['meetingTimeSlot']?['end']?['dateTime']
items('Apply_to_each')?['meetingTimeSlot']?['start']?['dateTime']

{
  meta: Topic.schedulingAgentParsedPayload.meta,
  meeting: {
    title: Global.currentMeeting.subject,
    dateTimeStart: Global.currentMeeting.start,
    durationMinutes: DateDiff(
        DateTimeValue(Global.currentMeeting.start),
        DateTimeValue(Global.currentMeeting.end),
        TimeUnit.Minutes
    ),
    timeZone: DateTimeFormat.UTC
  },
  attendees: {
    mandatory: [
      {
        email: "new.user@xxx.com"
      }
    ],
    optional: []
  },
  summary: Topic.schedulingAgentParsedPayload.summary,
  publishing: Topic.schedulingAgentParsedPayload.publishing
}


{
  meta: Topic.schedulingAgentParsedPayload.meta,
  meeting: {
    title: Global.currentMeeting.subject,
    dateTimeStart: Global.currentMeeting.start,
    dateTimeEnd: Global.currentMeeting.end,
    durationMinutes: DateDiff(
        DateTimeValue(Global.currentMeeting.start),
        DateTimeValue(Global.currentMeeting.end),
        TimeUnit.Minutes
    ),
    timeZone: "UTC"
  },
  attendees: {
    mandatory: ForAll(
        Split(Global.currentMeeting.requiredAttendees, ","),
        { email: Trim(Value) }
    ),
    optional: If(
        IsBlank(Global.currentMeeting.optionalAttendees),
        [],
        ForAll(
            Split(Global.currentMeeting.optionalAttendees, ","),
            { email: Trim(Value) }
        )
    )
  },
  summary: Topic.schedulingAgentParsedPayload.summary,
  publishing: Topic.schedulingAgentParsedPayload.publishing
}


items('Apply_to_each')?['meetingTimeSlot']?['start']?['dateTime']


outputs('Get_my_profile_(V2)')?['body/mailboxSettings']?['timeZone']


ForAll(
        ParseJSON(Topic.detectedAttendees).mandatoryNames,
        Text(ThisRecord)
)

ForAll(
        ParseJSON(Topic.detectedAttendees).mandatoryNames,
        Text(ThisRecord)
)





userEmailsFound
isOptionalMultipleEmails

optionalUsersEmailsFound
isOptionalMultipleEmails


optionalEmailsFound
isMultipleOptionalEmails


ParseJSON(Topic.computedAttendeesList.Text.Content).mandatory
ParseJSON(Topic.computedAttendeesList.Text.Content).optional

