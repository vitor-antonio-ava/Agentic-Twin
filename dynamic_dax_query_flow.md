# Power Automate Flow - Dynamic DAX Query Builder (Step-by-Step)

## What This Flow Does
Takes a list of KPI IDs and MS Project IDs as input and dynamically builds a DAX query to get their RAG status from Power BI.

---

## INPUT SCHEMA

The flow receives this JSON (from an HTTP trigger, parent flow, or manual trigger with JSON input):

```json
{
  "kpiIds": "KPI_EM_035,KPI_EM_039,KPI_EM_045",
  "projectIds": "773c5730-a49e-ee11-a2b3-00155d100f4c,bd908a2e-7e2c-f111-ab42-00155d10160d",
  "tierCode": "T3_ID",
  "tierId": "T3_0003",
  "date": "2026-02-01"
}
```

> **Note:** `kpiIds` and `projectIds` are **comma-separated strings**, not arrays.
```

---

## STEP-BY-STEP BUILD INSTRUCTIONS

---

### STEP 1: Create the Trigger

1. Open Power Automate → **+ New flow** → Choose **Instant cloud flow** (or **Automated** if called from another flow)
2. If using **HTTP trigger** (Premium):
   - Add trigger: **When a HTTP request is received**
   - In the **Request Body JSON Schema** field, paste:
   ```json
   {
     "type": "object",
     "properties": {
       "kpiIds": { "type": "string" },
       "projectIds": { "type": "string" },
       "tierCode": { "type": "string" },
       "tierId": { "type": "string" },
       "date": { "type": "string" }
     },
     "required": ["kpiIds", "projectIds", "date"]
   }
   ```
3. If using **Manual trigger** (for testing):
   - Add trigger: **Manually trigger a flow**
   - Add a **Compose** action right after it and hardcode a test JSON for development

---

### STEP 2: Initialize Variables

1. Click **+ New step** → Search for **Initialize variable**
2. Create **3 variables** (add each as a separate Initialize variable action):

**Variable 1:**
| Field | Value |
|-------|-------|
| Name | `varDateYear` |
| Type | String |
| Value | Click "Expression" tab → type: `formatDateTime(triggerBody()?['date'], 'yyyy')` → click OK |

**Variable 2:**
| Field | Value |
|-------|-------|
| Name | `varDateMonth` |
| Type | Integer |
| Value | Click "Expression" tab → type: `int(formatDateTime(triggerBody()?['date'], 'MM'))` → click OK |

> **Why `int(formatDateTime(..., 'MM'))`?** Using `'M'` alone is a .NET standard format specifier that outputs "March 1" instead of "3". Using `'MM'` gives zero-padded month ("03"), then `int()` converts it to a plain number (3).

**Variable 3:**
| Field | Value |
|-------|-------|
| Name | `varFinalQuery` |
| Type | String |
| Value | (leave empty) |

---

### STEP 3: Build the Project Filter String

**Purpose:** Convert the comma-separated string `"id1,id2"` into DAX format `"id1", "id2"`

1. Click **+ New step** → Search for **Select** (Data Operations)
2. Configure:
   | Field | Value |
   |-------|-------|
   | From | Click "Expression" tab → `split(triggerBody()?['projectIds'], ',')` |
   | Map | Switch to **text mode** (click the toggle icon on the right of Map). Then click "Expression" tab → `concat('"', trim(item()), '"')` |

3. **Rename this action** to: `Select_QuoteProjectIds`
   - Click the 3 dots (⋯) on the action → Rename

4. Click **+ New step** → Search for **Compose** (Data Operations)
5. In the **Inputs** field, click "Expression" tab → paste:
   ```
   join(body('Select_QuoteProjectIds'), ', ')
   ```
6. **Rename** to: `Compose_ProjectFilterString`

**Result:** `"773c5730-a49e-ee11-a2b3-00155d100f4c", "bd908a2e-7e2c-f111-ab42-00155d10160d"`

---

### STEP 4: Build the KPI ROW Blocks

**Purpose:** For each KPI ID, generate a DAX `ROW(...)` expression dynamically.

1. Click **+ New step** → Search for **Select** (Data Operations)
2. Configure:
   | Field | Value |
   |-------|-------|
   | From | Click "Expression" tab → `split(triggerBody()?['kpiIds'], ',')` |
   | Map | Switch to **text mode**. Then click "Expression" tab → paste the expression below |

   **Map Expression:**
   ```
   concat('ROW("KPI_ID", "', trim(item()), '", "EntityType", "KPI", "RAG", SWITCH(TRUE(), ''MeasureTable''[', trim(item()), '_OnTarget] = 1, "Green", ''MeasureTable''[', trim(item()), '_OnTarget] = 0, "Red", "Unknown"))')
   ```

3. **Rename** to: `Select_KpiRowBlocks`

4. Click **+ New step** → **Compose**
5. In **Inputs**, click "Expression" tab → paste:
   ```
   join(body('Select_KpiRowBlocks'), ', ')
   ```
6. **Rename** to: `Compose_KpiUnionBlock`

**Result for each KPI:** 
```
ROW("KPI_ID", "KPI_EM_035", "EntityType", "KPI", "RAG", SWITCH(TRUE(), 'MeasureTable'[KPI_EM_035_OnTarget] = 1, "Green", 'MeasureTable'[KPI_EM_035_OnTarget] = 0, "Red", "Unknown"))
```

---

### STEP 5: Build the Tier Filter (Conditional)

**Purpose:** If tierCode and tierId are provided, add the tier filter to the query.

1. Click **+ New step** → **Compose**
2. In **Inputs**, click "Expression" tab → paste:
   ```
   if(and(not(empty(triggerBody()?['tierCode'])), not(empty(triggerBody()?['tierId']))), concat(', TREATAS("', triggerBody()?['tierId'], '", DIM_UNIVERSAL_HIERARCHY[', triggerBody()?['tierCode'], '])'), '')
   ```
3. **Rename** to: `Compose_TierFilter`

**Result (when tier is provided):** `, TREATAS("T3_0003", DIM_UNIVERSAL_HIERARCHY[T3_ID])`
**Result (when tier is empty):** `` (empty string)

---

### STEP 6: Assemble the Complete DAX Query

**Purpose:** Combine all the parts into the final DAX query string.

1. Click **+ New step** → **Compose**
2. In **Inputs**, click "Expression" tab → paste this entire expression:

```
concat('EVALUATE VAR ProjectFilter = { ', outputs('Compose_ProjectFilterString'), ' } VAR KpiRagTable = FILTER(SELECTCOLUMNS(CALCULATETABLE(UNION(', outputs('Compose_KpiUnionBlock'), '), TREATAS({ DATE(', variables('varDateYear'), ', ', variables('varDateMonth'), ', 1) }, ''calendar''[MonthStart])', outputs('Compose_TierFilter'), '), "EntityId", [KPI_ID], "EntityType", [EntityType], "Name", LOOKUPVALUE(DIM_LIST_OF_KPIS[KPI_NAME], DIM_LIST_OF_KPIS[KPI_ID], [KPI_ID]), "Owner_Email", BLANK(), "RAG", [RAG]), [RAG] = "Red") VAR MSProjectRagTable = FILTER(SELECTCOLUMNS(CALCULATETABLE(FCT_ACTIVE_MS_PROJECTS, TREATAS(ProjectFilter, FCT_ACTIVE_MS_PROJECTS[ProjectId])), "EntityId", FCT_ACTIVE_MS_PROJECTS[ProjectId], "EntityType", "MS PROJECT", "Name", FCT_ACTIVE_MS_PROJECTS[ProjectName], "Owner_Email", FCT_ACTIVE_MS_PROJECTS[Owner_Email], "RAG", FCT_ACTIVE_MS_PROJECTS[ProjectRAG]), [RAG] IN { "Red", "Amber" }) RETURN UNION(KpiRagTable, MSProjectRagTable)')
```

3. **Rename** to: `Compose_FinalDaxQuery`

> **NOTE:** DAX accepts single-line queries. The Power BI connector will process it regardless of formatting.

---

### STEP 6 (ALTERNATIVE - Readable Multi-line Version)

If you prefer a formatted readable query, use **Set Variable** instead:

1. Click **+ New step** → **Set variable**
2. Select `varFinalQuery`
3. In the **Value** field, type/paste the following **mixing literal text and dynamic content**:

Start typing in the value field (use the Dynamic Content panel and Expression tab where indicated):

```
EVALUATE
VAR ProjectFilter =
    {
        @{outputs('Compose_ProjectFilterString')}
    }
