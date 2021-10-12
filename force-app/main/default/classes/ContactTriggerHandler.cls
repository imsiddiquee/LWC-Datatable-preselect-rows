public with sharing class ContactTriggerHandler implements TriggerInterface {
    public static void beforeInsert(List<sObject> newRecordsList) {
        if (CheckRecursiveCallbacktrigger.runOnceBefore()) {
            List<Contact> newRecordContactList = (List<Contact>) newRecordsList;
            ContactService.preventToCreateMoreThanOnePrimaryContact(newRecordContactList);
        }
        System.debug('beforeInsert');
    }

    public static void afterInsert(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        System.debug('CheckRecursiveCallbacktrigger.runOnce()' + CheckRecursiveCallbacktrigger.runOnce());
        if (CheckRecursiveCallbacktrigger.runOnceAfter()) {
            Map<Id, Contact> newRecordContactsMap = (Map<Id, Contact>) newRecordsMap;
            //ContactService.calculateNumberOfContactsOnInsert(newRecordContactsMap);
            ContactService.calculateNumberOfContacts_groupBy_OnInsert(newRecordContactsMap);
        }
        System.debug('afterInsert');
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) {
        if (CheckRecursiveCallbacktrigger.runOnce()) {
            Map<Id, Contact> newRecordContactsMap = (Map<Id, Contact>) newRecordsMap;
            Map<Id, Contact> oldRecordContactsMap = (Map<Id, Contact>) oldRecordsMap;

            ContactService.preventToUpdateMoreThanOnePrimaryContact(newRecordContactsMap, oldRecordContactsMap);
        }

        System.debug('beforeUpdate');
    }

    public static void afterUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) {
        if (CheckRecursiveCallbacktrigger.runOnceAfter()) {
            Map<Id, Contact> newRecordContactsMap = (Map<Id, Contact>) newRecordsMap;
            Map<Id, Contact> oldRecordContactsMap = (Map<Id, Contact>) oldRecordsMap;

            ContactService.calculateNumberOfContactsOnUpdate(newRecordContactsMap, oldRecordContactsMap);
        }
    }

    public static void beforeDelete(List<sObject> oldRecordsList, Map<Id, sObject> oldRecordsMap) {
        if (CheckRecursiveCallbacktrigger.runOnceBefore()) {
            Map<Id, Contact> oldRecordContactsMap = (Map<Id, Contact>) oldRecordsMap;
            ContactService.calculateNumberOfContacts_groupBy_OnDelete(oldRecordContactsMap);
        }
    }

    public static void afterDelete(Map<Id, sObject> oldRecordsMap) {
        System.debug('afterDelete');
    }

    public static void afterUnDelete(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        System.debug('afterUnDelete');
    }
}
