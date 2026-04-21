{
  type: "AdaptiveCard",
  '$schema': "http://adaptivecards.io/schemas/adaptive-card.json",
  version: "1.5",
  body: [
    { type: "TextBlock", text: "Select your recipients", weight: "Bolder", size: "Medium" },
    {
      type: "Input.ChoiceSet",
      id: "people-picker",
      label: "Mandatory recipients", 
      isRequired: true,
      errorMessage: "Minimum one user is required",      
      isMultiSelect: true,
      'choices.data': {
        type: "Data.Query",
        dataset: "graph.microsoft.com/users"
      }      
    },
    {
          type: "Input.ChoiceSet",
          id: "people-picker-2",
          label: "Optional recipients", 
          isRequired: false,    
          isMultiSelect: true,
          'choices.data': {
            type: "Data.Query",
            dataset: "graph.microsoft.com/users"
          }      
    },
    {
      type: "ActionSet",
      actions: [
        { type: "Action.Submit", id: "selectRecipients", title: "Select recipients" }
      ]
    }
  ]
}