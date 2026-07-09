EVALUATE
TOPN(
    5,
    ADDCOLUMNS(
        CALCULATETABLE(
            VALUES('Calendar'[MonthStart]),
            'Calendar'[IsShowClosedMonthsOnly] = TRUE
        ),
        "MonthLabel", FORMAT('Calendar'[MonthStart], "MMM-YY"),
        "KPI_EM_037_Actual", CALCULATE('MeasureTable'[KPI_EM_037_Actual]),
        "KPI_EM_037_OnTarget", CALCULATE('MeasureTable'[KPI_EM_037_OnTarget]),
        "KPI_EM_037_Target", CALCULATE('MeasureTable'[KPI_EM_037_Target])
    ),
    'Calendar'[MonthStart],
    0
)
ORDER BY
    'Calendar'[MonthStart]

