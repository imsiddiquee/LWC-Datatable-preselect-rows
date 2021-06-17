public with sharing class ContentDocumentTriggerHandler {
    public static void Before_Delete_updateAccountonFileDelete(List<ContentDocument> oldList){
        Set<Id> contentDocIdSet=new Set<Id>();
        Map<Id,Account> accountMap=new Map<Id,Account>();
        Set<Id> accountIdSet=new Set<Id>();
        Set<Id> contentDocLinkIdSet=new Set<Id>();

        for (ContentDocument conDoc : oldList) {
            contentDocIdSet.add(conDoc.Id);            
        }

        if(!contentDocIdSet.isEmpty())
        {
            for (ContentDocumentLink docLink : [Select Id,LinkedEntityId from ContentDocumentLink 
            where ContentDocumentId IN : contentDocIdSet]) {

                if(docLink.LinkedEntityId !=null 
                && String.valueOf(docLink.LinkedEntityId).startsWith('001'))
                {
                    accountIdSet.add(docLink.LinkedEntityId);
                    contentDocLinkIdSet.add(docLink.Id);
                }
                
            }
        }

        if(!accountIdSet.isEmpty())
        {
            // for (Account acc : [Select Id,Total_No_of_Files__c,(Select Id from ContentDocumentLinks where Id not IN : contentDocLinkIdSet)
            // from Account where Id IN :accountIdSet]) {
            //     acc.Total_No_of_Files__c=acc.ContentDocumentLinks.size();
            //     accountMap.put(acc.Id, acc);
                
            // }
        }

        if(!accountMap.isEmpty())
        {
            update accountMap.values();
        }

    }
}
