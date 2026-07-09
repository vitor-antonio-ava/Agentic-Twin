# Power Automate: KPI Slide Generation (Slide 4 Pattern)

## Overview

This flow generates an HTML `<div class="slide">` block matching the Slide 4 pattern for **every off-track KPI** in the DIA Tasks Dataverse table. The output is assembled into a full HTML file and saved/sent via SharePoint/email.

---

## 1. Data Sources → Slide 4 Component Mapping

### Text Content (from Dataverse DIA Task)

| Slide Section         | Dataverse Field Expression                          |
|-----------------------|-----------------------------------------------------|
| Slide title           | `myagtwin_kpiname`                                  |
| DIA badge class       | Computed → see Step 6                               |
| Chart title unit      | From graph points `UOM` field (first item)          |
| Situation             | `myagtwin_situation`                                |
| Current Response      | `myagtwin_currentresponse`                          |
| Patient Impact        | `myagtwin_patient`                                  |
| DIA                   | `myagtwin_dia`                                      |
| Recommendation        | `myagtwin_recommendation`                           |
| Next Steps            | `myagtwin_nextsteps`                                |
| Slide date            | `formatDateTime(utcNow(), 'MMMM yyyy')`             |

### SVG Chart (from Graph Points JSON)

Each item in `graph_points_example.json` maps to:

| JSON Field  | Usage                                              |
|-------------|----------------------------------------------------|
| `DATE`      | X-axis label text (e.g. "Jan-26")                  |
| `VALUE`     | Y coordinate of data point (decimal, 0.9 = 90%)   |
| `ON_TARGET` | Circle fill colour (1 = green `#2e7d32`, 0 = red `#d0021b`) |
| `TARGET`    | Dashed target line Y position (first item only)   |
| `UOM`       | Chart subtitle unit label (first item only)       |

---

## 2. SVG Coordinate System

**ViewBox**: `0 0 500 260`  
**Plot area**: x = 50 → 480, y = 20 → 220  
**First data point x**: 70, **Last data point x**: 430  

### Dynamic Y Scale (adapts to any data range)

Compute once before the loop:

```
yMin  = min(all VALUES) - 0.05        ← rounds slightly below lowest value
yMax  = 1.0                           ← fixed 100% ceiling
yRange = yMax - yMin
```

**Y coordinate formula per data point:**
```
yPos = 220 - ((VALUE - yMin) / yRange) * 200
```

PA expression (inside Apply to Each — Graph Points):
```
sub(220, mul(div(sub(float(items('Apply_to_each_GraphPoints')?['VALUE']), variables('yMin')), variables('yRange')), 200))
```

**Target dashed line Y** (compute once from first graph point):
```
targetY = 220 - ((TARGET - yMin) / yRange) * 200
```

PA expression:
```
sub(220, mul(div(sub(float(first(body('Parse_GraphPoints'))?['TARGET']), variables('yMin')), variables('yRange')), 200))
```

### Dynamic X Spacing (adapts to any number of points)

```
xSpacing = 360 / max(pointCount - 1, 1)
xPos     = 70 + (pointIndex * xSpacing)
```

PA expression for xPos (using a counter variable `pointIndex`):
```
add(70, mul(variables('pointIndex'), variables('xSpacing')))
```

---

## 3. Flow Steps

```
[Trigger]
    │
    ▼
[List Rows — Dataverse: DIA Tasks, filter: myagtwin_tasktype eq 1]
    │
    ▼
[Apply to each — KPI Task]   ←─── outer loop, one slide per KPI
    │
    ├── [HTTP / List Rows — get Graph Points for this KPI]
    │       Filter by: myagtwin_kpiid eq items()?['myagtwin_kpiid']
    │
    ├── [Parse JSON — Graph Points]
    │       Schema: { DATE: string, VALUE: number, ON_TARGET: integer, TARGET: number, UOM: string }
    │
    ├── [Select — extract VALUE column only]
    │       From: body('Parse_GraphPoints')
    │       Map: items()?['VALUE']
    │
    ├── [Initialize / Set Variables — scale + counters]
    │       See Step 4 below
    │
    ├── [Apply to each — Graph Points]   ←─── inner loop, builds SVG strings
    │       See Step 5 below
    │
    ├── [Compose — DIA Badge]
    │       See Step 6 below
    │
    ├── [Compose — Full Slide HTML]
    │       See Step 7 below — HTML Template
    │
    └── [Append to string variable — allSlides]
            concat(variables('allSlides'), outputs('Compose_SlideHTML'))

[Compose — Final Full HTML Document]
    └── Wrap allSlides in <html><head>...[CSS]...</head><body>...</body></html>

[Create file / Send email — SharePoint or Outlook]
```

---

## 4. Variable Initialisation (before inner loop)

Set these variables at the **start of each KPI task iteration**:

