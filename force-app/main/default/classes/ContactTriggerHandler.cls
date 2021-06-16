public with sharing class ContactTriggerHandler {
   
    public static void Before_Insert_PreventCreatePrimaryContact(List<Contact> newList){
        Set<Id> accountIdSet=new Set<Id>();
        Map<Id,Contact> accountIdContactMap=new Map<Id,Contact>();

        for (Contact contactObj : newList) {
            if(contactObj.Is_Primary__c == true && contactObj.AccountId !=null)
            {
                accountIdSet.add(contactObj.AccountId);
            }
            
        }

        if(accountIdSet != null && accountIdSet.size()>0)
        {
            for (Contact conObje : [SELECT Id,Is_Primary__c,AccountId from Contact where 
            AccountId IN:accountIdSet and Is_Primary__c=true]) {
                accountIdContactMap.put(conObje.AccountId,conObje);
            }

            for (Contact conObj : newList) {
                if(conObj.Is_Primary__c==true && conObj.AccountId != null && accountIdContactMap.get(conObj.AccountId) !=null)
                {
                    conObj.addError('You can not create more than one primary contact.');
                    return;
                }
                
            }
        }
    }

    public static void Before_Update_PreventPrimaryContactUpdate(Map<Id,Contact> newMapList,Map<Id,COntact> oldMapList){
        Set<Id> accountIdSet=new Set<Id>();
        Map<Id,Contact> accountIdContactMap=new Map<Id,Contact>();

        for (Contact con : newMapList.values()) {
            if(newMapList.get(con.Id).Is_Primary__c != oldMapList.get(con.Id).Is_Primary__c)
            {
                if(newMapList.get(con.Id).Is_Primary__c == true && newMapList.get(con.Id).AccountId !=null)
                {
                    accountIdSet.add(con.AccountId);
                }
            }
            
        }

         //Validation
         for(Contact contactObj:newMapList.values()){

            if(newMapList.get(contactObj.id).Is_Primary__c!=oldMapList.get(contactObj.Id).Is_Primary__c 
                && newMapList.get(contactObj.id).Is_Primary__c==true 
                && newMapList.get(contactObj.id).AccountID!=null 
                && accountIdContactMap.get(newMapList.get(contactObj.id).AccountID)!=null){               
                    contactObj.addError('You can\'t make more than one contact as primary.');
            }
        }

    }

    public static void After_Insert_CalculateNumberofContacts(List<Contact> newList)
    {
        Set<Id> accountIdSet=new Set<Id>();
        Map<Id,Account> accountMap=new Map<Id,Account>();

        for (Contact con : newList) {
            if(con.AccountId !=null)
            {
                accountIdSet.add(con.AccountId);
            }
            
        }

        if(accountIdSet !=null && accountIdSet.size()>0)
        {
            for (AggregateResult aggResult : [Select count(id) conCount,AccountId from Contact where AccountId IN: accountIdSet GROUP BY AccountId]) {
                Account acc=new Account();
                acc.Id=(Id)aggResult.get('AccountId');
                //acc.No_of_contacts=(Integer)result.get('conCount');
                accountMap.put(acc.Id, acc);

            }
        }

        if(!accountMap.isEmpty())
        {
            update accountMap.values();
        }
    }

    public static void After_Delete_CalculateNumberofContacts(List<Contact> oldList)
    {
        Set<Id> accountIdSet=new Set<Id>();
        Map<Id,Account> accountMap=new Map<Id,Account>();

        for (Contact con : oldList) {
            if(con.AccountId !=null)
            {
                accountIdSet.add(con.AccountId);
            }
            
        }

        if(accountIdSet !=null && accountIdSet.size()>0)
        {
            //how to use not operator
            for (AggregateResult aggResult : [Select count(Id) conCount,AccountId from Contact 
            where AccountId IN: accountIdSet and Id not in: oldList GROUP BY AccountId]) {
                Account acc=new Account();
                acc.Id=(Id)aggResult.get('AccountId');
                //acc.No_of_contacts=(Integer)result.get('conCount');
                accountMap.put(acc.Id, acc);

            }
        }

        if(!accountMap.isEmpty())
        {
            update accountMap.values();
        }
    }

    
    

    

}