trigger ContentDocumentTrigger on ContentDocument  (before delete) {
    if(trigger.isBefore && trigger.isDelete)
    {
       // ContentDocumentTriggerHandler.Before_Delete_updateAccountonFileDelete(trigger.old);
    }

}