@IsTest
/*
 * @author: Pablo Gonzalez - 2018
 * Provides test methods for the TranslationsMergerApex class.
*/
public class TranslationsMergerApex_Test {
    
    public static testMethod void testGetAllLayouts(){
        
        TranslationsMerger_LEX_Controller.getAllLayouts();
        
    }
    
    public static testMethod void testDeleteRecords_Positive(){
        
        SubmitPageLayoutInfo_LEX_Controller.getTranslationKeysFromThisPageLayout('Account-Account Layout');
        
        List<Translation_Context__c> records = [SELECT Id FROM Translation_Context__c];
        
  
        
        List<Id> idsToDelete = new List<Id>();
        
        for(Translation_Context__c rec : records){
            idsToDelete.add(rec.Id);
        }
        
        Test.StartTest();
        TranslationsMerger_LEX_Controller.deleteTranslationRecords(idsToDelete);
        Test.StopTest();
        
       
    }
    
    public static testMethod void testDeleteRecords_Negative(){
        
        
        List<Id> idsToDelete;
        

        Test.StartTest();
        
        try{
            TranslationsMerger_LEX_Controller.deleteTranslationRecords(idsToDelete);
        }catch(Exception e){
            System.assert(e != null);
            System.debug(e);
        }
        
        
        Test.StopTest();

    }
    
    public static testMethod void testMergeFiles_Positive(){
        
        SubmitPageLayoutInfo_LEX_Controller.getTranslationKeysFromThisPageLayout('Account-Account Layout');
        SubmitPageLayoutInfo_LEX_Controller.getTranslationKeysFromThisPageLayout('Case-Case Layout');
        
        List<Translation_Context__c> records = [SELECT Id FROM Translation_Context__c];
        
        
        //confirm that 2 translation records were created
        System.assert(records.size() == 2);
        
        //add the records to a list
        List<Id> recordIds = new List<Id>();
        
        
        for(Translation_Context__c l : records){
            recordIds.add(l.Id);
        }
        
        
        Test.StartTest();
        
        TranslationsMerger_LEX_Controller.mergeFiles(recordIds);
        
        Test.StopTest();
        
        //confirm that a document was created with the correct name
        String expectedDocumentName = 'Merged_Translations_'+Date.today();
        List<Document> docs = [SELECT Id, Name FROM Document WHERE Name = :expectedDocumentName];
        
        System.assert(docs.size() == 1,'No documents were found with the name '+expectedDocumentName);      
              
    }
    
    public static testMethod void testMergeFiles_Negative(){
        
        //create an empty list of ids.
        List<Id> badIds;
        
        Test.StartTest();
        
        try{
            TranslationsMerger_LEX_Controller.mergeFiles(badIds);
        }catch(Exception e){
            System.assert(e != null,'An exception should have been throw if the ids are empty');
        }
        
        
        Test.StopTest();
        
    }

}