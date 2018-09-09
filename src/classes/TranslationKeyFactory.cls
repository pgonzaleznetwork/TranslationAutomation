/*
* This class process TranslatableMetadata objects and transform them into TranslationKey objects, which represent a key-value pair
* of translatable metadata that can be translated with the Translation Workbench
* 
* @Author - Pablo Gonzalez
*/
public class TranslationKeyFactory {
    
    /**************************************************** INSTANCE VARIABLES *******************************************/
    
    /*
    * This is a map holding multiple implementations of the TranslationKeyGeneratorI interface, which is implemented by multiple
    * subclasses in order to specificy how to generate the translation workbench key for a specific metadata type.
    */
    private Map<SFMD.type,TranslationKeyGeneratorI> keyGenerationStrategies = new Map<SFMD.type,TranslationKeyGeneratorI>();
    
    /**************************************************** PUBLIC METHODS *******************************************/
    
    
    /*
     * Constructor. Calls the registerTranslationKeyGeneratorIStrategies() method to register multiple implementations of
     * TranslationKeyGeneratorI into a map. 
	*/
    public TranslationKeyFactory(){
        registerTranslationKeyGeneratorIStrategies();
    }
    
    public List<TranslationKey> generateKeys(Map<SFMD.type,List<TranslatableMetadata>> translatableMetadataObjects){
        
        List<TranslationKey> keys = new List<TranslationKey>();
        
        
        for(SFMD.type type : translatableMetadataObjects.keySet()){
            
            
            TranslationKeyGeneratorI strategy = keyGenerationStrategies.get(type);
            
            
            List<TranslationKey> typeBasedTranslationKeys = strategy.generateTranslationKeys(translatableMetadataObjects.get(type));
            keys.addAll(typeBasedTranslationKeys);
        }
        return keys;
        
    }
    
    /**************************************************** PRIVATE METHODS *******************************************/
    
    /*
     * Each metadata type has a different translation workbench key type. We represent each type with a class that implements 
     * the TranslationKeyGeneratorI inteface and each class is responsible for determining how to generate the keys
     * for a given metadata type.
     * 
     * This maps makes it easy to get the required implementation of TranslationKeyGeneratorI at run time, based on the type of metadata
     * that needs to be translated. 
	*/
    private void registerTranslationKeyGeneratorIStrategies(){
        keyGenerationStrategies.put(SFMD.type.CUSTOM_FIELD_LABEL,new CustomFieldLabelKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.CUSTOM_FIELD_HELP_TEXT,new CustomFieldHelpTextKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.STANDARD_FIELD_HELP_TEXT,new StandardFieldHelpTextKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.LAYOUT_SECTION_NAME,new LayoutSectionNameKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.DETAIL_BUTTON,new DetailButtonKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.STANDARD_PICKLIST_VALUE,new StandardPicklistValueKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.CUSTOM_PICKLIST_VALUE,new CustomPicklistValueKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.PLATFORM_ACTION,new PlatformActionKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.QUICK_ACTION,new QuickActionKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.RELATED_LIST_BUTTON,new RelatedListButtonKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.RELATED_LIST_FIELD,new RelatedListFieldKeyGenerator());
        keyGenerationStrategies.put(SFMD.type.RELATED_LIST_PICKLIST_VALUE,new RelatedListPicklistValueKeyGenerator());
    }
    

    
    
