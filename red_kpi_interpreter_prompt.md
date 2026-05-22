Read information from the kpiList and kpiDataResult 
Determine which KPI's from kpiList  are in RED based on the results from kpiDataResult .
If the kpiDataResult shows that a KPI ID "OnTarget" value is:
 = 1 than its GREEN
 = 0 than its RED
 = 2 than its UNDEFINED

ONLY return the identified RED KPIs!
Return a JSON with 2 properties. "redKPIS" which is an array of JSON objects based on the schema below and "message"  which is a human readable list message to user like this example:
"The following KPI's are in RED and need potential DIA action.
KPI_EM_011 - COW (Cost Of Waste)
Assigned Owner: Ana Ocariz Sanchez (ana.x.ocarizsanchez@gsk.com)
KPI_EM_018 - Manual Tasks Eliminated
Assigned Owner: Vitor Antonio (vitor.x.antonio@gsk.com)"

redKPIS schema:
[
    {
        "description": "",
        "id": "KPI_EM_011",
        "name": "COW (Cost Of Waste)",
        "owner": "Ana Ocariz Sanchez",
        "ownerEmail": "ana.x.ocarizsanchez@test.com",
        "ownerId": "f303de06-e51a-408f-8efc-987599853343",
        "OnTarget": false
    },
    {
        "description": "",
        "id": "KPI_EM_018",
        "name": "Manual Tasks Eliminated",
        "owner": "Vitor Antonio",
        "ownerEmail": "vitor.x.antonio@test.com",
        "ownerId": "420a2572-f2f7-4c85-80dc-ea6478de394b",
        "OnTarget": false
    }
]

--- V2 ---

Read information from the kpiList, msProjectsList  and dataResult 
Check the data results from dataResult and check the values that have RAG Red or Amber.

Return a JSON with 2 properties. "redKPIS" which is an array of JSON objects based on the schema below and "message" which is a human readable table message to user like this example:

``
"The following KPI's are in RED and need potential DIA action.
--
Table
--
KPI_EM_035 - Deviations On-Time
Assigned Owner: Ana Ocariz Sanchez (ana.x.ocarizsanchez@gsk.com)
--
KPI_EM_039 - TPI Closed On Time
Assigned Owner: Vitor Antonio (vitor.x.antonio@gsk.com)"
--
MS PROJECT - MAPS 24v infant Ph2
Assigned Owner: Sylvine Barriere (sylvine.x.barriere@gsk.com)"
``

*redKPIS schema*
[
                {
                        "EntityId ": "KPI_EM_035",
                        "EntityType ": "KPI",
                        "Name ": "Deviations On-Time",
                        "OwnerEmail ": "dilawar.x.mansoori@gsk.com",
                        "OwnerName": "Dilawar Mansoori",
                        "RAG ": "Red"
                },
                {
                        "EntityId ": "KPI_EM_039",
                        "EntityType ": "KPI",
                        "Name ": "TPI Closed On Time",
                        "OwnerEmail ": "vitor.x.antonio@gsk.com",
                        "OwnerName": "Vitor Antonio",
                        "RAG ": "Red"
                },
                {
                        "EntityId ": "773c5730-a49e-ee11-a2b3-00155d100f4c",
                        "EntityType ": "MS PROJECT",
                        "Name ": "MAPS 24v infant Ph2",
                        "OwnerEmail ": "sylvine.x.barriere@gsk.com",
                        "OwnerName": "Sylvine Barriere",
                        "RAG ": "Amber"
                }
]

