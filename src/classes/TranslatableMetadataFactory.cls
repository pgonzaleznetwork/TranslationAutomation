/*
* This class takes string representations of a particular metadata type and transform them into a TranslatableMetadata object
* 
* The idea is that if you have a string representation of a specific metadata type, you can extract more information from it
* to be able to create a TranslatableMetadata object, which represents a metadata type that can be translated via the Translation Workbench.
* 
* @Author - Pablo Gonzalez
*/
public class TranslatableMetadataFactory {
    
    /*
     *************************************************** INSTANCE VARIABLES *******************************************/
    
    /*
    * Some metadata types are not fully available in Apex so it's not possible to extract their label. This value will be used
    * on those transltable items that don't expose their label name in apex.
    */
    @TestVisible
    private final String LABEL_NOT_AVAILABLE_IN_APEX = 'Label N/A';
    
    /*
    * Some metadata types don't belong to a specific sObject. This value will be used
    * on those transltable items that meet this criteria.
    */
    @TestVisible
    private final String OBJECT_AGNOSTIC_METADATA = 'Object N/A';
    
    /*
     * This list represents the API names of some of the standard actions shared among different objects. These actions are translated by default
     * so they shouldn't be returned as translatable metadata objects. 
	*/
    private final List<String> ACTIONS_THAT_DONT_NEED_TRANSLATION = new List<String>{'FeedItem.TextPost','FeedItem.ContentPost','NewTask','NewContact','NewCase','LogACall','NewNote','NewOpportunity',
            'SendEmail','NewEvent','FeedItem.LinkPost','FeedItem.PollPost','FeedItem.QuestionPost','JigsawSearch','Share','XClean',
            'Edit','Delete','AccountHierarchy','Submit','IncludeOffline','ChangeRecordType',
            'ChangeOwnerOne','EmailHighlightAction', 'CallHighlightAction','SmsHighlightAction','WebsiteHighlightAction','WebsiteHighlightAction'};
    
    
    /*the types of metadata that can be translated, in their given context.
    * For example, a custom field label can always be translated, but it's important to understand
    * its contenxt, for example, a field on a page layout, vs a field on a related list
    */
    public Enum TranslatableType {
        CUSTOM_FIELD_LABEL,
            CUSTOM_FIELD_HELP_TEXT,
            STANDARD_FIELD_HELP_TEXT,
            LAYOUT_SECTION_NAME,
            DETAIL_BUTTON,
            STANDARD_PICKLIST_VALUE,
            CUSTOM_PICKLIST_VALUE,
            BUTTON,QUICK_ACTION_OR_PLATFORM_ACTION,
            RELATED_LIST_BUTTON,RELATED_LIST_FIELD,RELATED_LIST_PICKLIST_VALUE        
            }
    
    //Map containing the DescribeResult for all the objects in the org
    private  Map<String,Schema.DescribeSObjectResult> allObjectsMap = new Map<String,Schema.DescribeSObjectResult>();
    
    //constructor
    private TranslatableMetadataFactory(){
        populateMapOfSobjectTypes();
        System.debug(LoggingLevel.INFO,'TranslatableMetadataFactory(): TranslatableMetadataFactory initialized');
    }
    
    /*Singleton method - This is done because the constructor's method populateMapOfSobjectTypes is resource heavy, so it should only
	be called once during a single execution*/
    private static TranslatableMetadataFactory instance;
    
    public static TranslatableMetadataFactory getInstance(){
        if(instance == null){
            instance = new TranslatableMetadataFactory();
        }
        return instance;
    }
    
