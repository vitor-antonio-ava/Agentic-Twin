# DIA Report Agent — Copilot Studio Instructions

## Agent Purpose

This agent guides the user through capturing 7 sections of a DIA (Decision Impact Assessment) report via
adaptive cards, collects mandatory and optional email recipients, generates a formatted HTML report,
and sends it by email using the Office 365 Outlook connector.

---

## Topic Flow Overview

```
Start
  │
  ├─ 1. Welcome Message
  ├─ 2. Capture Situation          → situationData
  ├─ 3. Capture Current Response   → currentResponseData
  ├─ 4. Capture Patient Impact     → patientImpactData
  ├─ 5. Capture Balanced Scorecard → balancedScorecardData
  ├─ 6. Capture DIA                → diaData
  ├─ 7. Capture Recommendation     → recommendationData
  ├─ 8. Capture Next Steps         → nextStepsData
  ├─ 9. Review Summary Card
  ├─10. Capture Recipients (Mandatory + Optional)
  ├─11. Build HTML Report (Power FX)
  ├─12. Send Email via Office 365 Connector
  └─ End
```

---

## Topic Variables

| Variable | Type | Description |
|---|---|---|
| `Topic.situationData` | Text | Content of the Situation section |
| `Topic.currentResponseData` | Text | Content of the Current Response section |
| `Topic.patientImpactData` | Text | Content of the Patient Impact section |
| `Topic.balancedScorecardData` | Text | Content of the Balanced Scorecard section |
| `Topic.diaData` | Text | Content of the DIA section |
| `Topic.recommendationData` | Text | Content of the Recommendation section |
| `Topic.nextStepsData` | Text | Content of the Next Steps section |
| `Topic.mandatoryRecipients` | Text | Comma-separated email addresses (mandatory) |
| `Topic.optionalRecipients` | Text | Comma-separated email addresses (optional) |
| `Topic.reportTitle` | Text | User-provided title for the DIA report |
| `Topic.htmlReport` | Text | Final assembled HTML string for the email body |

---

## Step-by-Step Topic Instructions

### Step 1 — Welcome Message

Send a message activity:

> "I'll help you create a DIA Report. We'll go through 7 sections step by step using simple forms.
> Let's start — please provide a title for this report."

Follow with a **Question node** (String entity) that captures into `Topic.reportTitle`.

---

### Step 2–8 — Adaptive Card for Each Section

For each section, use a **Send Adaptive Card** node with `waitForResponse: true`.
The card follows the same template — only the **title** and **variable** change per section.

#### Adaptive Card Template (Power FX — paste in "Edit formula" mode)

```
{
  type: "AdaptiveCard",
  '$schema': "https://adaptivecards.io/schemas/adaptive-card.json",
  version: "1.5",
  body: [
    {
      type: "TextBlock",
      text: "DIA Report",
      weight: "Bolder",
      size: "Small",
      color: "Accent",
      spacing: "None"
    },
    {
      type: "TextBlock",
      text: "<<SECTION_TITLE>>",
      weight: "Bolder",
      size: "Large",
      wrap: true,
      spacing: "Small"
    },
    {
      type: "TextBlock",
      text: "Please provide the content for this section.",
      wrap: true,
      isSubtle: true,
      spacing: "Small"
    },
    {
      type: "Input.Text",
      id: "sectionContent",
      placeholder: "Enter details here...",
      isMultiline: true,
      isRequired: true,
      errorMessage: "This field is required."
    }
  ],
  actions: [
    {
      type: "Action.Submit",
      title: "Next →"
    }
  ]
}
```

Replace `<<SECTION_TITLE>>` with the section name for each step:

| Step | Section Title | Output Variable |
|---|---|---|
| 2 | `Situation` | `Topic.situationData` |
| 3 | `Current Response` | `Topic.currentResponseData` |
| 4 | `Patient Impact` | `Topic.patientImpactData` |
| 5 | `Balanced Scorecard` | `Topic.balancedScorecardData` |
| 6 | `DIA` | `Topic.diaData` |
| 7 | `Recommendation` | `Topic.recommendationData` |
| 8 | `Next Steps` | `Topic.nextStepsData` |

