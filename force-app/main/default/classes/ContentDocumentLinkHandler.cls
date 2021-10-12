public with sharing class ContentDocumentLinkHandler implements TriggerInterface {
    public static void beforeInsert(List<sObject> newRecordsList) {
        System.debug('beforeInsert');
    }

    public static void afterInsert(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        if (CheckRecursiveCallbacktrigger.runOnceAfter()) {
            List<ContentDocumentLink> newRecordCDLsList = (List<ContentDocumentLink>) newRecordsList;
            ContentDocumentLinkService.updateAccountFileInsert(newRecordCDLsList);
        }
        System.debug('afterInsert');
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) {
        System.debug('beforeUpdate');
    }

    public static void afterUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) {
        System.debug('afterUpdate');
    }

    public static void beforeDelete(List<sObject> oldRecordsList, Map<Id, sObject> oldRecordsMap) {
        System.debug('beforeDelete');
    }

    public static void afterDelete(Map<Id, sObject> oldRecordsMap) {
        System.debug('afterDelete');
    }

    public static void afterUnDelete(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        System.debug('afterUnDelete');
    }
}
