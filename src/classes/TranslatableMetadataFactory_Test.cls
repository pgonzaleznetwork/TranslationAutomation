@IsTest
public class TranslatableMetadataFactory_Test{
    
    @IsTest
    public static void testGetRelatedListPicklistValuesTranslatables(){
        Map<String,List<String>> relatedObjectAndFields = new Map<String,List<String>>();
        
        relatedObjectAndFields.put('Case',new List<String>{'Reason'});
        
        TranslatableMetadataFactory fac = TranslatableMetadataFactory.getInstance();
        fac.getRelatedListPicklistValuesTranslatables(relatedObjectAndFields);
    }
    
}