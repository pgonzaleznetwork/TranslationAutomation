/*
 * This class coordinates the communication of the following classes in order to return a list of TranslationKey object, which represent a specific
 * metadata that can be translated via the translation workbench. It assumes that the metadata objects are all referenced on a specific page layout.
 * 
 * Classes:
 * 
 * PageLayoutMetadata: Exports the metadata of a page layout.
 * TranslatableMetadataFactory: Creates TranslatableMetadata objects. These represent metadata types that can be translated (and their attributes)
 * TranslationKeyFactory: Creates the metadata type-specific translation keys.
 * 
 * @Author: Pablo Gonzalez
*/
public class PageLayoutTranslatorFacade {
    
    /**************************************************** INSTANCE VARIABLES *******************************************/
    
    private TranslatableMetadataFactory translatableMDFactory;
    private TranslationKeyFactory translationKeyFactory;
    private Map<SFMD.type,List<TranslatableMetadata>> translatableTypes;
    
    /**************************************************** PUBLIC METHODS *******************************************/
    
    
    /*
     * Constructor
	*/
    public PageLayoutTranslatorFacade(){
        translatableMDFactory = TranslatableMetadataFactory.getInstance();
        translationKeyFactory = new TranslationKeyFactory();
        translatableTypes = new Map<SFMD.type,List<TranslatableMetadata>>();
    }
    
    /*
     * Extracts all the available metadata from a page layout.
     * Then transforms those items into TranslatableMetadata objects
     * Finally, they are transformed into specific Translation Keys
     * 
     * @param pageLayoutName: The name of a page layout as per the Metadata API naming convention
     * Return List<TranslationKey>
	*/
    public List<TranslationKey> getTranslationKeysFromThisPageLayout(String pageLayoutName){
        
        /*
         * Get the layout metadata. 
		*/
        PageLayoutMetadataI layout;
        
        if(Test.isRunningTest()){
            layout = new PageLayoutMetadataMock(pageLayoutName);
        }else{
            layout = new PageLayoutMetadata(pageLayoutName);
        }
        
             
        /*
         * Get the layout buttons as TranslatableMetadata objects
		*/
        List<TranslatableMetadata> customButtons = translatableMDFactory.getLayoutButtonsTranslatables(layout.getApiName(), layout.getButtons());
        
        /*
         * Get the quick actions as TranslatableMetadata objects
		*/
		List<TranslatableMetadata> quickActions = translatableMDFactory.getQuickActionsTranslatables(layout.getSObjectName(), layout.getQuickActions());
        
        /*
         * Get the lightning/platform as TranslatableMetadata objects
		*/
        List<TranslatableMetadata> platformActions = translatableMDFactory.getPlatformActionsTranslatables(layout.getPlatformActions());
        
        /*
         * Get the layout sections as TranslatableMetadata objects
		*/
		List<TranslatableMetadata> layoutSections = translatableMDFactory.getLayoutSectionsTranslatables(layout.getApiName(), layout.getSections());
        
        /*
         * Get the custom field labels as TranslatableMetadata objects
		*/
        List<TranslatableMetadata> customFieldLabels = translatableMDFactory.getCustomFieldLabelTranslatables(layout.getSObjectName(),layout.getFields());
        
        /*
         * Get the custom field help text as TranslatableMetadata objects
		*/ 
        List<TranslatableMetadata> customFieldHelpText = translatableMDFactory.getCustomFieldHelpTextTranslatables(layout.getSObjectName(),layout.getFields());
        
        /*
         * Get the standard field help text as TranslatableMetadata objects
		*/
        List<TranslatableMetadata> standardFieldHelpText = translatableMDFactory.getStandardFieldHelpTextTranslatables(layout.getSObjectName(),layout.getFields());
		
        /*
         * Get the layout buttons as TranslatableMetadata objects
		*/
		List<TranslatableMetadata> customPicklistVals = translatableMDFactory.getCustomPicklistValuesTranslatables(layout.getSObjectName(),layout.getFields());
        
        //get standard picklist values
        List<TranslatableMetadata> standardPicklistVals = translatableMDFactory.getStandardPicklistValuesTranslatables(layout.getSObjectName(),layout.getFields());
		  
        //get related list buttons
        List<TranslatableMetadata> RelatedListButtons = translatableMDFactory.getRelatedListButtonsTranslatables(layout.getRelatedListButtons());
        
        //get related list fields
        List<TranslatableMetadata> RelatedListFields = translatableMDFactory.getRelatedListCustomFieldsTranslatables(layout.getRelatedListFields());
        
        //get related list picklist values
        List<TranslatableMetadata> RelatedListPicklistValues = translatableMDFactory.getRelatedListCustomFieldsTranslatables(layout.getRelatedListFields());

		/*
		 * Arranage all translatable metadata objects in a map, according to their type
		*/
        translatableTypes.put(SFMD.type.DETAIL_BUTTON,customButtons);
        translatableTypes.put(SFMD.type.QUICK_ACTION,quickActions);
        translatableTypes.put(SFMD.type.PLATFORM_ACTION,platformActions);
        translatableTypes.put(SFMD.type.LAYOUT_SECTION_NAME,layoutSections);
        translatableTypes.put(SFMD.type.CUSTOM_FIELD_LABEL,customFieldLabels);
        translatableTypes.put(SFMD.type.CUSTOM_FIELD_HELP_TEXT,customFieldHelpText);
        translatableTypes.put(SFMD.type.STANDARD_FIELD_HELP_TEXT,standardFieldHelpText);
        translatableTypes.put(SFMD.type.CUSTOM_PICKLIST_VALUE,customPicklistVals);
        translatableTypes.put(SFMD.type.STANDARD_PICKLIST_VALUE,standardPicklistVals);
        translatableTypes.put(SFMD.type.RELATED_LIST_BUTTON,RelatedListButtons);   
        translatableTypes.put(SFMD.type.RELATED_LIST_FIELD,RelatedListFields);
        translatableTypes.put(SFMD.type.RELATED_LIST_PICKLIST_VALUE,RelatedListPicklistValues);
        
        
        /*
         * Send the map to the translationKeyFactory so that it can generate the keys for all the translatable metadata objects
		*/
        List<TranslationKey> workbenchKeys = translationKeyFactory.generateKeys(translatableTypes);
                
        return workbenchKeys;
        

    }

}