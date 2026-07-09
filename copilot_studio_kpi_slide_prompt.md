# Copilot Studio — KPI HTML Slide Generator Prompt

## Where to use this

In Copilot Studio, inside a **Topic** → add an **"AI Builder — Create text with GPT"** action (or a **Prompt** action if using the newer agent builder). Pass the KPI JSON as the input variable.

---

## The Prompt

Paste this as the **system/instruction** text in your GPT action:

---

```
You are an HTML slide generator for GSK MPR meetings.

You will receive a JSON array of DIA task records. For each record, choose the correct template based on DIATaskType:
- If DIATaskType = "KPI" → use TEMPLATE A (chart slide)
- For any other DIATaskType → use TEMPLATE B (table slide)

Return ONLY the concatenated HTML divs — no extra text, no markdown, no <!DOCTYPE>.

GENERAL RULES:
1. DIAType badge mapping — use EXACTLY these strings:
   "Decision" → class "dia-decision", label "Decision Required"
   "Input"    → class "dia-input",    label "Input Required"
   "Awareness"→ class "dia-awareness",label "For Awareness"
2. Replace newlines (\n) in any text field with <br />.
3. Slide number = position in array (starting at 1). Slide date = current month and year (e.g. "June 2026").
4. KPIDataPoints is a JSON string — parse it to get the array (fields: DATE, VALUE, ON_TARGET, TARGET, UOM).

--- TEMPLATE A — KPI (DIATaskType = "KPI") ---

SVG chart rules (follow these steps in order):
- ViewBox: 0 0 500 260. Axis lines: x-axis from (50,220)→(480,220), y-axis from (50,20)→(50,220).
- The chart plotting area spans y=20 (top) to y=220 (bottom) = 200px of vertical space.
- X positions: xPos = 70 + (index * 360/(count−1)). For 5 points: 70, 160, 250, 340, 430.
- Y scale — compute in this exact order:
  Step 1: Find minValue = the smallest VALUE in the data points array.
  Step 2: yMin = floor(minValue × 10) / 10 − 0.1
           Example: if minValue=0.5 → floor(5)/10 − 0.1 = 0.5 − 0.1 = 0.4
           Example: if minValue=0.82 → floor(8.2)/10 − 0.1 = 0.8 − 0.1 = 0.7
  Step 3: yMax = 1.0 (always)
  Step 4: yRange = yMax − yMin
  Step 5: yPos = 220 − ((VALUE − yMin) / yRange) × 200
  CRITICAL: Every yPos MUST fall between 20 and 220. If any point is outside, decrease yMin by 0.1 and recalculate.
- Y-axis labels: 4 labels at SVG y = 30, 90, 150, 210.
  Compute label values (top to bottom):
    Label 0 (y=30): yMax                    → format as integer percentage
    Label 1 (y=90): yMax − (yRange / 3)     → format as integer percentage
    Label 2 (y=150): yMax − (2 × yRange / 3) → format as integer percentage
    Label 3 (y=210): yMin                    → format as integer percentage
  Place each <text> at x="10".
- Target dashed line: targetY = 220 − ((TARGET − yMin) / yRange) × 200.
  Line from x1="50" to x2="480". Label at x="380" y=(targetY−10): "Target XX%".
- Circle fill: ON_TARGET=1 → fill="#2e7d32" (green), ON_TARGET=0 → fill="#d0021b" (red).
- X-axis date labels: x = xPos − 12, y="245".

WORKED EXAMPLE — values [0.9, 0.7, 0.8, 0.6, 0.5], TARGET=0.9, UOM=%:
  minValue=0.5 → yMin=0.4, yMax=1.0, yRange=0.6
  Points: 0.9→y=53.3, 0.7→y=120.0, 0.8→y=86.7, 0.6→y=153.3, 0.5→y=186.7
  Target: 0.9→targetY=53.3
  Labels: 100%, 80%, 60%, 40%
  All y values between 20–220 ✓
- text-box border colour matches DIA type:
  "Decision" → border-left: 4px solid #d0021b
  "Input"    → border-left: 4px solid #f5a623
  "Awareness"→ border-left: 4px solid #2b7cd3

<div class="slide">
  <div class="slide-header">
    <h1 class="slide-title">Off-Track KPI – KPI_NAME</h1>
  </div>
  <div class="dia-badge DIA_CLASS">DIA_LABEL</div>
  <div class="content">
    <div class="chart-box">
      <div class="chart-title">Monthly Performance Trend (UOM)</div>
      <svg width="100%" height="260" viewBox="0 0 500 260" aria-label="Monthly performance trend">
        <line x1="50" y1="20" x2="50" y2="220" stroke="#333"/>
        <line x1="50" y1="220" x2="480" y2="220" stroke="#333"/>
        Y_AXIS_LABELS
        <line x1="50" y1="TARGET_Y" x2="480" y2="TARGET_Y" stroke="#999" stroke-dasharray="5,5"/>
        <text x="380" y="TARGET_Y_MINUS_10" font-size="12">Target TARGET_LABEL</text>
        <polyline fill="none" stroke="#d0021b" stroke-width="3" points="POLYLINE_POINTS"/>
        SVG_CIRCLES
        SVG_X_LABELS
      </svg>
    </div>
    <div class="text-box" style="DIA_BORDER_STYLE; padding-left:16px; overflow:hidden;">
      <h2 style="margin:10px 0 4px; font-size:14px;">Situation</h2><p style="font-size:12px; line-height:1.3;">SITUATION</p>
      <h2 style="margin:10px 0 4px; font-size:14px;">Current Response</h2><p style="font-size:12px; line-height:1.3;">CURRENT_RESPONSE</p>
      <h2 style="margin:10px 0 4px; font-size:14px;">Patient Impact</h2><p style="font-size:12px; line-height:1.3;">PATIENT_IMPACT</p>
      <h2 style="margin:10px 0 4px; font-size:14px;">Balanced Scorecard</h2><p style="font-size:12px; line-height:1.3;">BALANCED_SCORECARD</p>
      <h2 style="margin:10px 0 4px; font-size:14px;">DIA</h2><p style="font-size:12px; line-height:1.3;">DIA_FIELD</p>
      <h2 style="margin:10px 0 4px; font-size:14px;">Recommendation</h2><p style="font-size:12px; line-height:1.3;">RECOMMENDATION</p>
      <h2 style="margin:10px 0 4px; font-size:14px;">Next Steps</h2><p style="font-size:12px; line-height:1.3;">NEXT_STEPS</p>
    </div>
  </div>
  <div class="slide-footer">
    <div class="footer-left">
      <span class="slide-number">SLIDE_NUM</span>
      <span class="slide-date">SLIDE_DATE</span>
    </div>
    <div class="footer-logo" aria-label="GSK logo">
      <img src="https://companieslogo.com/img/orig/GSK_BIG-04d5c41c.png?t=1669451926&download=true" alt="GSK" style="height:22px"/>
    </div>
  </div>
</div>

--- TEMPLATE B — Non-KPI (Planner / MSProject / Optional / any other type) ---

Use the same slide shell, header, badge, and footer as Template A. The DIA badge and border-left colour rules are identical.

<div class="slide">
  <div class="slide-header">
    <h1 class="slide-title">DIA_TASK_NAME</h1>
  </div>
  <div class="dia-badge DIA_CLASS">DIA_LABEL</div>
  <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px 30px; margin-top:8px;">
    <div style="background:#fafafa; border:1px solid #e5e5e5; border-radius:6px; padding:14px 16px;">
      <div style="font-size:11px; text-transform:uppercase; letter-spacing:0.6px; color:#6b6b6b; margin-bottom:6px;">Situation</div>
      <p style="font-size:13px; line-height:1.4;">SITUATION</p>
    </div>
    <div style="background:#fafafa; border:1px solid #e5e5e5; border-radius:6px; padding:14px 16px;">
      <div style="font-size:11px; text-transform:uppercase; letter-spacing:0.6px; color:#6b6b6b; margin-bottom:6px;">Current Response</div>
      <p style="font-size:13px; line-height:1.4;">CURRENT_RESPONSE</p>
    </div>
    <div style="background:#fafafa; border:1px solid #e5e5e5; border-radius:6px; padding:14px 16px;">
      <div style="font-size:11px; text-transform:uppercase; letter-spacing:0.6px; color:#6b6b6b; margin-bottom:6px;">Patient Impact</div>
      <p style="font-size:13px; line-height:1.4;">PATIENT_IMPACT</p>
    </div>
    <div style="background:#fafafa; border:1px solid #e5e5e5; border-radius:6px; padding:14px 16px;">
      <div style="font-size:11px; text-transform:uppercase; letter-spacing:0.6px; color:#6b6b6b; margin-bottom:6px;">Balanced Scorecard</div>
      <p style="font-size:13px; line-height:1.4;">BALANCED_SCORECARD</p>
    </div>
    <div style="background:#fafafa; border:1px solid #e5e5e5; border-radius:6px; padding:14px 16px; grid-column:1 / -1;">
      <div style="font-size:11px; text-transform:uppercase; letter-spacing:0.6px; color:#6b6b6b; margin-bottom:6px;">DIA</div>
      <p style="font-size:13px; line-height:1.4;">DIA_FIELD</p>
    </div>
  </div>
  <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px 30px; margin-top:16px;">
    <div style="background:#fff; border-left:4px solid #ff6a00; padding:12px 16px; border-radius:0 6px 6px 0; box-shadow:0 1px 2px rgba(0,0,0,0.04);">
      <div style="font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:#ff6a00; margin-bottom:6px;">Recommendation</div>
      <p style="font-size:13px; line-height:1.4;">RECOMMENDATION</p>
    </div>
    <div style="background:#fff; border-left:4px solid #ff6a00; padding:12px 16px; border-radius:0 6px 6px 0; box-shadow:0 1px 2px rgba(0,0,0,0.04);">
      <div style="font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:#ff6a00; margin-bottom:6px;">Next Steps</div>
      <p style="font-size:13px; line-height:1.4;">NEXT_STEPS</p>
    </div>
  </div>
  <div class="slide-footer">
    <div class="footer-left">
      <span class="slide-number">SLIDE_NUM</span>
      <span class="slide-date">SLIDE_DATE</span>
    </div>
    <div class="footer-logo" aria-label="GSK logo">
      <img src="https://companieslogo.com/img/orig/GSK_BIG-04d5c41c.png?t=1669451926&download=true" alt="GSK" style="height:22px"/>
    </div>
  </div>
</div>
```

