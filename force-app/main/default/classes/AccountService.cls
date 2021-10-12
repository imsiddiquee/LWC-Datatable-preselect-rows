public with sharing class AccountService {
    public static void contactCreateFromAccountInfo(List<Account> newRecordsList) {
        List<Contact> contactList = new List<Contact>();

        for (Account acc : newRecordsList) {
            Contact conObject = new Contact();
            conObject.AccountId = acc.Id;
            conObject.LastName = acc.Name;
            contactList.add(conObject);
        }
        if (!contactList.isEmpty()) {
            insert contactList;
        }

        System.debug('contactCreateFromAccountInfo');
    }

    public static void opportunityCreateFromAccountInfo(
        Map<Id, Account> existingRecorMap,
        Map<Id, Account> oldRecorMap
    ) {
        List<Opportunity> oppList = new List<Opportunity>();

        for (Account acc : existingRecorMap.values()) {
            if ((acc.Rating != oldRecorMap.get(acc.Id).Rating) && acc.Rating == 'Warm') {
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.Name = acc.Name;
                opp.StageName = 'Prospecting';
                opp.CloseDate = System.today();
                oppList.add(opp);
            }
        }
        if (!oppList.isEmpty()) {
            insert oppList;
        }
    }

    public static void updateAccountFileInsert(List<ContentDocumentLink> docList) {
        Map<Id, Account> accMap = new Map<Id, Account>();

        Set<Id> accIdsSet = new Set<Id>();
        for (ContentDocumentLink docLink : docList) {
            if (docLink.LinkedEntityId != null && String.valueOf(docLink.LinkedEntityId).startsWithIgnoreCase('001')) {
                accIdsSet.add(docLink.LinkedEntityId);
            }
        }

        if (accIdsSet.size() > 0) {
            for (AggregateResult agrObj : [
                SELECT COUNT(Id) flCount, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :accIdsSet
                GROUP BY LinkedEntityId
            ]) {
                Account acc = new Account();
                acc.Id = (Id) agrObj.get('LinkedEntityId');
                acc.Description = String.valueOf(agrObj.get('flCount'));
                accMap.put(acc.Id, acc);
            }
        }

        if (!accMap.isEmpty()) {
            update accMap.values();
        }
    }
}
