public with sharing class AccountTriggerHandler implements TriggerInterface {
    public static void beforeInsert(List<sObject> newRecordsList) {
        System.debug('beforeInsert');
    }

    public static void afterInsert(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        if (CheckRecursiveCallbacktrigger.runOnce()) {
            List<Account> accountList = (List<Account>) newRecordsList;
            AccountService.contactCreateFromAccountInfo(accountList);
        }
    }

    public static void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) {
        //List<Contact> existingRecors = (List<Contact>)newRecordsMap.values();
        System.debug('beforeUpdate');
    }

    public static void afterUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap) {
        if (CheckRecursiveCallbacktrigger.runOnce()) {
            Map<Id, Account> existingRecordMap = (Map<Id, Account>) newRecordsMap;
            Map<Id, Account> oldRecordMap = (Map<Id, Account>) oldRecordsMap;

            AccountService.opportunityCreateFromAccountInfo(existingRecordMap, oldRecordMap);
        }
    }

    public static void beforeDelete(List<sObject> oldRecordsList, Map<Id, sObject> oldRecordsMap) {
        Map<Id, Account> oldRecordMap = (Map<Id, Account>) oldRecordsMap;
        for (Account acc : oldRecordMap.values()) {
            acc.addError('Account can not be deleted');
        }
    }

    public static void afterDelete(Map<Id, sObject> oldRecordsMap) {
        System.debug('afterDelete');
    }

    public static void afterUnDelete(List<sObject> newRecordsList, Map<Id, sObject> newRecordsMap) {
        System.debug('afterUnDelete');
    }
}
