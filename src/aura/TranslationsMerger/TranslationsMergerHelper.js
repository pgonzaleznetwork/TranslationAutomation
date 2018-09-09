({
    getPageLayoutTranslationContextRecords : function(cmp) {
        var action = cmp.get('c.getAllLayouts');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.data', response.getReturnValue());
                console.log("response: "+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().length < 1){
                    cmp.set("v.noResults",true);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})