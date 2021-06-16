trigger ContactTrigger on Contact (before insert,before update,after insert,after delete) {

    if (trigger.isBefore) {
        if (trigger.isInsert) {
           // ContactTriggerHandler.Before_Insert_PreventCreatePrimaryContact(Trigger.new);
        }
        else if(trigger.isUpdate)
        {
           // ContactTriggerHandler.Before_Update_PreventPrimaryContactUpdate(Trigger.newMap,Trigger.oldMap);        
        }
        
    }

    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            //ContactTriggerHandler.After_Insert_CalculateNumberofContacts(Trigger.new);
        }

        if(trigger.isDelete)
        {
            
            //ContactTriggerHandler.After_Delete_CalculateNumberofContacts(Trigger.old);
        }
    }
}