	/*
     *************************************************** PUBLIC METHODS *******************************************/
    
    
    /*
    * Creates TranslatableMetadata objects based on a list of page layout section names
    * @param pageLayoutName: A valid page layout Name
    * @param sectionNames: A list representation of layout sections that belong to the pageLayoutName
    * @throws InvalidPageLayoutNameException
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getLayoutSectionsTranslatables(String pageLayoutName,List<String> sectionNames){
        
        System.debug(LoggingLevel.INFO,'getLayoutSectionsTranslatables(): Checking if '+pageLayoutName+' is a valid page layout name');
        
        List<TranslatableMetadata> layoutSections = new List<TranslatableMetadata>();
        
        if(!isThisAValidLayoutName(pageLayoutName)){
            System.debug(LoggingLevel.ERROR,pageLayoutName+' is not a valid page layout name. Make sure you are using the format specified by the Metadata API');
            throw new InvalidPageLayoutNameException(pageLayoutName+' is not a valid page layout name. Make sure you are using the format specified by the Metadata API');
        }else{
            for(String sectionName : sectionNames){
                TranslatableMetadata layoutSection = new TranslatableMetadata();
                layoutSection.apiName = pageLayoutName.split('-')[1];
                layoutSection.parentObject = pageLayoutName.split('-')[0];
                layoutSection.translatableLabel = sectionName;
                layoutSection.type = SFMD.type.LAYOUT_SECTION_NAME;
                layoutSections.add(layoutSection);
            }	
        }
        System.debug(LoggingLevel.INFO,'getLayoutSectionsTranslatables(): Returning '+ layoutSections.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getLayoutSectionsTranslatables(): '+JSON.serialize(layoutSections));
        return layoutSections;
    }
    
    /*
    * Creates TranslatableMetadata objects based on a list of page layout button names
    * @param pageLayoutName: A valid page layout Name
    * @param sectionNames: A list representation of layout buttons that belong to the pageLayoutName
    * @throws InvalidPageLayoutNameException
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getLayoutButtonsTranslatables(String pageLayoutName,List<String> buttonNames){
        
        System.debug(LoggingLevel.INFO,'getLayoutButtonsTranslatables(): Checking if '+pageLayoutName+' is a valid page layout name');
        
        
        List<TranslatableMetadata> layoutButtons = new List<TranslatableMetadata>();
        
        if(!isThisAValidLayoutName(pageLayoutName)){
            System.debug(LoggingLevel.ERROR,pageLayoutName+' is not a valid page layout name. Make sure you are using the format specified by the Metadata API');
            throw new InvalidPageLayoutNameException(pageLayoutName+' is not a valid page layout name. Make sure you are using the format specified by the Metadata API');
        }else{
            for(String buttonName : buttonNames){
                TranslatableMetadata detailButton = new TranslatableMetadata();
                detailButton.apiName = buttonName;
                detailButton.parentObject = pageLayoutName.split('-')[0];
                detailButton.translatableLabel = LABEL_NOT_AVAILABLE_IN_APEX;
                detailButton.type = SFMD.type.DETAIL_BUTTON;
                layoutButtons.add(detailButton);
            }	
        }
        System.debug(LoggingLevel.INFO,'getLayoutButtonsTranslatables(): Returning '+ layoutButtons.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getLayoutButtonsTranslatables(): '+JSON.serialize(layoutButtons));
        return layoutButtons;
    }
    
    /*
    * Creates TranslatableMetadata objects based on a list of platform/lightning action names
    * @param objectName: A valid page sObject name
    * @param quickActionNames: A list representation of quick actions that belong to that object
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getPlatformActionsTranslatables(List<String> platformActions){
        
        List<TranslatableMetadata> quickActions = new List<TranslatableMetadata>();
        
        for(String quickActionName : platformActions){
            
            if(!ACTIONS_THAT_DONT_NEED_TRANSLATION.contains(quickActionName)){
                
                TranslatableMetadata quickActionTranslatable = new TranslatableMetadata();
                quickActionTranslatable.parentObject = OBJECT_AGNOSTIC_METADATA;
                quickActionTranslatable.type = SFMD.type.PLATFORM_ACTION;
                quickActionTranslatable.translatableLabel = LABEL_NOT_AVAILABLE_IN_APEX;
                quickActionTranslatable.apiName = quickActionName;
                quickActions.add(quickActionTranslatable);
                
            }

            
        }
        System.debug(LoggingLevel.INFO,'getPlatformActionsTranslatables(): Returning '+ quickActions.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getPlatformActionsTranslatables(): '+JSON.serialize(quickActions));
        return quickActions;
    }
    
    /*
    * Creates TranslatableMetadata objects based on a list of quick action names
    * @param objectName: A valid page sObject name
    * @param quickActionNames: A list representation of quick actions that belong to that object
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getQuickActionsTranslatables(String objectName,List<String> quickActionNames){
        
        List<TranslatableMetadata> quickActions = new List<TranslatableMetadata>();
        
        for(String quickActionName : quickActionNames){
            
            if(!ACTIONS_THAT_DONT_NEED_TRANSLATION.contains(quickActionName)){
                
                TranslatableMetadata quickActionTranslatable = new TranslatableMetadata();
                quickActionTranslatable.parentObject = objectName;
                quickActionTranslatable.type = SFMD.type.QUICK_ACTION;
                quickActionTranslatable.translatableLabel = LABEL_NOT_AVAILABLE_IN_APEX;
                quickActionTranslatable.apiName = quickActionName;
                quickActions.add(quickActionTranslatable);
            }         
        }
        System.debug(LoggingLevel.INFO,'getQuickActionsTranslatables(): Returning '+ quickActions.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getQuickActionsTranslatables(): '+JSON.serialize(quickActions));
        return quickActions;
    }
    
    
    /*
    * Creates TranslatableMetadata objects based on a list of field api names
    * @param sObjectName: A valid sObject Name
    * @param fieldApiNames: A list representation of fields that belong to the sObjectName
    * @return List<TranslatableMetadata>
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    */
    public List<TranslatableMetadata> getCustomFieldLabelTranslatables(String sObjectName,List<String> fieldApiNames){
        
        List<TranslatableMetadata> translatableFieldLabels = new List<TranslatableMetadata>();
        
        //validate that the object is valid and that the fields belong to the object    
        Map<String,Map<String,Schema.DescribeFieldResult>> objectAndFieldInfo = validateThatFieldsBelongToThisObject(sObjectName,fieldApiNames);
        
        // the validation passed, so we can get the field describe information
        Map<String,Schema.DescribeFieldResult> fieldInfo = objectAndFieldInfo.get(sObjectName);
        
        //we don't need to go through all the fields in the map, only the ones originally passed to the method    
        for(String fieldApiName : fieldApiNames){
            //we only care about custom fields because standard fields are translated by default
            if(fieldInfo.get(fieldApiName).isCustom()){
                TranslatableMetadata translatableMD = new TranslatableMetadata();
                translatableMD.apiName = fieldApiName;
                translatableMD.type = SFMD.type.CUSTOM_FIELD_LABEL;
                translatableMD.parentObject = sObjectName;
                translatableMD.translatableLabel = fieldInfo.get(fieldApiName).getLabel();
                translatableFieldLabels.add(translatableMD);
            }
        }
        
        System.debug(LoggingLevel.INFO,'getCustomFieldLabelTranslatables(): Returning '+ translatableFieldLabels.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getCustomFieldLabelTranslatables(): '+JSON.serialize(translatableFieldLabels));
        return translatableFieldLabels;
    }
    
    /*
    * Creates TranslatableMetadata of type Custom Field Help Text based on a list of field api names
    * @param sObjectName: A valid sObject Name
    * @param fieldApiNames: A list representation of fields that belong to the sObjectName
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getCustomFieldHelpTextTranslatables(String sObjectName,List<String> fieldApiNames){
        
        List<TranslatableMetadata> translatableFieldHelpTexts = new List<TranslatableMetadata>();
        
        //validate that the object is valid and that the fields belong to the object    
        Map<String,Map<String,Schema.DescribeFieldResult>> objectAndFieldInfo = validateThatFieldsBelongToThisObject(sObjectName,fieldApiNames);
        
        // the validation passed, so we can get the field describe information
        Map<String,Schema.DescribeFieldResult> fieldInfo = objectAndFieldInfo.get(sObjectName);
        
        //we only need to go through the fields were passed to the method
        for(String fieldApiName : fieldApiNames){
            //process custom fields that have a help text
            if(fieldInfo.get(fieldApiName).getInlineHelpText() != null && fieldInfo.get(fieldApiName).isCustom()){
                TranslatableMetadata fieldHelpText = new TranslatableMetadata();
                fieldHelpText.apiName = fieldApiName;
                fieldHelpText.parentObject = sObjectName;
                fieldHelpText.translatableLabel = fieldInfo.get(fieldApiName).getInlineHelpText();
                fieldHelpText.type = SFMD.type.CUSTOM_FIELD_HELP_TEXT;
                translatableFieldHelpTexts.add(fieldHelpText);
            }
        }
        System.debug(LoggingLevel.INFO,'getCustomFieldHelpTextTranslatables(): Returning '+ translatableFieldHelpTexts.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getCustomFieldHelpTextTranslatables(): '+JSON.serialize(translatableFieldHelpTexts));
        return translatableFieldHelpTexts;
        
    }
    
        /*
    * Creates TranslatableMetadata of type Standard Field Help Text based on a list of field api names
    * @param sObjectName: A valid sObject Name
    * @param fieldApiNames: A list representation of fields that belong to the sObjectName
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getStandardFieldHelpTextTranslatables(String sObjectName,List<String> fieldApiNames){
        
        List<TranslatableMetadata> translatableFieldHelpTexts = new List<TranslatableMetadata>();
        
        //validate that the object is valid and that the fields belong to the object    
        Map<String,Map<String,Schema.DescribeFieldResult>> objectAndFieldInfo = validateThatFieldsBelongToThisObject(sObjectName,fieldApiNames);
        
        // the validation passed, so we can get the field describe information
        Map<String,Schema.DescribeFieldResult> fieldInfo = objectAndFieldInfo.get(sObjectName);
        
        //we only need to go through the fields were passed to the method
        for(String fieldApiName : fieldApiNames){
            //process standard fields that have a help text
            if(fieldInfo.get(fieldApiName).getInlineHelpText() != null && !fieldInfo.get(fieldApiName).isCustom()){
                TranslatableMetadata fieldHelpText = new TranslatableMetadata();
                fieldHelpText.apiName = fieldApiName;
                fieldHelpText.parentObject = sObjectName;
                fieldHelpText.translatableLabel = fieldInfo.get(fieldApiName).getInlineHelpText();
                fieldHelpText.type = SFMD.type.CUSTOM_FIELD_HELP_TEXT;
                translatableFieldHelpTexts.add(fieldHelpText);
            }
        }
        System.debug(LoggingLevel.INFO,'getStandardFieldHelpTextTranslatables(): Returning '+ translatableFieldHelpTexts.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getStandardFieldHelpTextTranslatables(): '+JSON.serialize(translatableFieldHelpTexts));
        return translatableFieldHelpTexts;
        
    }
    
    /*
    * Creates TranslatableMetadata of type Picklist values based on a list of field api names
    * @param sObjectName: A valid sObject Name
    * @param fieldApiNames: A list representation of fields that belong to the sObjectName
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getCustomPicklistValuesTranslatables(String sObjectName,List<String> fieldApiNames){
        
        List<TranslatableMetadata> translatablePicklistValues = new List<TranslatableMetadata>();
        
        //validate that the object is valid and that the fields belong to the object    
        Map<String,Map<String,Schema.DescribeFieldResult>> objectAndFieldInfo = validateThatFieldsBelongToThisObject(sObjectName,fieldApiNames);
        
        // the validation passed, so we can get the field describe information
        Map<String,Schema.DescribeFieldResult> fieldInfo = objectAndFieldInfo.get(sObjectName);
        
        //we don't need to go through all the fields in the map, only the ones originally passed to the method    
        for(String fieldApiName : fieldApiNames){
            //process custom picklist fields only
            if( fieldInfo.get(fieldApiName).isCustom() && ( fieldInfo.get(fieldApiName).getType() == Schema.DisplayType.PICKLIST || fieldInfo.get(fieldApiName).getType() == Schema.DisplayType.MultiPicklist)){
                //each picklist value is a translatablemetadata object
                for(Schema.PicklistEntry value : fieldInfo.get(fieldApiName).getPicklistValues()){
                    
                    TranslatableMetadata picklistValue = new TranslatableMetadata();
                    picklistValue.type = SFMD.type.CUSTOM_PICKLIST_VALUE;
                    picklistValue.translatableLabel = value.getLabel();
                    //picklist values dont have an API name, so we construct one using the field name and the value
                    picklistValue.apiName = fieldApiName;
                    picklistValue.parentObject  = sObjectName;
                    translatablePicklistValues.add(picklistValue);
                    
                }
                
            }
        }
        System.debug(LoggingLevel.INFO,'getCustomPicklistValuesTranslatables(): Returning '+ translatablePicklistValues.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getCustomPicklistValuesTranslatables(): '+JSON.serialize(translatablePicklistValues));
        return translatablePicklistValues;
    }
    
        /*
    * Creates TranslatableMetadata of type Standard Picklist values based on a list of field api names
    * @param sObjectName: A valid sObject Name
    * @param fieldApiNames: A list representation of fields that belong to the sObjectName
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getStandardPicklistValuesTranslatables(String sObjectName,List<String> fieldApiNames){
        
        List<TranslatableMetadata> translatablePicklistValues = new List<TranslatableMetadata>();
        
        //validate that the object is valid and that the fields belong to the object    
        Map<String,Map<String,Schema.DescribeFieldResult>> objectAndFieldInfo = validateThatFieldsBelongToThisObject(sObjectName,fieldApiNames);
        
        // the validation passed, so we can get the field describe information
        Map<String,Schema.DescribeFieldResult> fieldInfo = objectAndFieldInfo.get(sObjectName);
        
        //we don't need to go through all the fields in the map, only the ones originally passed to the method    
        for(String fieldApiName : fieldApiNames){
            //process standard picklist fields only
            if( !fieldInfo.get(fieldApiName).isCustom() && (fieldInfo.get(fieldApiName).getType() == Schema.DisplayType.PICKLIST || fieldInfo.get(fieldApiName).getType() == Schema.DisplayType.MultiPicklist)){
                //each picklist value is a translatablemetadata object
                for(Schema.PicklistEntry value : fieldInfo.get(fieldApiName).getPicklistValues()){
                    
                    TranslatableMetadata picklistValue = new TranslatableMetadata();
                    picklistValue.type = SFMD.type.STANDARD_PICKLIST_VALUE;
                    picklistValue.translatableLabel = value.getLabel();
                    //picklist values dont have an API name, so we construct one using the field name and the value
                    picklistValue.apiName = fieldApiName;
                    picklistValue.parentObject  = sObjectName;
                    translatablePicklistValues.add(picklistValue);
                    
                }
                
            }
        }
        System.debug(LoggingLevel.INFO,'getStandardPicklistValuesTranslatables(): Returning '+ translatablePicklistValues.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getStandardPicklistValuesTranslatables(): '+JSON.serialize(translatablePicklistValues));
        return translatablePicklistValues;
    }
    
    /*
    * Creates TranslatableMetadata objects based on a list of field api names - This is intended to represent fields
    * that belong to a specific related list
    * @param sObjectName: A valid sObject Name
    * @param fieldApiNames: A list representation of fields that belong to the sObjectName
    * @return List<TranslatableMetadata>
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    */
    public List<TranslatableMetadata> getRelatedListCustomFieldsTranslatables(Map<String,List<String>> relatedObjectAndFields){
        
        List<TranslatableMetadata> allRelatedListFields = new List<TranslatableMetadata>();
        
        Map<String,List<String>> relatedObjectAndCustomFieldsOnly = new Map<String,List<String>>();
        
        
        //go through the objects passed to the method
        for(String relatedObject : relatedObjectAndFields.keySet()){
            
            //do we support this related list?
            if(isThisRelatedListSupported(relatedObject)){
                
                //if it's supported, does it have at least one custom field?
                List<String> customFields = new List<String>();
                Boolean doesItHaveCustomFields = false;
                
                for(String relatedField : relatedObjectAndFields.get(relatedObject)){
                    
                    System.debug(relatedField);
                    
                    if(relatedField.contains('__c')){
                        doesItHaveCustomFields = true;
                        customFields.add(relatedField);
                    }
                }
                //it it does have custom fields, we can translate those
                if(doesItHaveCustomFields){
                    relatedObjectAndCustomFieldsOnly.put(relatedObject,customFields);
                }
                
            }
            
        }
        //did we find at least one supported related list with custom fields?
        if(relatedObjectAndCustomFieldsOnly.size() > 0){
            for(String relatedObject : relatedObjectAndCustomFieldsOnly.keySet()){
                //run each object and its fields to the getCustomFieldLabelTranslatables() method
                List<TranslatableMetadata> relatedFieldsFromObject = getCustomFieldLabelTranslatables(relatedObject,relatedObjectAndCustomFieldsOnly.get(relatedObject));
                allRelatedListFields.addAll(relatedFieldsFromObject);
            }
            
            
            //the difference being that we need to show that this is a custom field from a related list
            for(TranslatableMetadata relatedListCustomField : allRelatedListFields){
                relatedListCustomField.type = SFMD.type.RELATED_LIST_FIELD;
            }
        }
        
        System.debug(LoggingLevel.INFO,'getRelatedListCustomFieldsTranslatables(): Returning '+ allRelatedListFields.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getRelatedListCustomFieldsTranslatables(): '+JSON.serialize(allRelatedListFields));
        return allRelatedListFields;
    }
    
    /*
    * Creates TranslatableMetadata of type picklist values based on a list of field api names - this is intended to represent
    * a list of picklist values on a specific related list
    * @param relatedObjectAndFields: A map representing an object and the fields on that object (related list + fields)
    * @throws InvalidSObjectNameException if the sObjectName is not a valid object name
    * @throws InvalidFieldNameException if the fieldApiName is not a valid field name for the object in question
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getRelatedListPicklistValuesTranslatables(Map<String,List<String>> relatedObjectAndFields){
        
        
        List<TranslatableMetadata> allRelatedPicklistValues = new List<TranslatableMetadata>();
        Map<String,List<String>> relatedObjectAndCustomFieldsOnly = new Map<String,List<String>>();
        
        //go through the objects passed to the method
        for(String relatedObject : relatedObjectAndFields.keySet()){
            
            //do we support this related list?
            if(isThisRelatedListSupported(relatedObject)){
        
                //if it's supported, does it have at least one custom field?
                List<String> customFields = new List<String>();
                Boolean doesItHaveCustomFields = false;
                
                for(String relatedField : relatedObjectAndFields.get(relatedObject)){
                    
                    
                    if(relatedField.contains('__c')){
                        doesItHaveCustomFields = true;
                        customFields.add(relatedField);
                    }
                }
                //it it does have custom fields, we can translate those
                if(doesItHaveCustomFields){
                    relatedObjectAndCustomFieldsOnly.put(relatedObject,customFields);
                }
                
            }
            
        }
        //did we find at least one supported related list with custom fields?
        if(relatedObjectAndCustomFieldsOnly.size() > 0){
            for(String relatedObject : relatedObjectAndCustomFieldsOnly.keySet()){
                
                List<String> fieldNames = new List<String>(relatedObjectAndCustomFieldsOnly.get(relatedObject));
                List<TranslatableMetadata> picklistValuesFromObject = getCustomPicklistValuesTranslatables(relatedObject,fieldNames);
                allRelatedPicklistValues.addAll(picklistValuesFromObject);
            }
            
            for(TranslatableMetadata picklistValue : allRelatedPicklistValues){
                picklistValue.type = SFMD.type.RELATED_LIST_PICKLIST_VALUE;
            }
        }
        
        
        System.debug(LoggingLevel.INFO,'getRelatedListPicklistValuesTranslatables(): Returning '+ allRelatedPicklistValues.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getRelatedListPicklistValuesTranslatables(): '+JSON.serialize(allRelatedPicklistValues));
        return allRelatedPicklistValues;
    }
    
    /*
    * Creates TranslatableMetadata of type buttons - this is intended to represent
    * a list of buttons on a specific related list
    * @param relatedObjectAndButtons: A map representing an object and the buttons on that object (related list + buttons)
    * @return List<TranslatableMetadata>
    */
    public List<TranslatableMetadata> getRelatedListButtonsTranslatables(Map<String,List<String>> relatedObjectAndButtons){
        
        List<TranslatableMetadata> relatedListButtons = new List<TranslatableMetadata>();
        
        for(String relatedObject: relatedObjectAndButtons.keySet()){
            
            for(String relatedListButton : relatedObjectAndButtons.get(relatedObject)){
                
                TranslatableMetadata relatedListButtonMD = new TranslatableMetadata();
                relatedListButtonMD.apiName = relatedListButton;
                relatedListButtonMD.parentObject = relatedObject;
                relatedListButtonMD.translatableLabel = LABEL_NOT_AVAILABLE_IN_APEX;
                relatedListButtonMD.type = SFMD.type.RELATED_LIST_BUTTON;
                relatedListButtons.add(relatedListButtonMD);
            }  
        }
        System.debug(LoggingLevel.INFO,'getRelatedListButtonsTranslatables(): Returning '+ relatedListButtons.size()+' TranslatableMetadata objects');
        System.debug(LoggingLevel.INFO,'getRelatedListButtonsTranslatables(): '+JSON.serialize(relatedListButtons));
        return relatedListButtons;
    }
    
    /*
     *************************************************** INTERNAL/PRIVATE METHODS *******************************************/
    
    /*
    * Populates allObjectsMap with valid sObjects in the org and their describe information.
    * This is used later on to easily obtain describe information for custom fields, picklist values, etc
    */
    private  void populateMapOfSobjectTypes(){
        
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            Schema.DescribeSObjectResult describeResult  = objTyp.getDescribe();
            String name =  describeResult.getName();
            allObjectsMap.put(name, describeResult);              
        }
    }
    
    
    /*
    * Checks if the page layout name adheres to the naming convetion of the Metadata API i.e [Object]-[Layout Name]
    * @param pageLayoutName: The name of a page layout.
    */
    private Boolean isThisAValidLayoutName(String pageLayoutName){
        
        List<String> characters = pageLayoutName.split('-');
        try{
            String objectName = characters[0];
            String layoutName = characters[1];
        }catch(Exception e){
            return false;
        }
        return true;
    }
    
    /*
    * This methods validates that the sObject name passed to it is valid, and that the list of field API names
    * actually belong to that object. This is reused through some of the internal methods for creating translations
    * on field labels, field help texts, etc.
    * @param sObjectName: The name of an sObject
    * @param fieldApiNames: A list of field API names
    * @return Map<String,Map<String,Schema.DescribeFieldResult>> a map of object to field describe information
    */
    private Map<String,Map<String,Schema.DescribeFieldResult>> validateThatFieldsBelongToThisObject(String sObjectName,List<String> fieldApiNames){
        
        System.debug(LoggingLevel.INFO,'validateThatFieldsBelongToThisObject(): Validating that these fields belong to the '+sObjectName+' object.');
        
        Map<String,Map<String,Schema.DescribeFieldResult>> objectAndFields = new Map<String,Map<String,Schema.DescribeFieldResult>>();
        Map<String,Schema.DescribeFieldResult> fieldDescribeResult = new Map<String,Schema.DescribeFieldResult>();
        
        //check if the object exists in the object map and thrown an exception if it doesn't
        if(allObjectsMap.get(sObjectName) == null){
            System.debug(LoggingLevel.ERROR,sObjectName+' is not a valid sObject API name.');
            throw new InvalidSObjectNameException(sObjectName+' is not a valid sObject API name.');      
        }else{
            
            //get the describe information for all the fields in the object
            Map<String, Schema.SObjectField> objectFields = allObjectsMap.get(sObjectName).fields.getMap();
            
            for(String fieldApiName : fieldApiNames){
                //check that this is a valid field for this object
                if(!objectFields.containsKey(fieldApiName)){
                    //throw exception if field is invalid
                    System.debug(LoggingLevel.ERROR,fieldApiName+' is not a valid field API name for the '+sObjectName+' sObject.');
                    throw new InvalidFieldNameException(fieldApiName+' is not a valid field API name for the '+sObjectName+' sObject.');
                }else{
                    //if the field is valid get the describe information and put it on a map
                    Schema.DescribeFieldResult fieldDescribe = objectFields.get(fieldApiName).getDescribe();
                    fieldDescribeResult.put(fieldApiName,fieldDescribe);
                    objectAndFields.put(sObjectName,fieldDescribeResult);
                }
            }
        }
        return objectAndFields;
    }
    
    /*
    * Because Salesforce uses aliases for related list names, we can't support every standard related list (because we can't forsee
    * what the alias for that object relationship will be).
    * 
    * Therefore, we only support related list from custom objects, or a subset of standard objects (see the supportedRelatedLists list below).
    * 
    * @param: relatedObjectName: The name of an SObject
    * @return true or false depending on whether the object is supported
    */
    private boolean isThisRelatedListSupported(String relatedObjectName){
             
        List<String> supportedRelatedLists = new List<String>{'Account,Contact,Case,Opportunity,Product,Order,LineItem,Campaign,CampaignMember,Contract,Asset'};

            if(supportedRelatedLists.contains(relatedObjectName) || relatedObjectName.contains('__c')){

                return true;
            }else{
           
                return false;
            }
    }
    
    /*
     * Used to thrown an exception when a page layout does not meet the Metadata API naming convention.
	*/
    private class InvalidPageLayoutNameException extends Exception{}
    
    /*
    * Used to thrown an exception when an object name does not exist in the org-wide object describe map. In other words
    * this exception will be thrown if an object name that does not exist in the org is used in some of the public methods of this class.
	*/
    private class InvalidSObjectNameException extends Exception{}
    
    /*
    * Used to thrown an exception when an field name does not exist in the org-wide field describe map. In other words
    * this exception will be thrown if an field name that does not exist in the org is used in some of the public methods of this class.
	*/
    private class InvalidFieldNameException extends Exception{}
    
}