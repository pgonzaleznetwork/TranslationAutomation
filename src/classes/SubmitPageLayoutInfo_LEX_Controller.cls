/*
 * @Author: Pablo Gonzalez - 2018
 * This class is the controller of the <c:SubmitPageLayoutInfo> Lightning Component.
 * The test methods for this class can be found on the SubmitPageLayoutInfoApex_Test class.
*/
public class SubmitPageLayoutInfo_LEX_Controller {
    
    
    /*
     * @Description: Passes a page layout name to the PageLayoutTranslatorFacade class, where all the translatable items
     * of the page layout are retrieved and converted into Translation Workbench Keys
     * 
     * @param layoutName: The name of a page layout as per the Metadata API naming convention.
	*/
    @AuraEnabled
    public static void getTranslationKeysFromThisPageLayout(String layoutName){
        
        layoutName = layoutName.trim();
        List<TranslationKey> translationKeys;
        
        
        try{
            translationKeys = new PageLayoutTranslatorFacade().getTranslationKeysFromThisPageLayout(layoutName);
        }catch(Exception e){
            logErrorAndThrowLightningException(e);
        }
        
        insertTranslationKeys(layoutName,translationKeys);
        
    }
    
    /*
     * @Description: Takes a list of TranslationKey and converts them into Translation_Key__c records. 
     * It then inserts them to the database.
     * 
     * @param layoutName: The name of a page layout. This method does not validate that this is a real page layout name,
     * as this is only used to create a Translation_Context__c record, which is a parent record that holds all the Translation_Key__c records.
     * 
     * @param keys: A list of TranslationKey objects that represent translation workbench keys. 
	*/
    private static void insertTranslationKeys(String layoutName,List<TranslationKey> keys){
        
        List<Translation_Key__c> translationKeysToInsert = new List<Translation_Key__c>();
            
        try{
			
            Translation_Context__c translationContext = new Translation_Context__c(Name=layoutName,Context_Type__c='Page Layout'); 
        	insert translationContext;
            
            for(TranslationKey key : keys){
                Translation_Key__c translationKeyRecord = new Translation_Key__c();
                translationKeyRecord.Translation_Context__c = translationContext.Id;
                translationKeyRecord.Key__c = key.key;
                translationKeyRecord.Default_Label__c = key.defaultLabel;
                translationKeyRecord.Type__c = key.type.name();
                translationKeysToInsert.add(translationKeyRecord);
            
            }
            
            insert translationKeysToInsert;
            /*once the Translation_Key__c records are inserted, we pass their Translation_Context__c record to this method
            which takes care of creating a translation file based on their fields*/
            TranslationFileBuilder.createTranslationFileFromTranslationKeyRecords(translationContext.Id);
            
        }catch(Exception e){
            logErrorAndThrowLightningException(e);
        }
    }
    
    /*
     * @Description Internal method used to throw a lightning exception and log the error on the debug log. A lightning
     * exception is thrown because this class is expected to be used by a lightning component. 
	*/
    private static void logErrorAndThrowLightningException(Exception e){
        
        System.debug(LoggingLevel.ERROR, e.getMessage()+' - '+e.getLineNumber()+' - '+e.getStackTraceString());
        throw new AuraHandledException('Error: '+e.getMessage());
        
    }
        

}