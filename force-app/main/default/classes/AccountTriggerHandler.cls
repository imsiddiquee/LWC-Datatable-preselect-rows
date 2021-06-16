public with sharing class AccountTriggerHandler {
    public static void Before_Insert_UpdateRating(List<Account> newList)
    {
        for (Account acc : newList) {
            if(acc.Industry !=null && acc.Industry=='Media')
            {
                acc.Rating='Hot';
                acc.Description='Test Description';
            }
        }
    }

    public static void  After_Insert_CreateRelatedOpp(List<Account> newList)
    {
        List<Opportunity> oppToBeInserted=new List<Opportunity>();

        for (Account acc : newList) {
            Opportunity opp=new Opportunity();
            opp.Name=acc.Name;
            opp.AccountId=acc.Id;
            opp.StageName='Prospecting';
            opp.CloseDate=System.today();

            oppToBeInserted.add(opp);
        }
        if (!oppToBeInserted.isEmpty()) {
            insert oppToBeInserted;
            
        }
    }

    public static void Before_Update_UpdatePhoneDescription(List<Account> newList,Map<Id,Account> oldMap)
    {
        for (Account acc : newList) {
            if (oldMap !=null && acc.Phone !=oldMap.get(acc.Id).Phone) {
                acc.Description='Phone is modified on Account';
                
            }
            
        }
    }

    public static void After_Update_UpdateRelatedOppPhone(List<Account> newList,Map<Id,Account> oldMap)
    {
        Map<Id,Account> accIdToAccountMap=new Map<Id,Account>();

        List<Opportunity> oppList=new List<Opportunity>();
        List<Opportunity> oppToBeUpdated=new List<Opportunity>();

        for (Account acc : newList) {
            if (oldMap !=null && acc.Phone !=oldMap.get(acc.Id).Phone) {
                accIdToAccountMap.put(acc.Id, acc);
                
            }            
        }

        //oppList=[SELECT Id,Phone FROM Opportunity Where AccountId IN: accIdToAccountMap.keySet()];

        for (Opportunity opp : [SELECT Id,Account_Phone__c,AccountId FROM Opportunity Where AccountId IN: accIdToAccountMap.keySet()]) {

            Opportunity oppor=new Opportunity();
            if(accIdToAccountMap.containsKey(opp.AccountId))
            {
                oppor.Id=opp.Id;
                oppor.Account_Phone__c=accIdToAccountMap.get(opp.AccountId).Phone;
                oppToBeUpdated.add(oppor);
            }            
        }

        if(!oppToBeUpdated.isEmpty())
        {
            update oppToBeUpdated;
        }
    }

    public static void Before_delete_CheckAccountStatus(List<Account> oldList)
    {
        for (Account acc : oldList) {
            if (acc.Active__c=='Yes') {
                acc.addError('Active Employee cannot be removed.');
                
            }
        }
    }

    //
    public static void After_delete_CheckAccountStatus(List<Account> oldList)
    {
        // Set<Id> accIds=new Set<Id>();
        // List<Account> accToBeUpdated=new List<Account>();
        // Map<Id,Account> accIdToAccMap;

        // List<Contact> empList=new List<Contact>();
        // Map<Id,Decimal> accIdToTotalCount=new Map<Id,Decimal>();

        // for(Contact emp:oldList)
        // {
        //     if(emp.AccountId !=null)
        //     {
        //         accIds.add(emp.AccountId);
        //         empList.add(emp);
        //     }
        // }

        // if(!accIds.isEmpty())
        // {
        //     accIdToAccMap=new Map<Id,Account>([Select Id,Left_Employee_Count from Account where Id IN: accIds]);
        // }

        // if(!empList.isEmpty())
        // {
        //     for (Contact emp : empList) {
        //         if(accIdToAccMap.containsKey(emp.AccountId))
        //         {
        //             if(accIdToTotalCount.containsKey(emp.AccountId))
        //             {
        //                 Decimal count=accIdToTotalCount.get(emp.AccountId)+1;
        //                 accIdToTotalCount.put(emp.AccountId,count);
        //             }
        //             else {
        //                 Decimal count=accIdToTotalCount.get(emp.AccountId).Left_Employee_Count+1;
        //                 accIdToTotalCount.put(emp.AccountId,count);
        //             }
        //         }
                
        //     }
        // }

        // for (Id accId : accIdToTotalCount.keySet()) {
        //     Account acc=new Account();
        //     acc.Id=accId;
        //     acc.Left_Employee_Count=accIdToTotalCount.get(accId);
        //     accToBeUpdated.add(acc);

            
        // }

        // if(!accToBeUpdated.isEmpty())
        // {
        //     update accToBeUpdated;
        // }
    }

    public static void After_Undelete_UpdateEmployee(List<Contact> newList)
    {
        List<Contact> empToBeUpdated=new List<Contact>();
        for (Contact emp : newList) {
            Contact currentEmp=new Contact();
            currentEmp.Id=emp.Id;
            emp.active=true;
            empToBeUpdated.add(currentEmp);

        }

        if(!empToBeUpdated.isEmpty())
        {
            update empToBeUpdated;
        }
    }
}
