## KPI and other Data ##
- Workspace: GSC_T3_PRD_ExternalBusinessDevelopment
- Dataset: 8e6ca018-ec7a-40b7-8ff9-bcfceb78198f (EM KPI Library)

## Power BI Queries 

## Get Hierarchy Tiers
EVALUATE
    SUMMARIZE(
    'DIM_UNIVERSAL_HIERARCHY',
    'DIM_UNIVERSAL_HIERARCHY'[T4_ID],
    'DIM_UNIVERSAL_HIERARCHY'[T4_Desc],
    'DIM_UNIVERSAL_HIERARCHY'[T3_ID],
    'DIM_UNIVERSAL_HIERARCHY'[T3_Desc],
    'DIM_UNIVERSAL_HIERARCHY'[T2_ID],
    'DIM_UNIVERSAL_HIERARCHY'[T2_Desc],
    'DIM_UNIVERSAL_HIERARCHY'[T1_ID],
    'DIM_UNIVERSAL_HIERARCHY'[T1_Desc],
)

## Get MS Projects
EVALUATE
SUMMARIZE (
    'FCT_ACTIVE_MS_PROJECTS',
    'FCT_ACTIVE_MS_PROJECTS'[ProjectId],
    'FCT_ACTIVE_MS_PROJECTS'[ProjectName],   
    'FCT_ACTIVE_MS_PROJECTS'[ProjectOwner],? -> comes from power bi
    <!-- 'FCT_ACTIVE_MS_PROJECTS'[ProjectRAG], -->
    <!-- 'FCT_ACTIVE_MS_PROJECTS'[T3_ID] -->
    <!-- 'FCT_ACTIVE_MS_PROJECTS'[T3_Desc] -->
)

## Get KIPs
EVALUATE
SUMMARIZE (
    'DIM_LIST_OF_KPIS',
    'DIM_LIST_OF_KPIS'[KPI_ID],
    'DIM_LIST_OF_KPIS'[KPI_NAME]
)

## Get KPI Values Examples ##

## First Example
DEFINE
  VAR __DS0FilterTable = 
    TREATAS({DATE(2026, 3, 1)}, 'calendar'[MonthStart])

  VAR __DS0Core = 
    SUMMARIZECOLUMNS(
      'calendar'[MonthStart],
      __DS0FilterTable,
      "KPI_EM_045_Actual", 'MeasureTable'[KPI_EM_045_Actual],
      "KPI_EM_045_Target", 'MeasureTable'[KPI_EM_045_Target],
      "KPI_EM_045_OnTarget", 'MeasureTable'[KPI_EM_045_OnTarget]
    )

  VAR __DS0PrimaryWindowed = 
    TOPN(501, __DS0Core, 'calendar'[MonthStart], 1)

EVALUATE
  __DS0PrimaryWindowed

ORDER BY
  'calendar'[MonthStart]

## Second Example
EVALUATE
CALCULATETABLE(
    UNION(
        ROW(
            "KPI_ID", "KPI_EM_035",
            "Actual",   'MeasureTable'[KPI_EM_035_Actual],
            "OnTarget", 'MeasureTable'[KPI_EM_035_OnTarget],
            "Target",   'MeasureTable'[KPI_EM_035_Target]
        ),
        ROW(
            "KPI_ID", "KPI_EM_039",
            "Actual",   'MeasureTable'[KPI_EM_039_Actual],
            "OnTarget", 'MeasureTable'[KPI_EM_039_OnTarget],
            "Target",   'MeasureTable'[KPI_EM_039_Target]
        ),
		ROW(
            "KPI_ID", "KPI_EM_045",
            "Actual",   'MeasureTable'[KPI_EM_045_Actual],
            "OnTarget", 'MeasureTable'[KPI_EM_045_OnTarget],
            "Target",   'MeasureTable'[KPI_EM_045_Target]
        )
    ),
    TREATAS( { DATE(2026, 3, 1) }, 'calendar'[MonthStart] ),
    TREATAS( DIM_UNIVERSAL_HIERARCHY[T3_0001] )
    
)

## First Sample Query Tested ##

## Power BI Settings
- Workspace : GSC_T2_PRD_Barnard_Castle_Data_Factory
- Dataset : 446066ca-eb33-4678-913a-af8f7047b90e (Sample)

## Power BI Query Sample
DEFINE
	VAR __DS0FilterTable = 
		TREATAS({BLANK()}, 'Count data'[Location Category])
 
	VAR __DS0Core = 
		CALCULATETABLE(
			SUMMARIZE(
				'Count data',
				'Count data'[Monitoring Type Description],
				'Count data'[Functional Location Description],
				'Count data'[Operation Description],
				'Count data'[Monitoring Sub-Category Text],
				'Count data'[Monitoring Grade Description]
			),
			KEEPFILTERS(__DS0FilterTable)
		)
 
	VAR __DS0PrimaryWindowed = 
		TOPN(
			501,
			__DS0Core,
			'Count data'[Monitoring Type Description],
			1,
			'Count data'[Functional Location Description],
			1,
			'Count data'[Operation Description],
			1,
			'Count data'[Monitoring Sub-Category Text],
			1,
			'Count data'[Monitoring Grade Description],
			1
		)
 
EVALUATE
	__DS0PrimaryWindowed
 
ORDER BY
	'Count data'[Monitoring Type Description],
	'Count data'[Functional Location Description],
	'Count data'[Operation Description],
	'Count data'[Monitoring Sub-Category Text],
	'Count data'[Monitoring Grade Description]


## 