trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    TriggerDispatcher.run(new ContentDocumentLinkHandler(), Trigger.OperationType);  

}