After each card submission, use a **Set Variable** node:

```
Topic.<variableName> = =System.Activity.Value.sectionContent
```

---

### Step 9 — Review Summary Card

Send an Adaptive Card (no response needed) to let the user review all sections before sending.

```
{
  type: "AdaptiveCard",
  '$schema': "https://adaptivecards.io/schemas/adaptive-card.json",
  version: "1.5",
  body: [
    {
      type: "TextBlock",
      text: "DIA Report — Review",
      weight: "Bolder",
      size: "ExtraLarge",
      color: "Accent"
    },
    {
      type: "TextBlock",
      text: "Report Title: " & Topic.reportTitle,
      weight: "Bolder",
      wrap: true
    },
    {
      type: "TextBlock", text: "Situation", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.situationData, wrap: true, isSubtle: true
    },
    {
      type: "TextBlock", text: "Current Response", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.currentResponseData, wrap: true, isSubtle: true
    },
    {
      type: "TextBlock", text: "Patient Impact", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.patientImpactData, wrap: true, isSubtle: true
    },
    {
      type: "TextBlock", text: "Balanced Scorecard", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.balancedScorecardData, wrap: true, isSubtle: true
    },
    {
      type: "TextBlock", text: "DIA", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.diaData, wrap: true, isSubtle: true
    },
    {
      type: "TextBlock", text: "Recommendation", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.recommendationData, wrap: true, isSubtle: true
    },
    {
      type: "TextBlock", text: "Next Steps", weight: "Bolder", spacing: "Medium"
    },
    {
      type: "TextBlock", text: Topic.nextStepsData, wrap: true, isSubtle: true
    }
  ],
  actions: [
    {
      type: "Action.Submit",
      title: "Looks good — continue to recipients",
      data: { action: "confirm" }
    },
    {
      type: "Action.Submit",
      title: "Start over",
      data: { action: "restart" }
    }
  ]
}
```

After submission, check `System.Activity.Value.action`:
- If `"restart"` → redirect to Step 1
- If `"confirm"` → continue to Step 10

---

### Step 10 — Capture Recipients

Send an Adaptive Card to capture mandatory and optional email addresses.

```
{
  type: "AdaptiveCard",
  '$schema': "https://adaptivecards.io/schemas/adaptive-card.json",
  version: "1.5",
  body: [
    {
      type: "TextBlock",
      text: "Report Recipients",
      weight: "Bolder",
      size: "Large",
      color: "Accent"
    },
    {
      type: "TextBlock",
      text: "Enter email addresses separated by commas.",
      wrap: true,
      isSubtle: true
    },
    {
      type: "Input.Text",
      id: "mandatoryEmails",
      label: "Mandatory Recipients",
      placeholder: "name@example.com, name2@example.com",
      isMultiline: false,
      isRequired: true,
      errorMessage: "At least one mandatory recipient is required."
    },
    {
      type: "Input.Text",
      id: "optionalEmails",
      label: "Optional Recipients (CC)",
      placeholder: "name@example.com, name2@example.com",
      isMultiline: false,
      isRequired: false
    }
  ],
  actions: [
    {
      type: "Action.Submit",
      title: "Send Report"
    }
  ]
}
```

After submission, use **Set Variable** nodes:

```
Topic.mandatoryRecipients = =Trim(System.Activity.Value.mandatoryEmails)
Topic.optionalRecipients  = =Trim(System.Activity.Value.optionalEmails)
```

---

### Step 11 — Build the HTML Report (Power FX)

Use a **Set Variable** node to build `Topic.htmlReport`:

