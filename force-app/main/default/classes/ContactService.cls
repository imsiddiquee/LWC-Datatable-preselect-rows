public with sharing class ContactService {
    public static void preventToCreateMoreThanOnePrimaryContact(List<Contact> newRecordContactList) {
        Map<Id, Contact> accIdPrimaryConMap = new Map<Id, Contact>();

        Set<Id> accIdsSet = new Set<Id>();
        for (Contact con : newRecordContactList) {
            if (con.Level__c == 'Primary' && con.AccountId != null) {
                accIdsSet.add(con.AccountId);
            }
        }

        for (Contact con : [
            SELECT Id, Level__c, AccountId
            FROM Contact
            WHERE Level__c = 'Primary' AND AccountId IN :accIdsSet
        ]) {
            accIdPrimaryConMap.put(con.AccountId, con);
        }

        for (Contact con : newRecordContactList) {
            if (con.Level__c == 'Primary' && con.AccountId != null && accIdPrimaryConMap.get(con.AccountId) != null) {
                con.addError('You can\'t create more than one primary contact.');
            }
        }
    }

    public static void preventToUpdateMoreThanOnePrimaryContact(
        Map<Id, Contact> newRecordContactMap,
        Map<Id, Contact> oldRecordContactMap
    ) {
        Map<Id, Contact> accIdPrimaryConMap = new Map<Id, Contact>();

        Set<Id> accIdsSet = new Set<Id>();
        for (Contact con : newRecordContactMap.values()) {
            if (
                con.Level__c != oldRecordContactMap.get(con.Id).Level__c &&
                con.AccountId != null &&
                con.Level__c == 'Primary'
            ) {
                accIdsSet.add(con.AccountId);
            }
        }

        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE Level__c = 'Primary' AND AccountId IN :accIdsSet]) {
            accIdPrimaryConMap.put(con.AccountId, con);
        }

        for (Contact con : newRecordContactMap.values()) {
            if (
                con.Level__c != oldRecordContactMap.get(con.Id).Level__c &&
                con.AccountId != null &&
                con.Level__c == 'Primary' &&
                accIdPrimaryConMap.get(con.AccountId) != null
            ) {
                con.addError('Account has already primary contact, you can not update new contact as primary.');
            }
        }
    }

    //rollup summary with-out group by functionality

    public static void calculateNumberOfContactsOnInsert(Map<Id, Contact> newRecordContactsMap) {
        Map<Id, List<Id>> accIdConListMap = new Map<Id, List<Id>>();

        Set<Id> accIdsSet = new Set<Id>();
        for (Contact con : newRecordContactsMap.values()) {
            if (con.AccountId != null) {
                accIdsSet.add(con.AccountId);
            }
        }

        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIdsSet]) {
            if (!accIdConListMap.containsKey(con.AccountId)) {
                accIdConListMap.put(con.AccountId, new List<Id>());
            }
            accIdConListMap.get(con.AccountId).add(con.Id);
        }

        for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accIdsSet]) {
            System.debug('Total contacts are:: ' + accIdConListMap.get(acc.Id).size());
        }
    }

    public static void calculateNumberOfContactsOnUpdate(
        Map<Id, Contact> newRecordContactsMap,
        Map<Id, Contact> oldRecordContactsMap
    ) {
        Map<Id, List<Id>> newAccIdConListMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> oldAccIdConListMap = new Map<Id, List<Id>>();

        //current account related contacts
        Set<Id> accIdsSet = new Set<Id>();
        for (Contact con : newRecordContactsMap.values()) {
            if (
                newRecordContactsMap.get(con.Id).AccountId != oldRecordContactsMap.get(con.Id).AccountId &&
                con.AccountId != null
            ) {
                accIdsSet.add(con.AccountId);
            }
        }

        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIdsSet]) {
            if (!newAccIdConListMap.containsKey(con.AccountId)) {
                newAccIdConListMap.put(con.AccountId, new List<Id>());
            }
            newAccIdConListMap.get(con.AccountId).add(con.Id);
        }

        for (Id acc : newAccIdConListMap.keySet()) {
            System.debug('Current Account Contacts:: ' + newAccIdConListMap.get(acc).size());
        }

        //old account related contacts
        accIdsSet = new Set<Id>();
        for (Contact con : oldRecordContactsMap.values()) {
            if (
                newRecordContactsMap.get(con.Id).AccountId != oldRecordContactsMap.get(con.Id).AccountId &&
                con.AccountId != null
            ) {
                accIdsSet.add(con.AccountId);
            }
        }

        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIdsSet]) {
            if (!oldAccIdConListMap.containsKey(con.AccountId)) {
                oldAccIdConListMap.put(con.AccountId, new List<Id>());
            }
            oldAccIdConListMap.get(con.AccountId).add(con.Id);
        }

        for (Id acc : oldAccIdConListMap.keySet()) {
            System.debug('Current Account Contacts:: ' + oldAccIdConListMap.get(acc).size());
        }
    }

    //rollup summary with group by functionality

    public static void calculateNumberOfContacts_groupBy_OnDelete(Map<Id, Contact> oldRecordContactsMap) {
        Map<Id, Account> accMap = new Map<Id, Account>();

        Set<Id> accIdsSet = new Set<Id>();
        for (Contact con : oldRecordContactsMap.values()) {
            if (con.AccountId != null) {
                accIdsSet.add(con.AccountId);
            }
        }

        if (accIdsSet != null && accIdsSet.size() > 0) {
            for (AggregateResult agrResult : [
                SELECT Count(Id) conCount, AccountId
                FROM Contact
                WHERE AccountId IN :accIdsSet AND Id NOT IN :oldRecordContactsMap.values()
                GROUP BY AccountId
            ]) {
                Account acc = new Account();
                acc.Id = (Id) agrResult.get('AccountId');
                acc.Description = (String) agrResult.get('conCount');
                accMap.put(acc.Id, acc);
            }
        }

        if (!accMap.isEmpty()) {
            update accMap.values();
        }
    }

    public static void calculateNumberOfContacts_groupBy_OnInsert(Map<Id, Contact> newRecordContactsMap) {
        Map<Id, Account> accMap = new Map<Id, Account>();

        Set<Id> accIdsSet = new Set<Id>();
        for (Contact con : newRecordContactsMap.values()) {
            if (con.AccountId != null) {
                accIdsSet.add(con.AccountId);
            }
        }

        if (accIdsSet != null && accIdsSet.size() > 0) {
            for (AggregateResult agrResult : [
                SELECT Count(Id) conCount, AccountId
                FROM Contact
                WHERE AccountId IN :accIdsSet
                GROUP BY AccountId
            ]) {
                Account acc = new Account();
                acc.Id = (Id) agrResult.get('AccountId');
                acc.Description = String.valueOf(agrResult.get('conCount'));

                accMap.put(acc.Id, acc);
            }
        }

        if (!accMap.isEmpty()) {
            update accMap.values();
        }
    }
}