VAR KpiRagTable =
    FILTER(
        SELECTCOLUMNS(
            CALCULATETABLE(
                @{if(contains(outputs('Compose_KpiUnionBlock'), '), ROW('), concat('UNION(', outputs('Compose_KpiUnionBlock'), ')'), outputs('Compose_KpiUnionBlock'))},
                TREATAS ( { DATE(@{variables('varDateYear')}, @{variables('varDateMonth')}, 1) }, 'calendar'[MonthStart] )@{outputs('Compose_TierFilter')}
            ),
            "EntityId",    [KPI_ID],
            "EntityType",  [EntityType],
            "Name",
                LOOKUPVALUE(
                    DIM_LIST_OF_KPIS[KPI_NAME],
                    DIM_LIST_OF_KPIS[KPI_ID], [KPI_ID]
                ),
            "Owner_Email", BLANK(),
            "RAG",         [RAG]
        ),
        [RAG] = "Red"
    )
VAR MSProjectRagTable =
    FILTER(
        SELECTCOLUMNS(
            CALCULATETABLE(
                FCT_ACTIVE_MS_PROJECTS,
                TREATAS(
                    ProjectFilter,
                    FCT_ACTIVE_MS_PROJECTS[ProjectId]
                )
            ),
            "EntityId",    FCT_ACTIVE_MS_PROJECTS[ProjectId],
            "EntityType",  "MS PROJECT",
            "Name",        FCT_ACTIVE_MS_PROJECTS[ProjectName],
            "Owner_Email", FCT_ACTIVE_MS_PROJECTS[Owner_Email],
            "RAG",         FCT_ACTIVE_MS_PROJECTS[ProjectRAG]
        ),
        [RAG] IN { "Red", "Amber" }
    )
