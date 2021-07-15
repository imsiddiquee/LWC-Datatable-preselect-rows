public with sharing class Temperature {
    public static Decimal FtoC(Decimal fh)
    {
        Decimal result=(fh-32)*5/9;
        return result.setScale(2);
    }

    public static String eventPriority(String eventStatus)
    {
        String eventPri;

        if(String.isBlank(eventStatus) || eventStatus.length()>2)
        {
            return null;
        }

        if(eventStatus=='CA')
        {
            eventPri='High';
        }else {
            eventPri='Medium';
        }

        return eventPri;
    }

    public static void updateAccount(){
        List<Account> accToBeUpdated=new List<Account>();
        Set<Id> accIdSet=new Set<Id>();

        List<Contact> temp=[SELECT Id,Account.Id,Name from Contact where Name like '%test%' and Account.Id != NULL];
        
        
        for (Contact con : [SELECT Id,Account.Id,Name from Contact where Name like '%test%' and Account.Id != NULL]) {
            if (!accIdSet.contains(con.Account.Id)) {
                Account acc=new Account();
                acc.Id=con.Account.Id;
                acc.Active__c=true;
                acc.Rating='Hot';
                accToBeUpdated.add(acc);
                accIdSet.add(con.Account.Id);                
            }            
        }

        if(!accToBeUpdated.isEmpty())
        {
            update accToBeUpdated;
        }
    }

    public static List<Account> dynamicSearchAccountsByName(String searchKey)
    {
        List<Account> accList=new List<Account>();
        Set<Id> accIdSet=new Set<Id>();

        String searchWord='%'+searchKey+'%';

        if(!String.isBlank(searchKey))
        {
            for (Account acc : [Select Id,Name from Account where Name like: searchWord]) {
                if(!accIdSet.contains(acc.Id))
                {
                    accList.add(acc);
                    accIdSet.add(acc.Id);     
                }               
                
            }
        }

        if(!accList.isEmpty())
        {
            return accList;
        }

        return new List<Account>();

    }
}