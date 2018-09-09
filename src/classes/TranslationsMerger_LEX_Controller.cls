/*
 * @Author: Pablo Gonzalez - 2018
 * Controller class for the <c:TranslationsMerger> Lightning Component
*/
public class TranslationsMerger_LEX_Controller {
    
    /*
     * Returns a list that contains at least 100 the Layout_Translation_Info__c records in the org.
     * This is used to populate the lightning:dataTable component
	*/
    @AuraEnabled
    public static List<Translation_Context__c> getAllLayouts(){
        return [SELECT Id,Name, CreatedDate, Record_Link__c FROM Translation_Context__c WHERE Context_Type__c = 'Page Layout' ORDER BY CreatedDate DESC LIMIT 100];
    }
    
    /*
     * Passes a list of Layout_Translation_Info__c ids to the TranslationFileBuilder class.
     * That class is responsible for merging the contents of the records in question.
	*/
    @AuraEnabled
    public static void mergeFiles(List<Id> ids){
        System.debug('Ids passed from component: '+ids);
        
        try{
            TranslationFileBuilder.mergeTranslationKeyRecordsFromTheseTranslationContexts(ids);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    /*
     * Deletes a list of Translation_Context__c records. 
	*/
    @AuraEnabled
    public static void deleteTranslationRecords(List<Id> records){
        
        
        try{
            List<Translation_Context__c> recordsToDelete = [SELECT Id FROM Translation_Context__c WHERE Id IN :records];
            delete recordsToDelete;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

}