| Variable          | Type    | Initial Expression                                                                                   |
|-------------------|---------|------------------------------------------------------------------------------------------------------|
| `yMin`            | Float   | `sub(min(body('Select_Values')), 0.05)`                                                              |
| `yMax`            | Float   | `1.0`                                                                                                |
| `yRange`          | Float   | `sub(variables('yMax'), variables('yMin'))`                                                          |
| `pointCount`      | Integer | `length(body('Parse_GraphPoints'))`                                                                  |
| `xSpacing`        | Float   | `div(float(360), float(if(equals(variables('pointCount'), 1), 1, sub(variables('pointCount'), 1))))` |
| `targetY`         | Float   | `sub(220, mul(div(sub(float(first(body('Parse_GraphPoints'))?['TARGET']), variables('yMin')), variables('yRange')), 200))` |
| `targetLabel`     | String  | `concat(string(int(mul(first(body('Parse_GraphPoints'))?['TARGET'], 100))), first(body('Parse_GraphPoints'))?['UOM'])` |
| `svgPolyline`     | String  | `''` (empty)                                                                                         |
| `svgCircles`      | String  | `''` (empty)                                                                                         |
| `svgXLabels`      | String  | `''` (empty)                                                                                         |
| `pointIndex`      | Integer | `0`                                                                                                  |

---

## 5. Inner Loop — Build SVG Strings (Apply to Each Graph Points)

For each item in `body('Parse_GraphPoints')`:

### 5a — Compose xPos
```
add(70, mul(variables('pointIndex'), variables('xSpacing')))
```

### 5b — Compose yPos
```
sub(220, mul(div(sub(float(items('Apply_to_each_GraphPoints')?['VALUE']), variables('yMin')), variables('yRange')), 200))
```

### 5c — Compose pointColor
```
if(equals(items('Apply_to_each_GraphPoints')?['ON_TARGET'], 1), '#2e7d32', '#d0021b')
```

### 5d — Append to svgPolyline
```
concat(variables('svgPolyline'), string(outputs('Compose_xPos')), ',', string(outputs('Compose_yPos')), ' ')
```

### 5e — Append to svgCircles
```
concat(variables('svgCircles'),
  '<circle cx="', string(outputs('Compose_xPos')),
  '" cy="', string(outputs('Compose_yPos')),
  '" r="4" fill="', outputs('Compose_pointColor'), '" />')
```

### 5f — Append to svgXLabels
```
concat(variables('svgXLabels'),
  '<text x="', string(sub(outputs('Compose_xPos'), 12)),
  '" y="245" font-size="12">', items('Apply_to_each_GraphPoints')?['DATE'], '</text>')
```

### 5g — Increment pointIndex
```
add(variables('pointIndex'), 1)
```

> **Note:** PA's Apply to Each does not expose a native index. You must use the `pointIndex` integer variable and increment it manually at the **end** of each iteration.

---

## 6. Compose — DIA Badge

### Badge CSS class
```
if(
  equals(items('Apply_to_each_KPI')?['myagtwin_diatype'], 0), 'dia-decision',
  if(
    equals(items('Apply_to_each_KPI')?['myagtwin_diatype'], 1), 'dia-input',
    'dia-awareness'
  )
)
```

### Badge text
```
if(
  equals(items('Apply_to_each_KPI')?['myagtwin_diatype'], 0), 'Decision Required',
  if(
    equals(items('Apply_to_each_KPI')?['myagtwin_diatype'], 1), 'Input Required',
    'Awareness'
  )
)
```

---

## 7. HTML Template — Compose_SlideHTML

Paste the block below into a **Compose** action. Replace `@{...}` with actual PA expression references as noted.

