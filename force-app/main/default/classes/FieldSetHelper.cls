public with sharing class FieldSetHelper {
    
    @AuraEnabled (cacheable=true)
    public static String getFieldsFromFieldSet(String strObjectApiName, String strfieldSetName){

        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){   
            Map<String, String> returnMap = new Map<String, String>();

            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName)?.newInstance());
            List<Schema.FieldSetMember> lstFSMember = 
                sObj?.getSObjectType()?.getDescribe()?.fieldSets.getMap().get(strfieldSetName)?.getFields();
                
            returnMap.put('FIELD_LIST',JSON.serialize(lstFSMember));
            returnMap.put('OBJECT_LABEL', sObj?.getSObjectType()?.getDescribe()?.getLabel());

            return JSON.serialize(returnMap);
        }                                                                 
        return null;
        
    }
}