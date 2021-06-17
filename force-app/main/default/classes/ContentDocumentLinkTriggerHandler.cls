public with sharing class ContentDocumentLinkTriggerHandler {

    public static void After_Insert_UpdateAccountonFileCount(List<ContentDocumentLink> newList)
    {
        Set<Id> accountIdSet=new Set<Id>();
        Map<Id,Account> accountMap=new Map<Id,Account>();

        for (ContentDocumentLink conLink : newList) {
            if(conLink.LinkedEntityId !=null 
            && String.valueOf(conLink.LinkedEntityId).startsWithIgnoreCase('001') )
            {
                accountIdSet.add(conLink.LinkedEntityId);
            }
            
        }

        if(!accountIdSet.isEmpty())
        {
            for (AggregateResult agResult : [Select count(Id) flCount,LinkedEntityId actId from ContentDocumentLink
            where LinkedEntityId IN : accountIdSet Group by LinkedEntityId]) {
                Account acc=new Account();
                acc.Id=(Id)agResult.get('actId');
               // acc.Total_No_of_Files__c=(decimal)agResult.get('flCount');

                accountMap.put(acc.Id, acc);
            }

            if(!accountMap.isEmpty())
            {
                try {
                    update accountMap.values();

                } catch (Exception ex) {
                    
                }
            }
        }
        
    }

}
