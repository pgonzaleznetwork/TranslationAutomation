/*
    * Test class for the PageLayoutMetadata class. At the time of this writing, Page Layouts in are visible from apex test methods, but
    * they cannot be created through test methods (unlike normal sObjects).
    * 
    * This means that we cannot trully test that any of the methods in this class behave as expected, as we have on control over the subscriber's org
    * page layouts.
    * 
    * @Author - Pablo Gonzalez
*/


@IsTest
public class PageLayoutMetadata_Test {
    
    public static String layoutName;
    
    /*
    * Because page layout information varies from org to org and it is accessible
    * from tests methods, we can't use a real page layout for testing the methods in this class (as we can't know of the page layout name exists).
    * Instead, we ask the subscriber of the package to specify a "real" layout name in a custom metadata type, and we use
    * that layout to run the tests
	*/
    private static void getLayoutNameFromMetadataType(){
        
        List<Page_Layout_Translation_Manager_Setting__mdt> settings = [SELECT Page_Layout_Name_in_Tests__c  FROM 
                                                                       Page_Layout_Translation_Manager_Setting__mdt WHERE QualifiedApiName='Default'];
        
        if(settings.size() < 1){
            throw new ListException('There is not a Custom Metadata Type of type Page_Layout_Translation_Manager_Setting__mdt '+
                                    ' with a qualifiedApiName of Default');
        }else{
            layoutName = settings[0].Page_Layout_Name_in_Tests__c;
            System.debug('Metadata Type: '+layoutName);
        }
        
        
    }
    
    public static testMethod void testConstructor_Positive(){
        
        getLayoutNameFromMetadataType();
        
        Test.startTest();
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        Test.stopTest();
        
    }
    
    public static testMethod void testConstructor_Negative(){
        
        Test.startTest();
        try{
            PageLayoutMetadata layout = new PageLayoutMetadata('Account-Made Up Invalid Name');
        }catch(Exception e){
            System.assert(e.getTypeName() == 'PageLayoutMetadata.PageLayoutNotFoundException','An invalid API name should have thrown an exception');
        }
        
        Test.stopTest();
        
    }
    
    public static testMethod void testGetSObjectName(){
        
        getLayoutNameFromMetadataType();
        
        Test.startTest();
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        Test.stopTest();
        
        List<String> parts = layoutName.split('-');
        String sObjectName = parts[0];
   
        
        System.assert(layout.getSObjectName() == sObjectName,'The sObject Name should match the first page of a valid page layout name');
        System.assert(layout.getApiName() == layoutName,'The Api Name should match the layout name passed to the constructor');
        
    }
    

    
    public static testMethod void testGetSections(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getSections();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetButtons(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getButtons();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetQuickActions(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getQuickActions();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetPlatformActions(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getPlatformActions();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetFields(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getFields();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetRelatedLists(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getRelatedLists();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetRelatedListButtons(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getRelatedListButtons();
        Test.stopTest();
        
    }
    
    public static testMethod void testGetRelatedListFields(){
        
        getLayoutNameFromMetadataType();
        
        PageLayoutMetadata layout = new PageLayoutMetadata(layoutName);
        
        Test.startTest();
        layout.getRelatedListFields();
        Test.stopTest();
        
    }
    
}