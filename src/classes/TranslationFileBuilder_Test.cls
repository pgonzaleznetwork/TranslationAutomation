@IsTest
/*
 * @author - Pablo Gonzalez
 * Provides test and negative tests for the TranslationFileBuilder class.
*/
public class TranslationFileBuilder_Test {
    
    
    public static testMethod void testBuildTranslationFile(){
        
        Test.startTest();
        
        SubmitPageLayoutInfo_LEX_Controller.getTranslationKeysFromThisPageLayout('Account-Account Layout');
        
       
        
        Test.stopTest();
        
         List<Translation_Context__c> records = [SELECT Id FROM Translation_Context__c];
        
        //confirm that one translation record was created
        System.assert(records.size() == 1,'No Layout_Translation_Info__c were created.');
        
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE parentId = :records[0].Id];
        
        //confirm that one attachment was created for the translation record
        System.assert(attachments.size() == 1,'There should be one attachment under the newly created record');
        
    }
  
}