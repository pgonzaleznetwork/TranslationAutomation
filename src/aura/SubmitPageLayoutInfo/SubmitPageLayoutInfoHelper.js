({
    /*
     * Function to be called from the controller when a request to create translation_key__c records has been successful. 
    */
    showSuccessMessage : function() {
        var toast = $A.get("e.force:showToast");
        toast.setParams({
            "title":"Success!",
            "type": "success",
            "message":"The translation keys for this page layout have been retrieved. You'll find them in the Translation Context tab."
        });
        toast.fire();
        $A.get('e.force:refreshView').fire();
    },
    
    /*
     * Function to be called from the controller when a request to create translation_key__c records has failed.
     * 
     * @param response: The response object returned from the Apex controller. 
    */
    showErrorMessage : function(response){
        
        var toast = $A.get("e.force:showToast");
        
        var errors = response.getError();
        if(errors[0] && errors[0].message){
            toast.setParams({
                "title":"Error!",
                "message":errors[0].message,
                "type":"error"
            });
            toast.fire();
        }
        
    }
})