/*
* This class allows you to get the most common items of a page layout in a string representation
* @author: Pablo Gonzalez - 2018
*/

public class PageLayoutMetadata implements PageLayoutMetadataI{
    
    /**************************************************** INSTANCE VARIABLES *******************************************/
    
    private String apiName;
    private Metadata.Layout layoutObject;
    private string sObjectName;
    private List<String> sections;
    private List<String> buttons;
    private List<String> quickActions;
    private List<String> platformActions;
    private List<String> fields;
    private List<String> relatedLists;
    private Map<String,List<String>> relatedListFields;
    private Map<String,List<String>> relatedListButtons;
    

    
		/**************************************************** PUBLIC METHODS *******************************************/
    
    
    /*
     * Constructor
     * @param pageLayoutName: A page layout name that adheres to the Metadata API naming convention.
	*/
    public PageLayoutMetadata(String pageLayoutName){
        
        isLayoutNameValid(pageLayoutName);
        this.buttons = getButtonsFromMetadata();
        this.quickActions = getQuickActionsFromMetadata();
        this.platformActions = getPlatformActionsFromMetadata();
        this.sections = getSectionsFromMetadata();
        this.fields = getFieldsFromMetadata();
        this.relatedLists = getRelatedListsFromMetadata();    
        this.relatedListButtons = getRelatedListButtonsFromMetadata();
        this.relatedListFields = getRelatedlistFieldsFromMetadata();
        
        System.debug(LoggingLevel.INFO, 'PageLayoutMetadata: PageLayoutMetadata object initialized.');
        
    }
    
    public String getApiName(){
        return apiName;
    }
    
    public String getSObjectName(){
        return sObjectName;
    }
    
    public List<String> getSections(){
        return sections;
    }
    
    public List<String> getButtons(){
        return buttons;
    }
    
    public List<String> getQuickActions(){
        return quickActions;
    }
    
    public List<String> getPlatformActions(){
        return platformActions;
    }
    
    public List<String> getFields(){
        return fields;
    }
    
    public List<String> getRelatedlists(){
        return relatedLists;
    }
    
    public Map<String,List<String>> getRelatedListFields(){
        return relatedListFields;
    }
    
    public Map<String,List<String>> getRelatedListButtons(){
        return relatedListButtons;
    }
    
    /**************************************************** PRIVATE METHODS *******************************************/
    
    /*
    * This method checks that the page layout name passed to the constructor is correct
    * If so, it sets the corresponding instance variables with the layout name and the parent sObject name
    * @param: pageLayoutName - The Metadata API name of the Page Layout
    * @throws: PageLayoutNotFoundException
    */
    private void isLayoutNameValid(String pageLayoutName){
        
        System.debug(LoggingLevel.INFO, 'isLayoutNameValid(): Validating if '+pageLayoutName+' is a valid Page Layout name');
        
        
        //try to get the page layout from the metadata object. If the list is empty, the name is wrong
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {pageLayoutName});
        if(layouts.size() <1){
            System.debug(LoggingLevel.ERROR, pageLayoutName+' is not a valid page layout name. Make sure you are using the format specified by the Metadata API');
            throw new PageLayoutNotFoundException(pageLayoutName+' is not a valid page layout name. Make sure you are using the format specified by the Metadata API');
        }
        //get the parent layout metadata object
        layoutObject = (Metadata.Layout) layouts.get(0);
        
        //because we know the layout name is correct, split it so that we can extract the object name  
        List<String> parts = pageLayoutName.split('-');       
        