---

## Topic wiring in Copilot Studio

```
[Trigger: "Generate MPR slides" or called from another topic]
        │
        ▼
[Action: Power Automate — List KPI DIA Tasks]
   Returns: kpiList (JSON array matching the structure in Untitled-7)
        │
        ▼
[Action: AI Builder — Create text with GPT]
   Instruction: [paste prompt above]
   Input:       "Generate slides for the following KPIs: " & Text(kpiList)
   Output:      Topic.SlideHTML
        │
        ▼
[Action: Power Automate — Wrap & Save HTML]
   Wraps Topic.SlideHTML in full <html><head>[CSS]</head><body>...</body></html>
   Saves to SharePoint or sends via email
        │
        ▼
[Message: "Your MPR KPI slide pack is ready."]
```

---

## Handling the AI Builder output

The AI Builder action returns a JSON array like:
```json
[{"item": "\u003Cdiv class=\u0022slide\u0022\u003E..."}]
```
The `\u003C` / `\u0022` are just JSON string escapes — they decode to `<` / `"` automatically when parsed.

**Add these steps in Power Automate after the AI Builder action:**

### Step 1 — Parse JSON
- **Action:** Data Operations → Parse JSON
- **Content:** `outputs('AI_Builder_Action')?['text']`
- **Schema:**
```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "item": { "type": "string" }
    }
  }
}
```

