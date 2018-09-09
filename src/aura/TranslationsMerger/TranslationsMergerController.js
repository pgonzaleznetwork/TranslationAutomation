({
    init: function (cmp, event, helper) {
        
        /*
         * Called when the component is instantiated. It populates the data table with records from 
         * the Translation_Context object.
        */
        
        cmp.set('v.columns', [
            { label: 'Page Layout Name', fieldName: 'Record_Link__c', type: 'url',typeAttributes: {label: { fieldName: 'Name' }}},
            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date'}
            
        ]);
        helper.getPageLayoutTranslationContextRecords(cmp);
    },
    
    /*
    * Called when selecting rows from the data table. It ensures that the selected rows are kept in a component
    * attribute for easy retrieval and processing.
    */
    onSelection : function(cmp,event,helper){
        
        cmp.set("v.selectedRecords",event.getParam("selectedRows"));
        
        console.log("Selected records: "+cmp.get("v.selectedRecords"));
        
        
        
    },
    
    /*
    * Called when the Merge Translation Files button is clicked. 
    * It passes the selected rows to the mergeFiles apex controller method, which in turn
    * passes the ids to the TranslationFileBuilder class. 
     */
    submitMergeRecords : function(cmp,event,helper){
        
        var selectedRecords = cmp.get("v.selectedRecords");
        var selectedIds = [];
        
        for (var i = 0; i < selectedRecords.length; i++){
            selectedIds.push(selectedRecords[i].Id);
        }
        
        var action = cmp.get('c.mergeFiles');
        action.setParams({
            ids:selectedIds
        });
        action.setCallback(this, $A.getCallback(function (response) {
            
            var toast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                toast.setParams({
                    "title":"Success!",
                    "type": "success",
                    "message":"The translations files have been merged. Go to the Translation Files documents folder to find the result"
                });
                toast.fire();
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                
                if(errors[0] && errors[0].message){
                    toast.setParams({
                        "title":"Error!",
                        "message":errors[0].message,
                        "type":"error"
                    });
                    toast.fire();
                }
                
                
                
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
        
    },
    
    /*
     * Called when the Delete Translation Files button is clicked. It passes the ids 
     * of the selected rows to the deleteTranslationRecords apex controller method, where the records are deleted.
    */
    deleteRecords : function(component,event,helper){
        var selectedRecords = component.get("v.selectedRecords");
        var selectedIds = [];
        
        for (var i = 0; i < selectedRecords.length; i++){
            selectedIds.push(selectedRecords[i].Id);
        }
        
        var action = component.get('c.deleteTranslationRecords');
        action.setParams({
            records:selectedIds
        });
        action.setCallback(this, $A.getCallback(function (response) {
            
            var toast = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                toast.setParams({
                    "title":"Success!",
                    "type": "success",
                    "message":"Translation Record Deleted"
                });
                toast.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                
                if(errors[0] && errors[0].message){
                    toast.setParams({
                        "title":"Error!",
                        "message":errors[0].message,
                        "type":"error"
                    });
                    toast.fire();
                }
                
                
                
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
        
        
        
    }
})