RETURN
UNION(
    KpiRagTable,
    MSProjectRagTable
)
```

> In the field above, each `@{...}` represents a dynamic content insertion. In Power Automate's editor:
> - Type the plain text parts normally
> - For each `@{...}` part, click in that position, then click **Dynamic content** or **Expression** and insert the appropriate reference

---

### STEP 7: Run the Query Against Power BI

1. Click **+ New step** → Search for **Run a query against a dataset** (Power BI connector)
2. You may need to sign in to your Power BI connection
3. Configure:
   | Field | Value |
   |-------|-------|
   | Workspace | Select: **GSC_T3_PRD_ExternalBusinessDevelopment** |
   | Dataset | Select: **8e6ca018-ec7a-40b7-8ff9-bcfceb78198f** (EM KPI Library) |
   | Query | Click into the field → Dynamic content → select **Outputs** from `Compose_FinalDaxQuery` (or use `variables('varFinalQuery')` if you used the Set Variable approach) |

4. **Rename** to: `PowerBI_RunDaxQuery`

---

### STEP 8: Parse the Power BI Response

1. Click **+ New step** → Search for **Parse JSON** (Data Operations)
2. Configure:
   | Field | Value |
   |-------|-------|
   | Content | Dynamic content → select **First table rows** from the `PowerBI_RunDaxQuery` step |
   | Schema | Click **Generate from sample** and paste this sample payload, OR paste the schema directly: |

**Schema:**
```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "[EntityId]": { "type": "string" },
      "[EntityType]": { "type": "string" },
      "[Name]": { "type": "string" },
      "[Owner_Email]": { "type": "string" },
      "[RAG]": { "type": "string" }
    }
  }
}
```

> **Note:** Power BI wraps column names in brackets like `[EntityId]` in the response. Check your actual response to confirm the exact property names.

3. **Rename** to: `Parse_DaxResults`

---

### STEP 9 (Optional): Filter Results by Entity Type

If you want to separate KPIs from MS Projects:

1. Click **+ New step** → Search for **Filter array** (Data Operations)
2. Configure:
   | Field | Value |
   |-------|-------|
   | From | Dynamic content → **Body** from `Parse_DaxResults` |
   | Condition | `[EntityType]` is equal to `KPI` |
3. **Rename** to: `Filter_RedKPIs`

4. Add another **Filter array**:
   | Field | Value |
   |-------|-------|
   | From | Dynamic content → **Body** from `Parse_DaxResults` |
   | Condition | `[EntityType]` is equal to `MS PROJECT` |
5. **Rename** to: `Filter_MSProjects`

---

### STEP 10: Return/Use the Results

**Option A - If this flow is called by another flow (child flow):**
1. Click **+ New step** → **Respond to a PowerApp or flow**
2. Add outputs:
   - Text output: `queryResults` → Dynamic content from `Parse_DaxResults` body
   
**Option B - If using HTTP trigger:**
1. Click **+ New step** → **Response**
2. Status Code: `200`
3. Body: Dynamic content → **Body** from `Parse_DaxResults`

---

## COMPLETE FLOW STRUCTURE (Visual Summary)

```
┌─────────────────────────────────────────┐
│ TRIGGER: HTTP Request / Manual          │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Initialize variable: varDateYear        │
│ Expression: formatDateTime(             │
│   triggerBody()?['date'], 'yyyy')       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Initialize variable: varDateMonth       │
│ Expression: int(formatDateTime(         │
│   triggerBody()?['date'], 'MM'))        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Initialize variable: varFinalQuery      │
│ (empty string)                          │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Select: Select_QuoteProjectIds          │
│ From: split(triggerBody()?['projectIds']│
│        , ',')                           │
│ Map:  concat('"', trim(item()), '"')    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Compose: Compose_ProjectFilterString    │
│ join(body('Select_QuoteProjectIds'),    │
│   ', ')                                 │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Select: Select_KpiRowBlocks             │
│ From: split(triggerBody()?['kpiIds'],   │
│        ',')                             │
│ Map: concat('ROW("KPI_ID", "',         │
│   trim(item()),'",...SWITCH...)')       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Compose: Compose_KpiUnionBlock          │
│ join(body('Select_KpiRowBlocks'), ', ') │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Compose: Compose_TierFilter             │
│ if(tierCode+tierId not empty,           │
│   TREATAS filter string, '')            │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Set Variable: varFinalQuery             │
│ (Assembles full DAX with all parts)     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Power BI: Run a query against dataset   │
│ Workspace: GSC_T3_PRD_External...       │
│ Dataset: 8e6ca018-ec7a-40b7-...         │
│ Query: variables('varFinalQuery')       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Parse JSON: Parse_DaxResults            │
│ Content: First table rows               │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Response / Return results               │
└─────────────────────────────────────────┘
```

---

## ALL EXPRESSIONS (Copy-Paste Ready)

### Initialize varDateYear
```
formatDateTime(triggerBody()?['date'], 'yyyy')
```

### Initialize varDateMonth
```
int(formatDateTime(triggerBody()?['date'], 'MM'))
```

### Select_QuoteProjectIds → From
```
split(triggerBody()?['projectIds'], ',')
```

### Select_QuoteProjectIds → Map
```
concat('"', trim(item()), '"')
```

### Compose_ProjectFilterString
```
join(body('Select_QuoteProjectIds'), ', ')
```

### Select_KpiRowBlocks → From
```
split(triggerBody()?['kpiIds'], ',')
```

### Select_KpiRowBlocks → Map
```
concat('ROW("KPI_ID", "', trim(item()), '", "EntityType", "KPI", "RAG", SWITCH(TRUE(), ''MeasureTable''[', trim(item()), '_OnTarget] = 1, "Green", ''MeasureTable''[', trim(item()), '_OnTarget] = 0, "Red", "Unknown"))')
```

### Compose_KpiUnionBlock
```
join(body('Select_KpiRowBlocks'), ', ')
```

### Compose_TierFilter
```
if(and(not(empty(triggerBody()?['tierCode'])), not(empty(triggerBody()?['tierId']))), concat(', TREATAS("', triggerBody()?['tierId'], '", DIM_UNIVERSAL_HIERARCHY[', triggerBody()?['tierCode'], '])'), '')
```

### Compose_FinalDaxQuery (single line version)
```
concat('EVALUATE VAR ProjectFilter = { ', outputs('Compose_ProjectFilterString'), ' } VAR KpiRagTable = FILTER(SELECTCOLUMNS(CALCULATETABLE(UNION(', outputs('Compose_KpiUnionBlock'), '), TREATAS({ DATE(', variables('varDateYear'), ', ', variables('varDateMonth'), ', 1) }, ''calendar''[MonthStart])', outputs('Compose_TierFilter'), '), "EntityId", [KPI_ID], "EntityType", [EntityType], "Name", LOOKUPVALUE(DIM_LIST_OF_KPIS[KPI_NAME], DIM_LIST_OF_KPIS[KPI_ID], [KPI_ID]), "Owner_Email", BLANK(), "RAG", [RAG]), [RAG] = "Red") VAR MSProjectRagTable = FILTER(SELECTCOLUMNS(CALCULATETABLE(FCT_ACTIVE_MS_PROJECTS, TREATAS(ProjectFilter, FCT_ACTIVE_MS_PROJECTS[ProjectId])), "EntityId", FCT_ACTIVE_MS_PROJECTS[ProjectId], "EntityType", "MS PROJECT", "Name", FCT_ACTIVE_MS_PROJECTS[ProjectName], "Owner_Email", FCT_ACTIVE_MS_PROJECTS[Owner_Email], "RAG", FCT_ACTIVE_MS_PROJECTS[ProjectRAG]), [RAG] IN { "Red", "Amber" }) RETURN UNION(KpiRagTable, MSProjectRagTable)')
```

> **Important:** `split()` is used to convert the comma-separated input strings into arrays before processing. `trim()` removes any whitespace around each ID in case the input has spaces after commas (e.g., `"KPI_EM_035, KPI_EM_039"`).

---

## EXPECTED OUTPUT (Example DAX Generated)

Given inputs:
- kpiIds: `"KPI_EM_035,KPI_EM_039"`
- projectIds: `"773c5730-a49e-ee11-a2b3-00155d100f4c,bd908a2e-7e2c-f111-ab42-00155d10160d"`
- tierCode: `"T3_ID"`, tierId: `"T3_0003"`, date: `"2026-02-01"`

```dax
EVALUATE
VAR ProjectFilter =
    {
        "773c5730-a49e-ee11-a2b3-00155d100f4c", "bd908a2e-7e2c-f111-ab42-00155d10160d"
    }
