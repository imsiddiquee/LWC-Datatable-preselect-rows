@isTest
public class RenewalOpportunityTest {
    @TestSetup
    static void setup(){
        
        
        
        Profile getprofile = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
        
        User createTestUser = new User(Alias = 'TDemo', Email = 'kamranqlesssfdc@gmail.com', EmailEncodingKey = 'ISO-8859-1', FirstName = 'Demo', LanguageLocaleKey = 'en_US', LastName = 'User', LocaleSidKey = 'en_US', ProfileId = getprofile.Id, TimeZoneSidKey = 'America/Denver', Username = 'KM@qless.com'); 
        insert createTestUser;
        
        CSMUsers__c cs = new CSMUsers__c();
        cs.Name='KristenBecker';
        cs.CustomerSuccessManagerUserID__c=createTestUser.ID;
        //cs.Other fiels values
        insert cs;
        //System.debug('CSM 1'+cs);
        
        CSMUsers__c cs2 = new CSMUsers__c();
        cs2.Name='LisaWilt';
        cs2.CustomerSuccessManagerUserID__c=createTestUser.ID;
        //cs.Other fiels values
        insert cs2;
        //System.debug('CSM 2'+cs2);
        
        CSMUsers__c cs3= new CSMUsers__c();
        cs3.Name='StaciaWilkins';
        cs3.CustomerSuccessManagerUserID__c=createTestUser.ID;
        //cs.Other fiels values
        insert cs3;
        //System.debug('CSM 3'+cs3);
        
        CSMUsers__c getLisaWilt        = CSMUsers__c.getInstance('LisaWilt');
        String  LisaWilt_USER_ID       = getLisaWilt.CustomerSuccessManagerUserID__c;
        //System.debug('LisaWilt_USER_ID'+LisaWilt_USER_ID);
        
        
        
        
        Account acc=new Account();
        acc.Name='test';
        acc.Client_Success_Manager__c=LisaWilt_USER_ID;
        acc.AccountNumber='012345';
        Insert acc;
        
        Contact con=new Contact();
        con.LastName='test contact';
        con.AccountId=acc.Id;
        con.Email='salesforceadmin@qless.com';
        Insert con;
        
        Opportunity opp=new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='first Opportunity';
        opp.Type='New Business';
        opp.CloseDate=System.today();
        opp.StageName='Proposal';
        opp.Amount=100;
        opp.Contract_Term_Months__c=12;        
        opp.TotalOpportunityQuantity=90;
        Insert opp;        
        
        Product2 prod = new Product2();
        prod.Name = 'Tickets'; 
        prod.Family = 'MRR';
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Product2Id = prod.Id;
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.UnitPrice = 10000;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.ID;
        oli.TotalPrice = 1000.00;
        oli.Quantity = 50;
        oli.PriceBookEntryID = standardPrice.ID;
        oli.Product2Id = prod.Id; 
        oli.Product_Family__c ='MRR';
        insert oli;
        
        
        
        Quote quote=new Quote();
        quote.OpportunityId=opp.Id;
        quote.Name='test quote';
        quote.Billing_Terms__c='Annual';
        quote.Term_of_Contract__c='2_Years';
        quote.AP_Contact_Name__c='test';
        quote.AP_Contact_Email_Address__c='test@gmail.com';
        quote.AP_Contact_Phone_Number__c='0123456';
        quote.Payment_Term__c='N_30';
        quote.ContactId=con.Id;
        quote.Phone='0123458';
        quote.BillingName='BillingName';
        quote.ShippingName='ShippingName';        
        Insert quote;
        
        
        
        
        
    }
    
    @isTest
    private static void createRenewalOpportunityTest()
    { 
        Test.startTest();
        
        Opportunity opp=[Select Id,Name from Opportunity where Name='first Opportunity' limit 1 ];
        List<Id> oppIdList=new List<Id>();
        oppIdList.add(opp.Id);
        RenewalOpportunity.createRenewalOpportunity(oppIdList);            
        System.assertEquals('first Opportunity', opp.Name);
        
        Test.stopTest();  
        
    }
    
        @isTest
    private static void createRenewalOpportunity_Invalid_Term_of_Contract_Test()
    { 
        Test.startTest();
        
        Opportunity opp=[Select Id,Name from Opportunity where Name='first Opportunity' limit 1 ];        
        List<Id> oppIdList=new List<Id>();
        oppIdList.add(opp.Id);
        
        Quote quote=[Select Id,Term_of_Contract__c from Quote where Name='test quote' limit 1];
        quote.Term_of_Contract__c='';
        update quote;
        
        RenewalOpportunity.createRenewalOpportunity(oppIdList);            
        System.assertEquals('first Opportunity', opp.Name);
        
        Test.stopTest();  
        
    }
    
      @isTest
    private static void createRenewalOpportunity_without_contctEmailAddress_Test()
    { 
        Test.startTest();
        
        Contact con=[Select Id,Email from Contact where LastName='test contact' limit 1 ];
        con.Email='';
        Update con;
        
        Opportunity opp=[Select Id,Name from Opportunity where Name='first Opportunity' limit 1 ];
        List<Id> oppIdList=new List<Id>();
        oppIdList.add(opp.Id);
        RenewalOpportunity.createRenewalOpportunity(oppIdList);            
        System.assertEquals('first Opportunity', opp.Name);
        
        Test.stopTest();  
        
    }
}