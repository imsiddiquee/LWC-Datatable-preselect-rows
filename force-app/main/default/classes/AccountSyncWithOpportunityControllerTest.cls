@isTest
public with sharing class AccountSyncWithOpportunityControllerTest {
    @TestSetup
    static void setup(){
        Account acc=new Account();
        
        acc.Name='test';
        acc.Opportunity_Amount__c=100;
        acc.Monthly_Recurring_Revenue__c=20;
        acc.Annual_Recurring_Revenue__c=50;
        acc.Active__c=true;
        INSERT acc;
        
        Opportunity opp=new Opportunity();    
        opp.Name='test Opp';
        opp.AccountId=acc.Id;                                
        opp.Type='Upsell';
        opp.CloseDate=System.today(); 
        opp.StageName='Closed Won';
        opp.Amount=120;
        //opp.Monthly_Recurring_Revenue__c=50;
        //opp.Annual_Recurring_Revenue__c=40;
        
        
        INSERT opp;                           
        
        
        
    }
    
    @isTest
    private static void getLatestOpportunityRelatedAccountsTest()
    {
        List<AccountSyncWithOpportunityController.AccountOpportunityWrapper> accounts=  AccountSyncWithOpportunityController.getLatestOpportunityRelatedAccounts();             
        System.debug(accounts);
        System.assertNotEquals(0, accounts.size());   
        System.assertEquals('test', accounts[0].accountName);
        
    }

    @isTest
    private static void syncLatestOpportunityWithAccountsTest()
    {
        List<AccountSyncWithOpportunityController.AccountOpportunityWrapper> accounts=  AccountSyncWithOpportunityController.getLatestOpportunityRelatedAccounts();             
        String response=  AccountSyncWithOpportunityController.syncLatestOpportunityWithAccounts(accounts);            
        System.assertEquals('Success', response);
        
    }
}