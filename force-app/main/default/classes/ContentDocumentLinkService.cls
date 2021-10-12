public with sharing class ContentDocumentLinkService {
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