```html
<div class="slide">
  <div class="slide-header">
    <h1 class="slide-title">Off-Track KPI – @{items('Apply_to_each_KPI')?['myagtwin_kpiname']}</h1>
  </div>

  <div class="dia-badge @{outputs('Compose_DiaBadgeClass')}">
    @{outputs('Compose_DiaBadgeText')}
  </div>

  <div class="content">
    <div class="chart-box">
      <div class="chart-title">
        Monthly Performance Trend (@{first(body('Parse_GraphPoints'))?['UOM']})
      </div>

      <svg width="100%" height="260" viewBox="0 0 500 260" aria-label="Monthly performance trend">

        <!-- Axes -->
        <line x1="50" y1="20" x2="50" y2="220" stroke="#333" />
        <line x1="50" y1="220" x2="480" y2="220" stroke="#333" />

        <!-- Y-axis labels: 4 evenly spaced value markers -->
        <text x="10" y="24"  font-size="12">@{concat(string(int(mul(variables('yMax'), 100))), '%')}</text>
        <text x="10" y="74"  font-size="12">@{concat(string(int(mul(add(variables('yMin'), mul(variables('yRange'), 0.75)), 100))), '%')}</text>
        <text x="10" y="124" font-size="12">@{concat(string(int(mul(add(variables('yMin'), mul(variables('yRange'), 0.5)), 100))), '%')}</text>
        <text x="10" y="174" font-size="12">@{concat(string(int(mul(add(variables('yMin'), mul(variables('yRange'), 0.25)), 100))), '%')}</text>

        <!-- Target dashed line -->
        <line
          x1="50"
          y1="@{string(int(variables('targetY')))}"
          x2="480"
          y2="@{string(int(variables('targetY')))}"
          stroke="#999"
          stroke-dasharray="5,5"
        />
        <text
          x="390"
          y="@{string(sub(int(variables('targetY')), 6))}"
          font-size="12">Target @{variables('targetLabel')}</text>

        <!-- Performance polyline -->
        <polyline
          fill="none"
          stroke="#d0021b"
          stroke-width="3"
          points="@{variables('svgPolyline')}"
        />

        <!-- Individual data point circles (green = on target, red = off target) -->
        @{variables('svgCircles')}

        <!-- X-axis date labels -->
        @{variables('svgXLabels')}

      </svg>
    </div>

    <div class="text-box">
      <h2>Situation</h2>
      <p>@{items('Apply_to_each_KPI')?['myagtwin_situation']}</p>

      <h2>Current Response</h2>
      <p>@{items('Apply_to_each_KPI')?['myagtwin_currentresponse']}</p>

      <h2>Patient Impact</h2>
      <p>@{items('Apply_to_each_KPI')?['myagtwin_patient']}</p>

      <h2>Balance Scorecard</h2>
      <p>@{items('Apply_to_each_KPI')?['myagtwin_patient']}</p>

      <h2>DIA</h2>
      <p>@{items('Apply_to_each_KPI')?['myagtwin_balancedscorecard']}</p>

      <h2>Recommendation</h2>
      <p>@{items('Apply_to_each_KPI')?['myagtwin_recommendation']}</p>

      <h2>Next Steps</h2>
      <p>@{replace(items('Apply_to_each_KPI')?['myagtwin_nextsteps'], '\n', '<br />')}</p>
    </div>
  </div>

  <div class="slide-footer">
    <div class="footer-left">
      <span class="slide-number">@{variables('slideNumber')}</span>
      <span class="slide-date">@{formatDateTime(utcNow(), 'MMMM yyyy')}</span>
    </div>
    <div class="footer-logo" aria-label="GSK logo">
      <img
        src="https://companieslogo.com/img/orig/GSK_BIG-04d5c41c.png?t=1669451926&download=true"
        alt="GSK"
      />
    </div>
  </div>
</div>
```

---

## 8. Final Document Assembly

After the outer Apply to Each loop completes, compose the full HTML:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>MPR Off-Track KPI Slides — @{formatDateTime(utcNow(), 'MMMM yyyy')}</title>
  <style>
    [PASTE FULL CSS FROM Copilot MPR Slide Template HERE]
  </style>
</head>
<body>
  @{variables('allSlides')}
</body>
</html>
```

---

## 9. Sample Data Verification

Using `graph_points_example.json` (values 0.5–0.9, target 0.9):

| Variable    | Computed Value                       |
|-------------|--------------------------------------|
| `yMin`      | `min(0.9,0.7,0.8,0.6,0.5) - 0.05 = 0.45` |
| `yMax`      | `1.0`                                |
| `yRange`    | `0.55`                               |
| `pointCount`| `5`                                  |
| `xSpacing`  | `360 / 4 = 90`                       |
| `targetY`   | `220 - ((0.9-0.45)/0.55)*200 = 56`   |

**Resulting SVG points:**

| DATE   | VALUE | xPos | yPos                              | ON_TARGET | Colour    |
|--------|-------|------|-----------------------------------|-----------|-----------|
| Jan-26 | 0.9   | 70   | 220 - (0.45/0.55)*200 = 56        | 1         | `#2e7d32` |
| Feb-26 | 0.7   | 160  | 220 - (0.25/0.55)*200 = 129       | 0         | `#d0021b` |
| Mar-26 | 0.8   | 250  | 220 - (0.35/0.55)*200 = 93        | 0         | `#d0021b` |
| Apr-26 | 0.6   | 340  | 220 - (0.15/0.55)*200 = 165       | 0         | `#d0021b` |
| May-26 | 0.5   | 430  | 220 - (0.05/0.55)*200 = 202       | 0         | `#d0021b` |

Polyline `points` string: `70,56 160,129 250,93 340,165 430,202 `

---

## 10. Tips & Gotchas

| Issue | Fix |
|---|---|
| `div()` does integer division | Wrap operands: `div(float(a), float(b))` |
| `mul()` with floats fails | Use `mul(float(a), float(b))` |
| `int()` truncates, not rounds | For display labels this is fine; for pixel positions add `0.5` before `int()` |
| Apply to Each has no native index | Manually increment `pointIndex` variable at end of each iteration |
| Graph points stored in Dataverse as JSON text | Add a **Parse JSON** action after retrieving the field; schema matches `graph_points_example.json` |
| Graph points in a separate Dataverse table | Add **List rows** filtered by `myagtwin_kpiid`, then **Select** to normalise |
| `svgPolyline` trailing space | PA's `trim()` function removes it if needed; SVG tolerates trailing spaces |
| Next steps with line breaks | Use `replace(field, '\n', '<br />')` to preserve line breaks in HTML |
