public with sharing class ContactTriggerHelper {
    private static Boolean isRunning=false;
   
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

    //contact spouse relation, used recursion technique.
    public static void After_Insert_ReceiprocalSpouse(List<Contact> newList)
    {
        if (isRunning == true) return;

        List<Contact> conList=new List<Contact>();

        for (Contact conRecord : newList) {
            
            // if(String.isNotBlank(con.Spouse__c))
            // {
            //     Contact con=new Contact();
            //     con.Spouse__c=conRecord.Id;
            //     con.Id=conRecord.Id;

            //     conList.add(con);
            // }           
        }

        isRunning=true;

        if(!conList.isEmpty())
        {
            update conList;
            isRunning=false;
        }
    }


    //removed duplicate contact
    public static void Before_Insert_CreateUniqueContact(List<Contact> newList)
    {
            /*for( Contact con : Trigger.New) {
        if(con.Phone != null) {
            //VerifyPhoneNumbers.doFuture(con.Id);
            VerifyPhoneNumbers.sobjectAsParam(JSON.serialize(con));
        }
    }*/
    // Get a list of all new records
    //Trigger.New // List<sObject> => List<Contact>
    //List<Contact> contactList = new List<Contact>();
    Set<String> newEmailSet = new Set<String>();
    Set<String> existingEmailSet = new Set<String>();

    
    //contactList=newList;
    // Step 2 - Add new emails into a Set
    for ( Contact con : newList ) {
        if ( con.Email != null ) {
            newEmailSet.add(con.Email);
        }
    }
    // Step 3 - Make a SQOL on Contact Object to get the Duplicate Records 
    // 3 New . Contact (test@gmail.com, test1@gmail.com, test2@gmail.com)
    // 10000 Contact - 
    // 0 Records
    List<Contact> existingContactList = [Select Id, Email From Contact 
                                         Where Email IN: newEmailSet AND Email != null];
    // Step 4
    for (Contact con : existingContactList ) {
        existingEmailSet.add(con.Email);
    }
    
    // Step 5 
    
    for ( Contact con : newList ) { // the list we are inserting or updating
        if ( existingEmailSet.contains( con.Email ) ) {
            con.Email.AddError(' Duplicate Email is not Allowed ');
        } else {
            existingEmailSet.add(con.Email);
        }
    }
    // existingEmailSet = {};
    // test12@gmail.com
    // test12@gmail.com
    // existingEmailSet.contains( 'test12@gmail.com' ) => No
    // existingEmailSet = {'test12@gmail.com'}
    // existingEmailSet.contains( 'test12@gmail.com' ) = YES
    //
    //
    }

    
}
