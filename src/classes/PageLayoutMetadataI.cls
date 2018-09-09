public interface PageLayoutMetadataI {
    
    String getApiName();
    
    String getSObjectName();
    
    List<String> getSections();
    
     List<String> getButtons();
    
     List<String> getQuickActions();
    
     List<String> getPlatformActions();
    
     List<String> getFields();
       
     Map<String,List<String>> getRelatedListFields();
    
     Map<String,List<String>> getRelatedListButtons();

}