VAR KpiRagTable =
    FILTER(
        SELECTCOLUMNS(
            CALCULATETABLE(
                UNION(
                    ROW("KPI_ID", "KPI_EM_035", "EntityType", "KPI", "RAG", SWITCH(TRUE(), 'MeasureTable'[KPI_EM_035_OnTarget] = 1, "Green", 'MeasureTable'[KPI_EM_035_OnTarget] = 0, "Red", "Unknown")),
                    ROW("KPI_ID", "KPI_EM_039", "EntityType", "KPI", "RAG", SWITCH(TRUE(), 'MeasureTable'[KPI_EM_039_OnTarget] = 1, "Green", 'MeasureTable'[KPI_EM_039_OnTarget] = 0, "Red", "Unknown"))
                ),
                TREATAS ( { DATE(2026, 2, 1) }, 'calendar'[MonthStart] ),
                TREATAS("T3_0003", DIM_UNIVERSAL_HIERARCHY[T3_ID])
            ),
            "EntityId",    [KPI_ID],
            "EntityType",  [EntityType],
            "Name",        LOOKUPVALUE(DIM_LIST_OF_KPIS[KPI_NAME], DIM_LIST_OF_KPIS[KPI_ID], [KPI_ID]),
            "Owner_Email", BLANK(),
            "RAG",         [RAG]
        ),
        [RAG] = "Red"
    )
