trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if (trigger.isAfter) {
        if(trigger.isInsert)
        {
            //ContentDocumentLinkTriggerHandler.After_Insert_UpdateAccountonFileCount(trigger.new);
        }
        
    }

}