/*
* This class allows you to get the most common items of a page layout in a string representation
* @author: Pablo Gonzalez - 2018
*/

public class PageLayoutMetadataMock implements PageLayoutMetadataI{
    

    
		/**************************************************** PUBLIC METHODS *******************************************/
    
    
     public PageLayoutMetadataMock(String pageLayoutName){
        
         if(pageLayoutName == 'TestInvalidName'){
             throw new PageLayoutNotFoundTestException('This name is invalid');
         }
     
     }
    
    
    public String getApiName(){
        return 'Account-Account Layout';
    }
    
    public String getSObjectName(){
        return 'Account';
    }
    
    public List<String> getSections(){
        
        List<String> sections = new List<String>{'Important Links','Detail'};
        
        return sections;
    }
    
    public List<String> getButtons(){
        
        List<String> buttons = new List<String>{'Detail Button 1','Detail Button 2'};
        return buttons;
    }
    
    public List<String> getQuickActions(){
        
        List<String> quickActions = new List<String>{'Quick Action 1','Quick Action 2'};
        return quickActions;
    }
    
    public List<String> getPlatformActions(){
        
         List<String> platformActions = new List<String>{'Platform Action 1','Platform Action 2'};
        return platformActions;
    }
    
    public List<String> getFields(){
        
        List<String> fields = new List<String>{'AccountNumber','AnnualRevenue', 'AccountSource'};
        
        return fields;
    }
    
    
    public Map<String,List<String>> getRelatedListFields(){
        
        Map<String,List<String>> relatedListAndFields = new Map<String,List<String>>();
        relatedListAndFields.put('Contact',new List<String>{'Email'});
        relatedListAndFields.put('Case',new List<String>{'Reason'});
        
        return relatedListAndFields;
    }
    
    public Map<String,List<String>> getRelatedListButtons(){
        
        Map<String,List<String>> relatedListAndButtons = new Map<String,List<String>>();
        relatedListAndButtons.put('Contact',new List<String>{'New Contact Custom'});
        
        return relatedListAndButtons;
    }
    
    private class PageLayoutNotFoundTestException extends Exception{}
    
}