VAR MSProjectRagTable =
    FILTER(
        SELECTCOLUMNS(
            CALCULATETABLE(
                FCT_ACTIVE_MS_PROJECTS,
                TREATAS(
                    ProjectFilter,
                    FCT_ACTIVE_MS_PROJECTS[ProjectId]
                )
            ),
            "EntityId",    FCT_ACTIVE_MS_PROJECTS[ProjectId],
            "EntityType",  "MS PROJECT",
            "Name",        FCT_ACTIVE_MS_PROJECTS[ProjectName],
            "Owner_Email", FCT_ACTIVE_MS_PROJECTS[Owner_Email],
            "RAG",         FCT_ACTIVE_MS_PROJECTS[ProjectRAG]
        ),
        [RAG] IN { "Red", "Amber" }
    )
RETURN
UNION(
    KpiRagTable,
    MSProjectRagTable
)
```

---

## TIPS & TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| "Expression too long" error in Compose | Use the Set Variable approach (Step 6 Alternative) instead |
| Single quotes in DAX breaking the expression | In Power Automate expressions, use `''` (two single quotes) to escape a single quote inside a string literal |
| Power BI query fails | Test the generated query first by adding a Compose action after Step 6 and checking the output in a test run |
| Empty KPI or Project string | Add a **Condition** before Step 7: `if(empty(triggerBody()?['kpiIds']), ..., ...)` → only run query if both have values |
| Column names in response have brackets | Power BI returns columns as `[EntityId]`, `[Name]`, etc. — adjust your Parse JSON schema accordingly |
| "Select" action map field doesn't show expression editor | Click the small toggle icon (T with arrow) to switch from key/value mode to text mode |
| Spaces in comma-separated input | `trim(item())` handles this — inputs like `"KPI_EM_035, KPI_EM_039"` work fine |
