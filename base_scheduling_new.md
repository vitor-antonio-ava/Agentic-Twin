kind: AdaptiveDialog
beginDialog:
  kind: OnRedirect
  id: main
  actions:
    - kind: SetVariable
      id: setVariable_e4UqAC
      displayName: Set local meetingPayload
      variable: Topic.schedulingMeetingPayload
      value: |-
        =If(
            !IsBlank(Global.SummaryJSON),
            Trim(Substitute(Substitute(Global.SummaryJSON, "```json", "" ), "```","" )),
            JSON({
                meta: {
                    runId: "RUN_20250206_153000",
                    sourceType: "Transcript",
                    generatedBy: "SummaryAgent"
                },
                meeting: {
                    meetingTitle: "Quality Council Meeting",
                    transcriptMeetingDate: "11 February 2026, 14:30",
                    timeZone: "Central European Time",
                    teamsMeetingLink: ""
                },
                summary: {
                    format: "HTML",
                    htmlContent: "<h1>Quality Council Meeting Summary</h1>\n<h2>Top 3 Problems Identified</h2>\n<ul>\n<li>High number of overdue effectiveness checks and long-term actions.</li>\n<li>Repeated deviations due to human factors and knowledge gaps in processes.</li>\n<li>Resource constraints impacting timely completion of actions and commissioning of M building.</li>\n</ul>\n<h2>Key actions</h2>\n<ul>\n<li>Follow up on overdue long-term actions and effectiveness checks.</li>\n<li>Formalize operator process knowledge sessions and address knowledge gaps.</li>\n<li>Track and close QIP actions for OSD for 2026.</li>\n<li>Address ongoing DI deviations and data integrity issues.</li>\n<li>Plan periodic reviews 3 months in advance to prevent delays.</li>\n<li>Escalate need for long-term solution for temporary instructions.</li>\n</ul>\n<h2>Decisions Made</h2>\n<ul>\n<li>Keep high number of overdue effectiveness checks as a priority.</li>\n<li>Escalate TI (Temporary Instructions) issue for long-term solution.</li>\n<li>Continue planning for periodic reviews and formalize knowledge sessions.</li>\n<li>Maintain focus on reducing TI count for M2.</li>\n</ul>\n<h2>Escalations Required</h2>\n<ul>\n<li>Escalate TI issue through Psychology Council for alternative solutions.</li>\n<li>Escalate resource constraints for M building commissioning.</li>\n<li>Escalate long-term solution for temporary instructions to central quality.</li>\n</ul>\n<h2>Suggestions for Process Confirmations for Next Month</h2>\n<ul>\n<li>Confirm progress on overdue long-term actions and effectiveness checks.</li>\n<li>Validate implementation of knowledge sessions and training plans.</li>\n<li>Review status of QIP actions and DI deviation resolutions.</li>\n<li>Monitor resource allocation for M building and related projects.</li>\n</ul>\n<h2>Communications to cascade to team</h2>\n<ul>\n<li>Emphasize importance of timely closure of long-term actions and effectiveness checks.</li>\n<li>Share updates on escalation of TI issues and resource constraints.</li>\n<li>Communicate upcoming periodic review plans and training requirements.</li>\n<li>Reinforce adherence to process to avoid deviations and repeats.</li>\n</ul>\n<h2>Actions</h2>\n<table border='1'>\n<tr><th>Action</th><th>Owner</th><th>Due Date</th><th>Status</th></tr>\n<tr><td>Follow up on overdue long-term actions</td><td>Nuwandi</td><td>End of December</td><td>Ongoing</td></tr>\n<tr><td>Formalize operator process knowledge sessions</td><td>Nuwandi</td><td>Not specified</td><td>New</td></tr>\n<tr><td>Track QIP actions for OSD for 2026</td><td>Nuwandi</td><td>2026</td><td>Ongoing</td></tr>\n<tr><td>Catch up on ongoing DI deviations</td><td>Nuwandi & Chris</td><td>Not specified</td><td>New</td></tr>\n<tr><td>Plan periodic reviews 3 months in advance</td><td>Nuwandi</td><td>Starting December</td><td>Ongoing</td></tr>\n<tr><td>Escalate TI issue for long-term solution</td><td>Nuwandi</td><td>January onwards</td><td>New</td></tr>\n<tr><td>Address resource constraints for M building commissioning</td><td>Mattia</td><td>January onwards</td><td>New</td></tr>\n<tr><td>Review and close overdue SAP for engineering</td><td>Charlie</td><td>Not specified</td><td>Ongoing</td></tr>\n<tr><td>Implement signage and software changes for visual aid gaps</td><td>Engineering</td><td>Interim + Long-term</td><td>Ongoing</td></tr>\n<tr><td>Ensure compliance with validation for ECC changes</td><td>Engineering</td><td>Not specified</td><td>Ongoing</td></tr>\n</table>",
                    approvedByUser: true
                },
                actions: [
                    {
                    actionId: "",
                    title: "Follow up on overdue long-term actions",
                    description: "",
                    ownerDisplayName: "Nuwandi",
                    ownerEmail: "",
                    ownerObjectId: "",
                    dueDate: "End of December",
                    priority: "Medium",
                    status: "Ongoing",
                    source: "Ongoing",
                    resolutionStatus: "Unresolved"
                    },
                    {
                    actionId: "",
                    title: "Formalize operator process knowledge sessions",
                    description: "",
                    ownerDisplayName: "Nuwandi",
                    ownerEmail: "",
                    ownerObjectId: "",
                    dueDate: "",
                    priority: "Medium",
                    status: "New",
                    source: "New",
                    resolutionStatus: "Unresolved"
                    }
                ]
            })
        )

    - kind: SetVariable
      id: setVariable_VCsvtD
      variable: Global.meetingPayload
      value: =Topic.schedulingMeetingPayload

    - kind: SetMultipleVariables
      id: setVariable_tKud50
      assignments:
        - variable: Global.schedulingAgentPassedTranscriptDateTime
          value: =ParseJSON(Global.meetingPayload).meeting.transcriptMeetingDate

        - variable: Global.schedulingAgentPassedTranscriptMeetingTitle
          value: =ParseJSON(Global.meetingPayload).meeting.meetingTitle

    - kind: ConditionGroup
      id: conditionGroup_J7EVr3
      conditions:
        - id: conditionItem_bVS2Ci
          condition: =Global.User_Intention_Choice = "Pre-read"
          actions:
            - kind: GotoAction
              id: xMBzNI
              actionId: 5NaZqb

    - kind: Question
      id: question_QZZIxT
      interruptionPolicy:
        allowInterruption: true

      variable: init:Topic.isMeetingScheduleAnswer
      prompt: |-
        {If(
        // Both title AND datetime must be present to offer the transcript option
        !IsBlank(Global.schedulingAgentPassedTranscriptMeetingTitle) && Global.schedulingAgentPassedTranscriptMeetingTitle <> "" &&
        !IsBlank(Global.schedulingAgentPassedTranscriptDateTime) && Global.schedulingAgentPassedTranscriptDateTime <> "",

        "I've detected the following meeting information from the transcript:" &
        "

        Meeting Title:  " & Global.schedulingAgentPassedTranscriptMeetingTitle &
        "

        Meeting Date & Time:  " & Global.schedulingAgentPassedTranscriptDateTime &
        "

        Would you like to use this information to schedule a follow-up meeting or send emails?",

        // Fallback: partial or no transcript data — inform user and proceed with standard flow
        "No meeting details were found.
        Would you like to search for an existing meeting or create a new meeting or email"
        )}
      entity:
        kind: EmbeddedEntity
        definition:
          kind: ClosedListEntity
          items:
            - id: Yes, search for the existing meeting
              displayName: Yes, search for the existing meeting

            - id: Create a new meeting
              displayName: Create a new meeting

    - kind: ConditionGroup
      id: conditionGroup_Rohueo
      conditions:
        - id: conditionItem_pTqTLO
          condition: =Topic.isMeetingScheduleAnswer = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_QZZIxT'.'Yes, search for the existing meeting'
          actions:
            - kind: ConditionGroup
              id: conditionGroup_N11uVz
              conditions:
                - id: conditionItem_9x2YdR
                  condition: =IsBlank(Global.schedulingAgentPassedTranscriptDateTime)
                  actions:
                    - kind: Question
                      id: question_IKTWII
                      interruptionPolicy:
                        allowInterruption: true

                      variable: init:Topic.userProvidedDateTime
                      prompt: Please provide the date and time of the existing meeting (i.e. 11 February 2026, 14:30)
                      entity: DateTimePrebuiltEntity

                    - kind: SetVariable
                      id: setVariable_BBobIM
                      variable: Global.schedulingAgentPassedTranscriptDateTime
                      value: =Text(Topic.userProvidedDateTime, "yyyy-mm-dd hh:mm:ss")

            - kind: BeginDialog
              id: pVQFC6
              input:
                binding:
                  providedMeetingTime: =Text(Global.schedulingAgentPassedTranscriptDateTime)

              dialog: copilots_header_a34f2.topic.scheduling_GetMeetingbyDateTime

            - kind: SetVariable
              id: setVariable_goNrsn
              variable: Topic.existingMeeting
              value: =JSON(Global.currentMeeting)

            - kind: SetMultipleVariables
              id: setVariable_LlhrH6
              assignments:
                - variable: Topic.meetingMandatoryAttendees
                  value: |-
                    =ParseJSON(Topic.existingMeeting).organizer & ", " &
                    ParseJSON(Topic.existingMeeting).requiredAttendees

                - variable: Topic.meetingOptionalAttendees
                  value: =ParseJSON(Topic.existingMeeting).optionalAttendees

            - kind: SetMultipleVariables
              id: setVariable_zbNWwp
              assignments:
                - variable: Global.currentMeeting.requiredAttendees
                  value: =Substitute(Topic.meetingMandatoryAttendees, ";", "")

                - variable: Global.currentMeeting.optionalAttendees
                  value: =Substitute(Topic.meetingOptionalAttendees, ";", "")

            - kind: Question
              id: question_txrOhA
              interruptionPolicy:
                allowInterruption: true

              variable: init:Topic.existingMeetingFollowUpDecision
              prompt: Would you like to schedule a follow up meeting or send email with meeting notes?
              entity:
                kind: EmbeddedEntity
                definition:
                  kind: ClosedListEntity
                  items:
                    - id: Schedule follow-up
                      displayName: Schedule follow-up

                    - id: Send email
                      displayName: Send email

            - kind: ConditionGroup
              id: conditionGroup_kAh5P3
              conditions:
                - id: conditionItem_Zs0PpF
                  condition: =Topic.existingMeetingFollowUpDecision = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_txrOhA'.'Schedule follow-up'
                  actions:
                    - kind: SetVariable
                      id: MpFmSc
                      variable: Global.schedulingAgentUserDesiredAction
                      value: SendInvite

                    - kind: GotoAction
                      id: 7i4MZB
                      actionId: FI7HEe

                - id: conditionItem_mzyGtw
                  condition: =Topic.existingMeetingFollowUpDecision = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_txrOhA'.'Send email'
                  actions:
                    - kind: SetVariable
                      id: setVariable_tqJuAA
                      variable: Global.schedulingAgentUserDesiredAction
                      value: SendEmail

                    - kind: Question
                      id: question_mSR2g2
                      interruptionPolicy:
                        allowInterruption: true

                      variable: init:Topic.Var1
                      prompt: |-
                        The current email subject is set to:
                        {Global.currentMeeting.subject}

                        Do you want to keep or change it?
                      entity:
                        kind: EmbeddedEntity
                        definition:
                          kind: ClosedListEntity
                          items:
                            - id: Keep
                              displayName: Keep

                            - id: Change
                              displayName: Change

                    - kind: ConditionGroup
                      id: conditionGroup_xGzkIX
                      conditions:
                        - id: conditionItem_IyMnB2
                          condition: =Topic.Var1 = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_mSR2g2'.Keep
                          actions:
                            - kind: SetVariable
                              id: setVariable_GMhc5F
                              variable: Global.userDesiredEmailSubject
                              value: =Global.currentMeeting.subject

                        - id: conditionItem_h60kMz
                          condition: =Topic.Var1 = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_mSR2g2'.Change
                          actions:
                            - kind: Question
                              id: question_WgHpRN
                              interruptionPolicy:
                                allowInterruption: true

                              variable: init:Topic.Var2
                              prompt: Please provide the email subject
                              entity: StringPrebuiltEntity

                            - kind: SetVariable
                              id: setVariable_paKubk
                              variable: Global.userDesiredEmailSubject
                              value: =Topic.Var2

            - kind: SendActivity
              id: sendActivity_jx671Y
              activity: |-
                Heres what I have on attendees:

                Mandatory:
                {Topic.meetingMandatoryAttendees}
                Optional:
                {Topic.meetingOptionalAttendees}

            - kind: Question
              id: question_0XZgWD
              interruptionPolicy:
                allowInterruption: true

              variable: init:Topic.userChangeAttendeesAnswer
              prompt: Do you want to make any changes to the attendees list?
              entity:
                kind: EmbeddedEntity
                definition:
                  kind: ClosedListEntity
                  items:
                    - id: I want to make changes
                      displayName: I want to make changes

                    - id: I don't want to make changes
                      displayName: I don't want to make changes

                displayName: EmbeddedEntity-EdghtM

            - kind: ConditionGroup
              id: conditionGroup_VJXTGU
              conditions:
                - id: conditionItem_52ntbb
                  condition: =Topic.userChangeAttendeesAnswer = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_0XZgWD'.'I want to make changes'
                  actions:
                    - kind: Question
                      id: question_EF8JwK
                      interruptionPolicy:
                        allowInterruption: true

                      variable: init:Topic.userAttendeesChangeRequest
                      prompt: |-
                        Tell me what to change.
                        For example:
                        ‘Move Sarah from optional to mandatory’ or ‘Remove John’ or ‘Add Ahmed as mandatory’.
                      entity: StringPrebuiltEntity

                    - kind: SearchAndSummarizeContent
                      id: GoDwuc
                      variable: Topic.changedAttendeesList
                      userInput: =Topic.userAttendeesChangeRequest
                      additionalInstructions: |-
                        Detect the names of the attendees from the user response stored in
                        {Topic.userAttendeesChangeRequest}

                        Return ONLY valid JSON in this format:

                        "message": "human readable response to show user",
                        "mandatory": ["email": "", "name": "", "email": "", "name": ""],
                        "optional": ["email": "", "name": "", "email": "", "name": ""]



                        Do not include explanations or additional text.
                      responseCaptureType: FullResponse

                    - kind: SetMultipleVariables
                      id: setVariable_SkgJ6g
                      assignments:
                        - variable: Topic.meetingMandatoryAttendees
                          value: =Text(ParseJSON(Topic.changedAttendeesList.Text.Content).mandatory)

                        - variable: Topic.meetingOptionalAttendees
                          value: =Text(ParseJSON(Topic.changedAttendeesList.Text.Content).optional)

                    - kind: GotoAction
                      id: NV66nU
                      actionId: sendActivity_jx671Y

                - id: conditionItem_tSufgh
                  condition: =Topic.userChangeAttendeesAnswer = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_0XZgWD'.'I don''t want to make changes'

            - kind: SetMultipleVariables
              id: setVariable_rTmnkP
              assignments:
                - variable: Global.currentMeeting.requiredAttendees
                  value: =Topic.meetingMandatoryAttendees

                - variable: Global.currentMeeting.optionalAttendees
                  value: =Topic.meetingOptionalAttendees

        - id: conditionItem_0RnUa5
          condition: =Topic.isMeetingScheduleAnswer = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.question_QZZIxT'.'Create a new meeting'
          actions:
            - kind: Question
              id: 5NaZqb
              interruptionPolicy:
                allowInterruption: true

              variable: Topic.userFollowUpDecision
              prompt: |-
                **How would you like to proceed?**
                Please select one of the options below.
              entity:
                kind: EmbeddedEntity
                definition:
                  kind: ClosedListEntity
                  items:
                    - id: Send meeting invite with summary
                      displayName: Send meeting invite with summary

                    - id: Send summary by email only
                      displayName: Send summary by email only

            - kind: ConditionGroup
              id: conditionGroup_Xq2gED
              conditions:
                - id: conditionItem_feQAp7
                  condition: =Topic.userFollowUpDecision = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.5NaZqb'.'Send meeting invite with summary'
                  actions:
                    - kind: Question
                      id: rOv0eQ
                      interruptionPolicy:
                        allowInterruption: true

                      variable: Global.userDesiredEmailSubject
                      prompt: Please provide the meeting title
                      entity:
                        kind: StringPrebuiltEntity
                        sensitivityLevel: None

                - id: conditionItem_mfUxuj
                  condition: =Topic.userFollowUpDecision = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.5NaZqb'.'Send summary by email only'
                  actions:
                    - kind: Question
                      id: coHkLO
                      interruptionPolicy:
                        allowInterruption: true

                      variable: Global.userDesiredEmailSubject
                      prompt: Please provide the email subject
                      entity:
                        kind: StringPrebuiltEntity
                        sensitivityLevel: None

            - kind: BeginDialog
              id: l0RDcO
              dialog: copilots_header_a34f2.topic.scheduling_HandleMeetingAttendees

            - kind: SetMultipleVariables
              id: setVariable_6xSGB5
              assignments:
                - variable: Global.currentMeeting.requiredAttendees
                  value: =Global.computedMandatoryAttendees

                - variable: Global.currentMeeting.optionalAttendees
                  value: =Global.computedOptionalAttendees

            - kind: ConditionGroup
              id: conditionGroup_3ud3zN
              conditions:
                - id: conditionItem_GZ6gA0
                  condition: =Topic.userFollowUpDecision = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.5NaZqb'.'Send meeting invite with summary'
                  actions:
                    - kind: BeginDialog
                      id: FI7HEe
                      dialog: copilots_header_a34f2.topic.scheduling_MeetingScheduler

                    - kind: SetVariable
                      id: setVariable_1ptdid
                      variable: Global.schedulingAgentUserDesiredAction
                      value: SendInvite

                - id: conditionItem_82N0uG
                  condition: =Topic.userFollowUpDecision = 'copilots_header_a34f2.topic.scheduling_BaseSchedulingAgent.main.5NaZqb'.'Send summary by email only'
                  actions:
                    - kind: SetMultipleVariables
                      id: setVariable_CBiVFf
                      assignments:
                        - variable: Global.currentMeeting.requiredAttendees
                          value: =Global.currentMeeting.requiredAttendees

                        - variable: Global.currentMeeting.optionalAttendees
                          value: |
                            =Global.currentMeeting.optionalAttendees

                    - kind: SendActivity
                      id: sendActivity_g48kjc
                      activity: |-
                        Mandatory:
                        {Global.currentMeeting.requiredAttendees}

                        Optional:
                        {Global.currentMeeting.optionalAttendees}

                    - kind: SetVariable
                      id: setVariable_k7YTFV
                      variable: Global.schedulingAgentUserDesiredAction
                      value: SendEmail

                    - kind: ConditionGroup
                      id: conditionGroup_gBGD6q
                      conditions:
                        - id: conditionItem_LPDfCd
                          condition: =!IsBlank(Global.userDesiredEmailSubject)
                          actions:
                            - kind: GotoAction
                              id: dpHHAl
                              actionId: sendActivity_BlfjCm

                    - kind: Question
                      id: question_fcK2Xm
                      interruptionPolicy:
                        allowInterruption: true

                      variable: init:Global.userDesiredEmailSubject
                      prompt: Please provide the email subject.
                      entity: StringPrebuiltEntity

                    - kind: SendActivity
                      id: sendActivity_BlfjCm
                      activity: Got it! Sending meeting summary notes to Action Agent.

    - kind: SetVariable
      id: setVariable_xXvz6j
      variable: Topic.schedulingAgentParsedPayload
      value: =ParseJSON(Global.meetingPayload)

    - kind: SetVariable
      id: setVariable_hBouZn
      variable: Topic.finalEmailSubject
      value: |-
        =If(
            Global.schedulingAgentUserDesiredAction = "SendEmail",
            If(
                !IsBlank(Global.userDesiredEmailSubject), 
                Global.userDesiredEmailSubject, 
                Global.currentMeeting.subject
            ),
            If(
                !IsBlank(Topic.schedulingAgentParsedPayload.meeting.meetingTitle), 
                Text(Topic.schedulingAgentParsedPayload.meeting.meetingTitle), 
                Global.currentMeeting.subject
            )
        )

    - kind: SetVariable
      id: setVariable_hmag6V
      variable: Global.meetingPayload
      value: |+
        =JSON(
            {
                meta: Topic.schedulingAgentParsedPayload.meta,
                meeting: {
                    title: If(!IsBlank(Global.currentMeeting.Value),
                        Text(Global.currentMeeting.Value),
                        Topic.finalEmailSubject),
                    dateTimeStart: Global.currentMeeting.start,
                    dateTimeEnd: Global.currentMeeting.end,
                    durationMinutes: DateDiff(
                        DateTimeValue(Global.currentMeeting.start),
                        DateTimeValue(Global.currentMeeting.end),
                        TimeUnit.Minutes
                    ),
                    timeZone: If(
                        !IsBlank(Topic.schedulingAgentParsedPayload.meeting.timeZone),
                        Topic.schedulingAgentParsedPayload.meeting.timeZone,
                        Global.currentMeeting.timeZone
                    ),
                    teamsMeetingLink: Global.currentMeeting.webLink
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
                    ),
                    lastValidatedByUser: true
                },
                summary: Topic.schedulingAgentParsedPayload.summary,
                publishing: {
                    activity: Global.schedulingAgentUserDesiredAction,
                    approvalStatus: "Approved",
                    emailSubject: If(
                        Global.schedulingAgentUserDesiredAction = "SendEmail",
                        Topic.finalEmailSubject,
                        If(!IsBlank(Global.currentMeeting.Value),
                        Text(Global.currentMeeting.Value),
                        Topic.schedulingAgentParsedPayload.meetingTitle)
                    )
                }
            }
        )

    - kind: ConditionGroup
      id: conditionGroup_WZQ8eN
      conditions:
        - id: conditionItem_yV4yoZ
          condition: =Global.schedulingAgentUserDesiredAction = "SendEmail"
          actions:
            - kind: SendActivity
              id: sendActivity_Ah3ns2
              activity:
                text:
                  - Do you want me to send this email now?
                quickReplies:
                  - kind: MessageBack
                    text: "\"Send Email\""

        - id: conditionItem_7FG6L6
          condition: =Global.schedulingAgentUserDesiredAction = "SendInvite"
          actions:
            - kind: SendActivity
              id: sendActivity_M4FAGj
              activity:
                text:
                  - |
                    Do you want me to send the invite for this meeting.
                quickReplies:
                  - kind: MessageBack
                    text: Send Invite

inputType: {}
outputType: {}