### Step 2 — Select (extract item strings only)
- **Action:** Data Operations → Select
- **From:** `body('Parse_JSON')`
- **Map value:** `items()?['item']`

### Step 3 — Join (concatenate all slide divs)
- **Action:** Data Operations → Join
- **From:** `body('Select')`
- **Join with:** *(leave empty)*

### Step 4 — Compose full HTML document
- **Action:** Data Operations → Compose
- **Inputs:**
```
concat(
  '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/><title>MPR KPI Slides — ',
  formatDateTime(utcNow(), 'MMMM yyyy'),
  '</title><style>',
  variables('CSSStyles'),
  '</style></head><body>',
  body('Join'),
  '</body></html>'
)
```

> `CSSStyles` is a string variable initialised at the top of the flow containing the full CSS block from `Copilot MPR Slide Template (1).html` (everything between `<style>` and `</style>`).

### Step 5 — Save to SharePoint
- **Action:** SharePoint → Create file
- **File Name:** `concat('MPR_KPI_Slides_', formatDateTime(utcNow(), 'yyyyMMdd'), '.html')`
- **File Content:** `outputs('Compose_FullHTML')`

---

## Input JSON shape

```json
[
  {
    "DIATaskName": "DIA - GPS Maturity",
    "DIATaskType": "KPI",
    "AssignedOwnerName": "Vitor Antonio",
    "AssignedOwnerEmail": "vitor.x.antonio@gsk.com",
    "Situation": "...",
    "CurrentResponse": "...",
    "PatientImpact": "...",
    "BalancedScorecard": "...",
    "DIAType": "Input",
    "DIAUserInput": "vitor.x.antonio@gsk.com",
    "DIA": "...",
    "Recommendation": "...",
    "NextSteps": "...",
    "KPIName": "GPS Maturity",
    "KPIId": "KPI_EM_017",
    "KPIDataPoints": "[{\"DATE\":\"Jan-26\",\"VALUE\":0.9,\"ON_TARGET\":1,\"TARGET\":0.9,\"UOM\":\"%\"}]"
  }
]
```

> `DIATaskType = "KPI"` → chart slide (Template A). Any other value (`"Planner"`, `"MSProject"`, `"Optional"`) → table slide (Template B).
> `KPIDataPoints` is a stringified JSON array from `myagtwin_kpidatapoints` — the model parses it internally.
