trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after undelete, after delete) {

    TriggerDispatcher.run( new AccountTriggerHandler() , Trigger.OperationType );

/*
    if(Trigger.isInsert)
    {
        if (Trigger.isBefore) {
           
          // AccountTriggerHandler.Before_Insert_UpdateRating(Trigger.new);    
        }
        else if (Trigger.isAfter) {
          // AccountTriggerHandler.After_Insert_CreateRelatedOpp(Trigger.new);    
           
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isBefore)
        {
           // AccountTriggerHandler.Before_Update_UpdatePhoneDescription(Trigger.new,Trigger.oldMap);    
        }
        else if(Trigger.isAfter)
        {
            //AccountTriggerHandler.After_Update_UpdateRelatedOppPhone(Trigger.new,Trigger.oldMap);    
        }
        
    }

    if (Trigger.isDelete) {
        if(Trigger.isBefore)
        {
            //Employee record cannot be deleted is active is true.
           // AccountTriggerHandler.Before_delete_CheckAccountStatus(Trigger.Old);    
        }
        else if(Trigger.isAfter)
        {
            //When employee record is deleted then update left employee count on account.
           // AccountTriggerHandler.After_delete_CheckAccountStatus(Trigger.Old);    
        }
        
    }

    if (Trigger.isAfter && Trigger.isUndelete) {
        //AccountTriggerHandler.After_Undelete_UpdateEmployee(Trigger.new);
        
    }
    
    */
}