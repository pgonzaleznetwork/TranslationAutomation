({
    // comapre untranslated
    compareTranslationFiles : function(component, event, helper) {
        // get the value from untranslatedtext input field in the component
        var untranslatedField = component.find("untranslatedText");
        var untranslatedText = untranslatedField.get("v.value");
        
        /* The file contain multiple lines so we split lines for further processing. 
         * The following variables support adding the contents
         * of those lines in different maps, so that we can compare them later against the contents of another file*/
        var unTranslatedFileLines = untranslatedText.split("\n");
        var unTranslatedFileKeys = new Map();
        /*
         * Layout sections on the untranslated file will have an additional number that is not visible
         * in the layout info file, for a given layout section name. For example:
         * 
         * untranslated: Layout_Section_Name_1
         * layout info: Layout_Section_Name <<<< The number is missing here
         * 
         * For that reason, we create a map of layout sections, so that we can compare them excluding the number
         * and store the matching result in the map - the entries in the map will have the number
        */
        var layoutSectionsMap = new Map();
        // get the value from layout info text input field in the component
        var layoutInfoField = component.find("layoutInfoText");
        var layoutInfoText = layoutInfoField.get("v.value");
        //split lines from layout info
        var layoutInfoFileLines = layoutInfoText.split("\n");
        // generating map from unTranslated Files
        for(var key in unTranslatedFileLines) {
            //stringVariable has one complete line of unTranslated Files
            var lineFromUntranslatedFile = unTranslatedFileLines[key];
            //get the key
            var untranslatedTranslationKey = lineFromUntranslatedFile.substring(0, lineFromUntranslatedFile.lastIndexOf('\t'));
            untranslatedTranslationKey = untranslatedTranslationKey.trim();
            //seperately conserve LayoutSection key for further use
            if (untranslatedTranslationKey.startsWith("LayoutSection")) {
                layoutSectionsMap.set(untranslatedTranslationKey.substring(0,untranslatedTranslationKey.lastIndexOf('_')),untranslatedTranslationKey);
                untranslatedTranslationKey = untranslatedTranslationKey.substring(0,untranslatedTranslationKey.lastIndexOf('_'));
            }
            //get the default label
            var untranslatedDefaultLabel = lineFromUntranslatedFile.substring( lineFromUntranslatedFile.lastIndexOf('\t'),lineFromUntranslatedFile.length );
            untranslatedDefaultLabel  = untranslatedDefaultLabel.trim();
            //put key and label into map
            unTranslatedFileKeys.set(untranslatedTranslationKey,untranslatedDefaultLabel);
        }
        // add header of CSV file
        var csvFileContents = 'Metadata Type,Key,Default Label\n';
        
        // generate csv from layout info
        for(var keyi in layoutInfoFileLines) {
			//stringVariablei has one complete line of layout info
            var lineFromLayoutInfoFile = layoutInfoFileLines[keyi];
            
            //layout info has three section 1# Metadata Type		2# Key		3# Default Label
            //get the key, 
            //its in the middle
            var layoutInfoTranslationKey = lineFromLayoutInfoFile.substring(lineFromLayoutInfoFile.indexOf('\t'),lineFromLayoutInfoFile.lastIndexOf('\t')); 
            //get the Metadata Type
            var metadataType = lineFromLayoutInfoFile.substring(0,lineFromLayoutInfoFile.indexOf('\t'));
            layoutInfoTranslationKey = layoutInfoTranslationKey.trim();
            //get the Default Label
            var layoutInfoDefaultLabel = lineFromLayoutInfoFile.substring( lineFromLayoutInfoFile.lastIndexOf('\t'),lineFromLayoutInfoFile.length );
            layoutInfoDefaultLabel = layoutInfoDefaultLabel.trim();
            // get keys which are untranslated or standard fields
            if(unTranslatedFileKeys.has(layoutInfoTranslationKey) || layoutInfoTranslationKey.includes('_Use_Rename_Tabs_And_Labels')) {
            	// change key for layoutsection from key peserve from unTranslated files
                if ((layoutInfoTranslationKey.startsWith("LayoutSection") && layoutSectionsMap.has(layoutInfoTranslationKey)) ) {
                    layoutInfoTranslationKey = layoutSectionsMap.get(layoutInfoTranslationKey);
                }
                //add csv file content
                csvFileContents = csvFileContents + metadataType + ',' + layoutInfoTranslationKey + ',' + layoutInfoDefaultLabel + '\n';
            }

        }
        
        //download csv
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvFileContents);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Untranslated_PageLayout_Items.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file

    }
})