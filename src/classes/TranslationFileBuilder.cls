/*
 * This class creates a translation file (using the format of the Translation Workbench) using the contents of multiple
 * Translation_Key__c records.
 * 
 * The translation file is then attached to the Translation_Context record.
 * 
 * @author Pablo Gonzalez - 2018
*/

public class TranslationFileBuilder {
    
    /*************************************** INSTANCE VARIABLES *******************************************/
    
    /*
     * The headers of the file. The file will have multiple values separated by tabs.
	*/
    private static String translationFileContents = 'METADATA TYPE'+'\t'+'KEY'+'\t'+'DEFAULT LABEL'; 
    
    
    /*************************************** PUBLIC METHODS *******************************************/


    /*
     * Creates an attachment on a particular Translation_Context__c record. The contents of the attachment are the field
     * values found on the Translation_Key__c records that are child of the current Translation_Context__c record.
     * 
     * This creates a file very similar to the translation workbench files.
	*/
    public static void createTranslationFileFromTranslationKeyRecords(Id translationContextId){
        
        Translation_Context__c context = [SELECT Name FROM Translation_Context__c WHERE Id = :translationContextId LIMIT 1][0];
          	
        /*
         * Add the details of all the Translation_Key__c records, separated by tabs.
		*/
        for(Translation_Key__c translationKeyRecord : [SELECT Type__c,Key__c,Default_Label__c FROM Translation_Key__c WHERE Translation_Context__c = :translationContextId ORDER BY Name ASC]){
           
            translationFileContents = translationFileContents+'\r\n'+translationKeyRecord.Type__c+'\t'+translationKeyRecord.Key__c+'\t'+translationKeyRecord.Default_Label__c;
        }
        
        /*add the contents to the attachment record and attach to the parent record.*/
        Attachment translationFile = new Attachment();
        Blob documentBlob = Blob.valueOf(translationFileContents);
        translationFile.Name = context.Name+'_Translations_'+Date.today();
        translationFile.Body = documentBlob;
        translationFile.ParentId = translationContextId;
       
        insert translationFile;
        
    }
    
    /*
     * Gets the values from multiple Translation_Key__c records and creates a file of unique keys. 
	*/
    public static void mergeTranslationKeyRecordsFromTheseTranslationContexts(List<Id> translationContexts){
  		
        /*
         * This map will be used to organize the Translation_Key__c based on their type. This is needed so that the file
         * shows all the metadata of a particular type in a single section, rather than multiple metadata types being spreaded all
         * over the file.
		*/
        Map<String,List<Translation_Key__c>> typeOfTranslationKeyMap = getMapOfSupportedMetadataTypes();
   	
        /*
         * Go through all the translation_key__c records and add them to the list that belongs to their type.
		*/
        for(Translation_Key__c translationKeyRecord : [SELECT Type__c,Key__c,Default_Label__c FROM Translation_Key__c WHERE Translation_Context__c IN :translationContexts ORDER BY Name ASC]){
           
            List<Translation_Key__c> listOfSpecificTranslationType = typeOfTranslationKeyMap.get(translationKeyRecord.Type__c);
            listOfSpecificTranslationType.add(translationKeyRecord);
        }
        
        /*
         * Add the contents to the file, on a type by type basis
		*/
        for(String type : typeOfTranslationKeyMap.keySet()){
            for(Translation_Key__c translationKeyRecord : typeOfTranslationKeyMap.get(type)){
                 translationFileContents = translationFileContents+'\r\n'+translationKeyRecord.Type__c+'\t'+translationKeyRecord.Key__c+'\t'+translationKeyRecord.Default_Label__c;
            }
        }
        
   
        Blob documentBlob = Blob.valueOf(translationFileContents);  
        Folder fol;
        
        try{
            fol = [SELECT Id, Name FROM Folder WHERE DeveloperName = 'Translation_Files' LIMIT 1][0];
        }catch(Exception e){
            throw new NoFolderFoundException('The request cannot be completed because a folder named Translation Files was not found',e);
        }
   	
        Document doc = new Document();
        doc.Body = documentBlob;
        doc.Name = 'Merged_Translations_'+Date.today();
        doc.FolderId = fol.Id;
       
        insert doc;
        
    }
    
    
    /*************************************** PRIVATE METHODS *******************************************/
    
    /*
     * Creates a map of supported metadata types and lists of translation_key__c records. This map is then
     * used to retrieve the list of translation_key__c records of a particular type of metadata.
     * 
     * Items are added to the lists and the lists are later used to create a new translation file, sorted by metadata type. 
	*/
    private static Map<String,List<Translation_Key__c>> getMapOfSupportedMetadataTypes(){
        
        /*
         * Get the supported metadata types (ENUM) from the SFMD class and add them to a list of Strings.
		*/
        List<SFMD.type> supportedMetadataTypesEnum = SFMD.type.values();
        
        List<String> supportedMetadataTypes = new List<String>();
        
        for(SFMD.type type : supportedMetadataTypesEnum){
            supportedMetadataTypes.add(type.name());
        }
        
        /*
         * For each type of metadata, create a new list that can be used to add Translation_Key__c records of that type
		*/
        Map<String,List<Translation_Key__c>> typeOfTranslationKeyMap = new Map<String,List<Translation_Key__c>>();
        
        for(String type : supportedMetadataTypes){
            typeOfTranslationKeyMap.put(type,new List<Translation_Key__c>());
        }
        return typeOfTranslationKeyMap;
    }
    
        
    private class NoFolderFoundException extends Exception{
        
    }
    
}