({
    
     /*
       * Sends the submited value to the Apex method getTranslationKeysFromThisPageLayout
         * The method passes the page layout name to the PageLayoutTranslatorFacade class
         * which is responsible for creating the Translation_Key__c records with all the 
         * translatable items found in the page layout.
        */
    sendPageLayoutNameToApexController : function(component, event, helper) {
        
        component.set("v.showSpinner",true);
       
        /*
         * Get the value that was submitted on the input field
        */
        var field = component.find("layoutField");
        var value = field.get("v.value");
        
        /*
         * Pass this value to the Apex method
        */
        var action = component.get("c.getTranslationKeysFromThisPageLayout");
        action.setParams({
            layoutName:value
        });
        
        /*
         * Called when the Apex method returns. 
        */
        action.setCallback(this, $A.getCallback(function (response) {
            
            var toast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showSuccessMessage();
            } else if (state === "ERROR") {                
                helper.showErrorMessage(response);
                component.set("v.showSpinner",false);
            }
        }));
        
        $A.enqueueAction(action);
    }    
})