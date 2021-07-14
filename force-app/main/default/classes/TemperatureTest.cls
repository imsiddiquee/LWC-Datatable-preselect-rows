@isTest
public with sharing class TemperatureTest {

    @TestSetup
    static void setup(){
        List<Account> accList=new List<Account>();

        for (Integer i = 0; i < 2; i++) {
            Account acc=new Account();
            acc.Name='Test'+i;
            accList.add(acc);
        }

        insert accList;
    }

    @isTest
    private static void warmTempTest()
    {
        Decimal res=Temperature.FtoC(70);
        System.assertEquals(21.11, res);
    }
    
    @isTest
    private static void coldTempTest()
    {
        Decimal res=Temperature.FtoC(32);
        System.assertEquals(0, res);
    }
    
    @isTest
    private static void testEventStatusLength()
    {
        String res=Temperature.eventPriority('IND');
        System.assertEquals(null, res);
    }
    
    @isTest
    private static void testHighPri()
    {
        String res=Temperature.eventPriority('CA');
        System.assertEquals('High', res);
    }
    
    @isTest
    private static void testMediumPri()
    {
        String res=Temperature.eventPriority('NA');
        System.assertEquals('Medium', res);
    }
    
    @isTest
    private static void updateAccountTest()
    {
        Account acc=new Account();
        acc.Name='Test Account';
        acc.Active__c=false;
        acc.Rating='Cold';
        insert acc;
        
        Contact con=new Contact();
        con.FirstName='Test';
        con.LastName='test';
        con.AccountId=acc.Id;
        insert con;
        
        Temperature.updateAccount();
        
        Account updatedAcc=[Select Id,Active__c,Rating From Account where Id=: acc.Id];
        System.assertEquals('Hot', updatedAcc.Rating);
    }
    
    @isTest
    public static void copyBillingToShipping_insert_test()
    {
        Account acc=new Account();
        acc.Name='Test Account';
        acc.Active__c=true;
        acc.BillingCity='test';
        acc.Rating='Cold';
        
        insert acc;
        
        Account currentAcc=[SELECT Id,Name,Active__c,BillingCity FROM Account WHERE Id=:acc.Id];
        
        System.assertEquals(acc.BillingCity, currentAcc.BillingCity);
        
    }

    @isTest
    public static void copyBillingToShipping_insert_negative_test()
    {
        //get data from setup
        Account currentAcc=[SELECT Id,Name,Active__c,BillingCity,Phone FROM Account WHERE Name='Test0'];           
        System.assertEquals(null, currentAcc.Phone);

        currentAcc.Phone='123456';
        update currentAcc;
        System.assertNotEquals(null, currentAcc.Phone);


        delete currentAcc;
        List<Account> deletedAcc=[SELECT Id,Name,Active__c,BillingCity,Phone FROM Account WHERE Name='Test0'];
        System.assertEquals(0, deletedAcc.size());
        
    }

    @isTest
    public static void copyBillingToShipping_update_test()
    {
        Account acc=new Account();
        acc.Name='Test Account';
        acc.Active__c=true;
        acc.BillingCity='test';
        acc.Rating='Cold';
        
        Test.startTest();
        insert acc;

        acc.Active__c=false;
        acc.BillingCity='negativeTest';

        update acc;
        Test.stopTest();
        
        Account currentAcc=[SELECT Id,Name,Active__c,BillingCity FROM Account WHERE Id=:acc.Id];
        
        System.assertNotEquals(acc.BillingCity, acc.ShippingCity);
        
    }

    public static Integer RESPONSE_CODE=200;
    public static String RESPONSE_HEADER_KEY='Content-Type';
    public static String RESPONSE_HEADER_VALUE='application/json';
    public static String RESPONSE_BODY='{}';//api json

    public static void testGetBlog_apiCallOut_test()
    {
        //https://github.com/rahulmalhotra/SFDC-Integration-Tutorial/blob/restcallouttest/force-app/main/default/classes/SFDCStopCalloutTest.cls

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new QLessMock());

        //Performing the API callout
        //HttpResponse response=getBlogs();
        HttpResponse response=new HttpResponse();

        //verifying
        /*
        System.assertEquals(RESPONSE_CODE, response.getStatusCode());
        System.assertEquals(RESPONSE_HEADER_VALUE, response.getHeader(RESPONSE_HEADER_VALUE));
        System.assertEquals(RESPONSE_BODY, response.getBody());
        */
        

        Test.stopTest();
    }
    
    
}