    /**************************************************** INTERFACE AND SUBCLASSES *******************************************/
    
    
    /*
     * Interface that subclasses implement to specify how to generate the workbench key for a given metadata type
	*/
    public Interface TranslationKeyGeneratorI {
        
        List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata);
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to custom field labels
	*/
    public class CustomFieldLabelKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> customFieldLabelKeys = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type custom field.
         * The generated key is in the format CustomField.ObjectName.FieldAPINameWithoutUnderscoreC.FieldLabel
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.CUSTOM_FIELD_LABEL;
                translationKey.key = 'CustomField.'+md.parentObject+'.'+md.apiName.substringBefore('__c')+'.FieldLabel';
                translationKey.defaultLabel = md.translatableLabel;
                customFieldLabelKeys.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'CustomFieldLabelKeyGenerator(): Returning '+ customFieldLabelKeys.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'CustomFieldLabelKeyGenerator(): '+JSON.serialize(customFieldLabelKeys));
            return customFieldLabelKeys;
        }
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to custom field help text
	*/
    public class CustomFieldHelpTextKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> customFieldHelpTextKeys = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type custom field help text.
         * The generated key is in the format CustomField.ObjectName.FieldAPINameWithoutUnderscoreC.HelpText
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                TranslationKey translationKey = new TranslationKey();
                translationKey.key = 'CustomField.'+md.parentObject+'.'+md.apiName.substringBefore('__c')+'.HelpText';
                translationKey.type = SFMD.type.CUSTOM_FIELD_HELP_TEXT;
                translationKey.defaultLabel = md.translatableLabel;
                customFieldHelpTextKeys.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'CustomFieldHelpTextKeyGenerator(): Returning '+ customFieldHelpTextKeys.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'CustomFieldHelpTextKeyGenerator(): '+JSON.serialize(customFieldHelpTextKeys));
            return customFieldHelpTextKeys;
        }
                
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to standard field help text
	*/
    public class StandardFieldHelpTextKeyGenerator implements TranslationKeyGeneratorI{
        
         List<TranslationKey> standardFieldHelpTextKeys = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type standard field help text.
         * The generated key is in the format StandardFieldHelp.ObjectName.FieldAPIName.HelpText
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
             for(TranslatableMetadata md : metadata){
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.STANDARD_FIELD_HELP_TEXT;
                translationKey.key = 'StandardFieldHelp.'+md.parentObject+'.'+md.apiName+'.HelpText';
                translationKey.defaultLabel = md.translatableLabel;
                standardFieldHelpTextKeys.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'StandardFieldHelpTextKeyGenerator(): Returning '+ standardFieldHelpTextKeys.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'StandardFieldHelpTextKeyGenerator(): '+JSON.serialize(standardFieldHelpTextKeys));
            return standardFieldHelpTextKeys;
        }
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to page layout section names
	*/
    public class LayoutSectionNameKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> layoutSectionNames = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Layout Section names.
         * The generated key is in the format LayoutSection.ObjectName.LayoutName.LayoutSection
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
           
            for(TranslatableMetadata md : metadata){
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.LAYOUT_SECTION_NAME;
                translationKey.key = 'LayoutSection.'+md.parentObject+'.'+md.apiName.substringBefore('.')+'.'+md.translatableLabel;
                translationKey.defaultLabel = md.translatableLabel;
                layoutSectionNames.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'LayoutSectionNameKeyGenerator(): Returning '+ layoutSectionNames.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'LayoutSectionNameKeyGenerator(): '+JSON.serialize(layoutSectionNames));
            return layoutSectionNames;
        }
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to page layout section names
	*/
    public class DetailButtonKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> detailButtonNames = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Layout Section names.
         * The generated key is in the format ButtonOrLink.ObjectName.buttonApiName
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.DETAIL_BUTTON;
                translationKey.key = 'ButtonOrLink.'+md.parentObject+'.'+md.apiName;
                translationKey.defaultLabel = md.translatableLabel;
                detailButtonNames.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'DetailButtonKeyGenerator(): Returning '+ detailButtonNames.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'DetailButtonKeyGenerator(): '+JSON.serialize(detailButtonNames));
            return detailButtonNames;
        }
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to standard picklist values
	*/
    public class CustomPicklistValueKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> customPicklistValues = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Custom Picklist Valie.
         * The generated key is in the format PicklistValue.ObjectName.FieldApiNameWitoutUnderscoreC.picklistValue
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.CUSTOM_PICKLIST_VALUE;
                translationKey.key = 'PicklistValue.'+md.parentObject+'.'+md.apiName.substringBefore('__c')+'.'+md.translatableLabel;
                translationKey.defaultLabel = md.translatableLabel;
                customPicklistValues.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'CustomPicklistValueKeyGenerator(): Returning '+ customPicklistValues.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'CustomPicklistValueKeyGenerator(): '+JSON.serialize(customPicklistValues));
            return customPicklistValues;
        }
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to standard picklist values
	*/
    public class StandardPicklistValueKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> standardPicklistValues = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Custom Picklist Valie.
         * The generated key is in the format PicklistValue.Standard.ObjectAndFieldNameAlias.picklistValue
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                
                 TranslationKey translationKey = new TranslationKey();
                
                /*This is done because the industry field is shared among different objects so it
                 has a very specific format that needs to be harcoded*/
                if(md.apiName == 'Industry'){
                    translationKey.key = 'PicklistValue.Standard'+'.'+md.apiName.toLowerCase()+'.'+md.translatableLabel;
                }
                
                /*This is done because the StageName field has a different key that doesn't match the field name*/
                if(md.apiName == 'StageName'){
                    translationKey.key = 'PicklistValue.Standard.opportunityStage.'+md.translatableLabel;
                }
                
                /*This is done because the this field is shared among the Account and Lead objects so it has a very specific format*/
                if(md.apiName == 'AccountSource' || md.apiName == 'LeadSource'){
                    translationKey.key = 'PicklistValue.Standard.LeadSource.'+md.translatableLabel;
                }
                
                /*If the field is not any of the above, then the standard key generation mechanism applies*/
                if(md.apiName != 'AccountSource' && md.apiName != 'Lead Source' && md.apiName != 'StageName' && md.apiName != 'Industry'){
                    translationKey.key = 'PicklistValue.Standard.'+md.parentObject.toLowerCase()+md.apiName+'.'+md.translatableLabel;
                }
                
                
                translationKey.type = SFMD.type.STANDARD_PICKLIST_VALUE;
                translationKey.defaultLabel = md.translatableLabel;
                standardPicklistValues.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'StandardPicklistValueKeyGenerator(): Returning '+ standardPicklistValues.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'StandardPicklistValueKeyGenerator(): '+JSON.serialize(standardPicklistValues));
            return standardPicklistValues;
        }
        
    }
    
    /*
     * Implementation of TranslationKeyGeneratorI specific to Quick Actions
	*/
    public class QuickActionKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> quickActions = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Quick Action. 
         * The generated key is in the format QuickAction.ActionApiName
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.QUICK_ACTION;
                translationKey.key = 'QuickAction.'+md.apiName;
                translationKey.defaultLabel = md.translatableLabel;
                quickActions.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'QuickActionKeyGenerator(): Returning '+ quickActions.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'QuickActionKeyGenerator(): '+JSON.serialize(quickActions));
            return quickActions;
        }
        
    }
    
    public class PlatformActionKeyGenerator implements TranslationKeyGeneratorI{
        
        List<TranslationKey> platformActions = new List<TranslationKey>();
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Platform Action. 
         * The generated key is in the format QuickAction.ActionApiName
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            for(TranslatableMetadata md : metadata){
                
                TranslationKey translationKey = new TranslationKey();
                translationKey.type = SFMD.type.PLATFORM_ACTION;
                translationKey.key = 'QuickAction.'+md.apiName;
                translationKey.defaultLabel = md.translatableLabel;
                platformActions.add(translationKey);
            }
            
            System.debug(LoggingLevel.INFO,'PlatformActionKeyGenerator(): Returning '+ platformActions.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'PlatformActionKeyGenerator(): '+JSON.serialize(platformActions));
            return platformActions;
        }
        
    }
    
        public class RelatedListButtonKeyGenerator implements TranslationKeyGeneratorI{
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Related List Button. 
         * The generated key is in the format ButtonOrLink.ObjectName.buttonApiName
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            /*
             * We reuse the key generation strategy for buttons
			*/
            
            Map<SFMD.type,List<TranslatableMetadata>> metadataTypes = new Map<SFMD.type,List<TranslatableMetadata>>();
            metadataTypes.put(SFMD.type.DETAIL_BUTTON,metadata);
            
            List<TranslationKey> relatedListButtons = new TranslationKeyFactory().generateKeys(metadataTypes);

            
            /*
             * The difference is that the type should be RELATED_LIST_BUTTONS so we update the type here
			*/
            for(TranslationKey key : relatedListButtons){
                key.type = SFMD.type.RELATED_LIST_BUTTON;
            }
            System.debug(LoggingLevel.INFO,'RelatedListButtonKeyGenerator(): Returning '+ relatedListButtons.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'RelatedListButtonKeyGenerator(): '+JSON.serialize(relatedListButtons));
            return relatedListButtons;
        }
        
    }
    
    public class RelatedListFieldKeyGenerator implements TranslationKeyGeneratorI{
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Related List Field. 
         * The generated key is in the format CustomField.ObjectName.FieldAPINameWithoutUnderscoreC.FieldLabel
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            /*
             * We reuse the key generation strategy for custom field labels, as the logic is the same
			*/
            
            Map<SFMD.type,List<TranslatableMetadata>> metadataTypes = new Map<SFMD.type,List<TranslatableMetadata>>();
            metadataTypes.put(SFMD.type.CUSTOM_FIELD_LABEL,metadata);
            
            List<TranslationKey> relatedListFields = new TranslationKeyFactory().generateKeys(metadataTypes);

            
            /*
             * The difference is that the type should be RELATED_LIST_FIELD so we update the type here
			*/
            for(TranslationKey key : relatedListFields){
                key.type = SFMD.type.RELATED_LIST_FIELD;
            }
            System.debug(LoggingLevel.INFO,'RelatedListFieldKeyGenerator(): Returning '+ relatedListFields.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'RelatedListFieldKeyGenerator(): '+JSON.serialize(relatedListFields));
            return relatedListFields;
        }
        
    }
    
        public class RelatedListPicklistValueKeyGenerator implements TranslationKeyGeneratorI{
        
        /*
         * Takes a list of TranslatableMetadata objects and creates a translation workbench key of type Related List Picklist Value. 
         * The generated key is in the format QuickAction.ActionApiName
         * 
         * @param metadata: List of TranslatableMetatadata objects
         * @return: A list of TranslationKey objects
		*/
        public List<TranslationKey> generateTranslationKeys(List<TranslatableMetadata> metadata){
            
            /*
             * We reuse the key generation strategy for custom picklist values, as the logic is the same.
             * Standard fields are not supported for related lists since their name is not the API name, but
             * an arbitrary alias defined by Salesforce.
			*/
            
            Map<SFMD.type,List<TranslatableMetadata>> metadataTypes = new Map<SFMD.type,List<TranslatableMetadata>>();
            metadataTypes.put(SFMD.type.CUSTOM_PICKLIST_VALUE,metadata);
            
            List<TranslationKey> relatedListPicklistValues = new TranslationKeyFactory().generateKeys(metadataTypes);

            
            /*
             * The difference is that the type should be RELATED_LIST_FIELD so we update the type here
			*/
            for(TranslationKey key : relatedListPicklistValues){
                key.type = SFMD.type.RELATED_LIST_PICKLIST_VALUE;
            }
            System.debug(LoggingLevel.INFO,'RelatedListPicklistValueKeyGenerator(): Returning '+ relatedListPicklistValues.size()+' TranslationKey objects');
        	System.debug(LoggingLevel.INFO,'RelatedListPicklistValueKeyGenerator(): '+JSON.serialize(relatedListPicklistValues));
            return relatedListPicklistValues;
        }
        
    }
        
}