        this.sObjectName = parts[0];
        this.apiName = pageLayoutName;
        
    }
    
    /*
    * Goes through the different layers of the page layout metadata and returns a list of string
    * where each string is the api name of a button
    */
    private List<String> getButtonsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getButtonsFromMetadata(): Retrieving Custom Buttons from Page Layout');

        
        List<String> buttons = new List<String>();
        
        if(layoutObject.customButtons != null){
            for(String button : layoutObject.customButtons){
                buttons.add(button);
            }
        }
        return buttons;
    }
    
    /*
    * Goes through the different layers of the page layout metadata and returns a list of string
    * where each string is the api name of a quick action
    */
    private List<String> getQuickActionsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getQuickActionsFromMetadata(): Retrieving Quick Actions from Page Layout');
        
        List<String> quickActions = new List<String>();
        
        if(layoutObject.quickActionList != null){
              
            for(Metadata.QuickActionListItem action : layoutObject.quickActionList.quickActionListItems){
                    quickActions.add(action.quickActionName);                                 
            }
        }
        return quickActions;
    }
    
    /*
    * Goes through the different layers of the page layout metadata and returns a list of string
    * where each string is the api name of a platform action
    */
    private List<String> getPlatformActionsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getPlatformActionsFromMetadata(): Retrieving Platform Actions from Page Layout');
        
        List<String> platformActions = new List<String>();
        
        //process lightning actions
        if(layoutObject.platformActionList != null){
            for(Metadata.PlatformActionListItem platformAction : layoutObject.platformActionList.platformActionListItems){

                    platformActions.add(platformAction.actionName);

                }
            }
        
        return platformActions;
     }
    
    /*
    * Goes through the different layers of the page layout metadata and returns a list of strings
    * where each string is a name of a layout section
    * @return List<String>
    */
    private List<String> getSectionsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getSectionsFromMetadata(): Retrieving Sections from Page Layout');
        
        List<String> sections = new List<String>();
        
        if(layoutObject.layoutSections != null){
            List<Metadata.LayoutSection> layoutSections = layoutObject.layoutSections;
            
            for (Metadata.LayoutSection section : layoutSections) {
                sections.add(section.label);
            }
        }
		return sections;
    }
    
    
    /*
    * Goes through the different layers of the page layout metadata and returns a list of strings
    * where each string is a field api name
    * @return List<String>
    */
    private List<String> getFieldsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getFieldsFromMetadata(): Retrieving field API names referenced in the Page Layout');
        
        //the list of fields available in the layout
        List<String> fields = new List<String>();
        
        //get the sections from the layout - fields are children of layout sections
        List<Metadata.LayoutSection> layoutSections = layoutObject.layoutSections;
        //loop through all the sections and see if they have columns
        for(Metadata.LayoutSection section : layoutSections){
            List<Metadata.LayoutColumn> columns = section.layoutColumns;
            
            for(Metadata.LayoutColumn column : columns){
                //for every column, inspect the column items to see if there are fields
                if(column.layoutItems != null){
                    List<Metadata.LayoutItem> layoutItems = column.layoutItems;
                    
                    for(Metadata.LayoutItem item : layoutItems){
                        
                        if(item.field != null){
                            fields.add(item.field);
                        }
                    }      
                }   
            }
            
        }
        return fields;
    }
    
     /*
    * Goes through the different layers of the page layout metadata and returns a list of strings
    * where each string is a name of a related list
    * @return List<String>
    */
    private List<String> getRelatedlistsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getRelatedlistsFromMetadata(): Retrieving Related List names from the Page Layout');
        
        List<String> relatedLists = new List<String>();
        
        if(layoutObject.relatedLists != null){
            
             List<Metadata.RelatedListItem> relatedListItems = layoutObject.relatedLists;

            for(Metadata.RelatedListItem relatedList : relatedListItems){
                relatedLists.add(relatedList.relatedList);
            }
        }
        return relatedLists;
        
    }
    
      /*
    * Goes through the different layers of the page layout metadata and returns a list of strings
    * where each string is a name of a related list button in the following notation relatedListName.buttonName
    * @return List<String>
    */
    private Map<String,List<String>> getRelatedlistButtonsFromMetadata(){
        
        System.debug(LoggingLevel.INFO,'getRelatedlistButtonsFromMetadata(): Retrieving Custom Buttons from the Related Lists of the Page Layout');
        
        Map<String,List<String>> objectAndButtons = new Map<String,List<String>>();
        
        if(layoutObject.relatedLists != null){
            
            for(Metadata.RelatedListItem relatedList : layoutObject.relatedLists){
                if(relatedList.customButtons != null){
                    
                    List<String> relatedListButtons = new List<String>();
                    String relatedObject;
                    
                          //if this is a related list from a custom object
                    if(relatedList.relatedList.contains('.')){
                         relatedObject = relatedList.relatedList.substringBefore('.');
                    }else{//if the related list is from a standard object
                        relatedObject =  relatedList.relatedList.substringAfter('Related');
                        relatedObject = relatedObject.substringBeforeLast('List');
                    }
                    
                    
                    
                    for(String button : relatedList.customButtons){
                        relatedListButtons.add(button);
                    }
                    objectAndButtons.put(relatedObject,relatedListButtons);
                }
            }

        }
        return objectAndButtons;   
    }
    
     /*
    * Goes through the different layers of the page layout metadata and returns a list of strings
    * where each string is a name of a related list field in the following notation relatedListName.fieldName
    * @return List<String>
    */
    private Map<String,List<String>> getRelatedlistFieldsFromMetadata(){
        
        Map<String,List<String>> relatedObjectAndFields = new Map<String,List<String>>();
        String relatedObject;
        
        System.debug(LoggingLevel.INFO,'getRelatedlistFieldsFromMetadata(): Retrieving Custom Fields from the Related Lists of the Page Layout');
        
        List<String> relatedListFields = new List<String>();
        
        if(layoutObject.relatedLists != null){
            
            for(Metadata.RelatedListItem relatedList : layoutObject.relatedLists){
                
                //if this is a related list from a custom object
                if(relatedList.relatedList.contains('.')){
                     relatedObject = relatedList.relatedList.substringBefore('.');
                }else{//if the related list is from a standard object
                    relatedObject =  relatedList.relatedList.substringAfter('Related');
                    relatedObject = relatedObject.substringBeforeLast('List');
                }
                //only process related list that have fields
                if(relatedList.fields != null){
                    relatedObjectAndFields.put(relatedObject,relatedList.fields);
                }
            }

        }
        return relatedObjectAndFields;   
    }
    
    /*
     * Used to thrown an exception when a page layout does not meet the Metadata API naming convention.
	*/
    private class PageLayoutNotFoundException extends Exception{}
    
}