```powerfx
="<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<style>
  body { font-family: Calibri, Arial, sans-serif; color: #222; margin: 0; padding: 0; }
  .header { background-color: #E8004A; padding: 24px 32px; }
  .header h1 { color: white; margin: 0; font-size: 24px; }
  .header p { color: #f9d0df; margin: 6px 0 0 0; font-size: 14px; }
  .content { padding: 24px 32px; }
  .section { margin-bottom: 28px; border-left: 4px solid #E8004A; padding-left: 16px; }
  .section h2 { font-size: 16px; color: #E8004A; margin: 0 0 8px 0; text-transform: uppercase; letter-spacing: 0.5px; }
  .section p { font-size: 14px; line-height: 1.6; margin: 0; white-space: pre-wrap; }
  .footer { background-color: #f5f5f5; padding: 16px 32px; font-size: 12px; color: #888; }
</style>
</head>
<body>
<div class='header'>
  <h1>" & Topic.reportTitle & "</h1>
  <p>Decision Impact Assessment &nbsp;|&nbsp; Generated on " & Text(Today(), "DD MMMM YYYY") & "</p>
</div>
<div class='content'>

  <div class='section'>
    <h2>1. Situation</h2>
    <p>" & Topic.situationData & "</p>
  </div>

  <div class='section'>
    <h2>2. Current Response</h2>
    <p>" & Topic.currentResponseData & "</p>
  </div>

  <div class='section'>
    <h2>3. Patient Impact</h2>
    <p>" & Topic.patientImpactData & "</p>
  </div>

  <div class='section'>
    <h2>4. Balanced Scorecard</h2>
    <p>" & Topic.balancedScorecardData & "</p>
  </div>

  <div class='section'>
    <h2>5. DIA</h2>
    <p>" & Topic.diaData & "</p>
  </div>

  <div class='section'>
    <h2>6. Recommendation</h2>
    <p>" & Topic.recommendationData & "</p>
  </div>

  <div class='section'>
    <h2>7. Next Steps</h2>
    <p>" & Topic.nextStepsData & "</p>
  </div>

</div>
<div class='footer'>
  This report was generated by the DIA Report Agent. Please do not reply to this email.
</div>
</body>
</html>"
```

---

### Step 12 — Send Email via Office 365 Connector

Use the **Office 365 Outlook — Send an email (V2)** connector action.

| Field | Value |
|---|---|
| **To** | `=Topic.mandatoryRecipients` |
| **CC** | `=Topic.optionalRecipients` |
| **Subject** | `="DIA Report: " & Topic.reportTitle` |
| **Body** | `=Topic.htmlReport` |
| **Is HTML** | `true` |

> **Note:** The "To" field in the connector accepts a semicolon-separated list.
> If your `mandatoryRecipients` variable uses commas, convert it first:
>
> ```powerfx
> Substitute(Topic.mandatoryRecipients, ",", ";")
> ```

---

### Step 13 — Confirmation Message

Send a final message activity:

> "✅ Your DIA Report **{Topic.reportTitle}** has been sent successfully to the selected recipients."

---

## Error Handling — Recommended Condition Checks

Add the following condition checks before Step 12:

1. **Mandatory recipients not empty:**
   ```
   Condition: =IsBlank(Topic.mandatoryRecipients)
   → True path: Send message "Please provide at least one mandatory recipient." → Loop back to Step 10
   ```

2. **AI-generated content review (optional):**
   Before sending, optionally pass the assembled sections through a **Generative Answers** node
   or an **AI Builder prompt** to clean up / summarise content per section.

---

## Optional Enhancement — Use People Picker for Recipients

Instead of free-text email input, replace the recipients card with a People Picker input
(uses Microsoft Graph `graph.microsoft.com/users` dataset):

```
{
  type: "Input.ChoiceSet",
  id: "mandatoryEmails",
  label: "Mandatory Recipients",
  style: "filtered",
  isMultiSelect: true,
  placeholder: "Search for people...",
  choices: [],
  "choices.data": {
    type: "Data.Query",
    dataset: "graph.microsoft.com/users"
  }
}
```

When using People Picker, the submitted value is a semicolon-separated list of UPNs (emails),
so no `Substitute` conversion is needed for the connector.

---

## Summary of Data Flow

```
User fills Adaptive Cards (x7 sections)
        ↓
Variables: situationData ... nextStepsData
        ↓
User fills Recipients Card
        ↓
Variables: mandatoryRecipients, optionalRecipients
        ↓
Power FX builds Topic.htmlReport (HTML string)
        ↓
Office 365 Connector: Send Email (To, CC, Subject, HTML Body)
        ↓
Confirmation message to user
```
