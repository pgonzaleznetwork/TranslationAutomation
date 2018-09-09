# Translation Automation Package Architecture


## What is this document?

This document describes the high level architecture of the Translation Automation package which can be found here. 

This document is organized in a way that follows the normal “workflow” of the app, which makes it easier to follow through the architecture. 

## Who is this for?

This document is useful to anyone using the app, as you might need to troubleshoot issues (though we tried to kill as much bugs as possible). 

# Getting the Translatable Metadata from a Page Layout


## Lightning Component: SubmitPageLayoutInfo

This is the main entry point of the application. This component allows you to enter a page layout name and get all the translation keys for all the items present in the page layout.

From a technical point of view, this component is responsible for passing a layout name to the PageLayoutTranslatorFacade Apex class, which is the class responsible for coordinating the interaction of multiple classes that result in the Translation_Key__c records being inserted.

## PageLayoutTranslatorFacade

This class coordinates the communication of the following classes in order to return a list of TranslationKey objects, which represent a specific metadata that can be translated via the translation workbench. It assumes that the metadata objects are all referenced on a specific page layout.

The main method of this class is getTranslationKeysFromThisPageLayout(), which does the following:

Instantiates a PageLayoutMetadata object - this in turns gets all the metadata from a specific page layout.
Once it has the page layout metadata, it passes it to the TranslatableMetadataFactory class. This class looks at the metadata, determines what is translatable (not every metadata on a page layout is translatable) and returns a list of TranslatableMetadata objects.
Once the TranslatableMetadata objects are known, they are organised based on their type and sent to the TranslationKeyFactory class. This class is responsible for creating the specific translation workbench keys, based on the type of translatable metadata.

## TranslatableMetadataFactory

This class takes string representations of a particular metadata types and transform them into a TranslatableMetadata object

The idea is that if you have a string representation of a specific metadata type, you can extract more information from it to be able to create a TranslatableMetadata object, which represents a metadata type that can be translated via the Translation Workbench.

This class has one method per metadata type from a page layout. In future releases, more methods could be added to this class to support more metadata types. At the time of this writing, some of the methods are:

getLayoutSectionTranslatables()
getLayoutButtonsTranslatables()
getCustomFieldLabelsTranslatables()
Etc…


As mentioned earlier, this class creates TranslatableMetadata objects. A TranslatableMetadata has the following properties:

Type: The type of metadata
Parent Object: If applicable, the object that this metadata belongs to
API Name: The API name of the metadata
Translatable Label: The specific label that can be translated for this metadata. For example, a record type can have 2 translatable labels: its name and its description (this would be represented as 2 different TranslatableMetadata objects, with different types).

## TranslationKeyFactory

This is the class that is responsible for creating the actual translation workbench keys for a particular metadata type, based on the attributes of that metadata (which come from a TranslatableMetadata object, see the previous section).

There is an inner interface called TranslationKeyGeneratorI. For each metadata type that can be translated, there’s an inner class that implements the TranslationKeyGeneratorI interface, and in particular, the generateTranslationKeys() method. 

Each class is responsible to provide the specific implementation that specifies how a translation workbench key should look like for a specific metadata type. For example, these are some of the implementations found in this class:

CustomFieldLabelKeyGenerator - specificies how to create translation workbench keys for custom field labels
CustomFieldHelpTextGenerator - specifies how to create translation workbench keys from the help text of custom fields
Etc…

All the implementations are then registered to a map of type and implementation. The types of translatable metadata are globally defined in the SFMD class. 

Finally, the main entry point of this class is the generateKeys() method. This method calls the specific implementation of TranslationKeyGeneratorI based on the type that is passed to the method. Because all the inner classes implement this interface, the caller doesn’t know which implementation is being used, and this class itself doesn’t know either. 

This makes it very easy to add new implementations for new metadata types that might be supported in the future. We simply add the type to the SFMD class, we create a specific implementation and we register against that type in the map. 

## SubmitPageLayoutInfo_LEX_Controller

Back to the controller of the Lightning Component, we get the list of TranslationKeys created by the TranslationKeyFactory class. The keys are inserted to the database using the insertTranslationKeys() method.

Once the keys are inserted, we call the TranslationFileBuilder class, in order to create the translation file.

## TranslationFileBuilder

In the context of generating the translation file for a specific page layout, the method that is relevant is createTranslationFileFromTranslationKeyRecords(). 

The method is heavily commented and it’s easy to follow. In a nutshell, it queries the records that were just inserted to the database, and creates a tab delimited file using the record values. It then adds the attachment to the Translation_Context__c record. 


# Merging or Deleting existing Page Layout Records

## Lightning Component: TranslationsMerger

This component has a few responsibilities, which can be seen in the javascript controller:

Query all existing Translation_Context__c records
Merge existing Translation_Context__c records into a single tab-delimited file
Delete existing Translation_Context__c records

For merging, the mergeFiles() method of the Apex Controller,  TranslationsMerger_LEX_Controller.

This method passes the ids of the Translation_Context__c records to the TranslationFileBuilder.mergeTranslationKeyRecordsFromTheseTranslationContexts(ids) method.

This method, similar to the one explained in the previous section, builds a tab-delimited file using the field values from all the Translation_Key__c records that are children of the Translation_Context__c records. 

The TranslationsMerger_LEX_Controller class also has the methods for querying and deleting the Translation_Context__c records.


# Merging or Deleting existing Page Layout Records

## Lightning Component: CompareTranslationFiles

This component compares an untranslated file (from the Translation Workbench) with a translation file provided from the app itself. Because the files can be very large, all the logic is contained in the javascript controller of the lightning component. The code is commented so it should be easy enough to follow the process.
