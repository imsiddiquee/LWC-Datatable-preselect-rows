@isTest
public class CronTriggerControllerTest {
    
    @TestSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> uu = new List<User>();
        
        while (uu.size() < 5) 
        {
            
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com');      
            uu.add(u);
        }
        
        insert(uu);
    }
    
    @isTest
    private static void getAllActiveUsersMapTest()
    {
        Map<String,String> activeUserMap=CronTriggerController.GetAllActiveUsersMap();               
        System.assertNotEquals(0, activeUserMap.size());        
        
    }
    
    @isTest
    private static void getUserCronJobDetailListTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com'); 
        insert(u);
        
        
        
        List<CronTrigger> crons=CronTriggerController.GetUserCronJobDetailList(u.id);               
        System.assertEquals(0, crons.size());
        
        List<CronTrigger> crons2=CronTriggerController.GetUserCronJobDetailList('');               
        System.assertEquals(0, crons2.size());
        
    }
    
    @isTest
    private static void getApexJobsCreatedByUserTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com'); 
        insert(u);
        
        
        
        List<AsyncApexJob> crons=CronTriggerController.GetApexJobsCreatedByUser(u.id);
        System.assertEquals(0, crons.size());
        
        List<AsyncApexJob> crons2=CronTriggerController.GetApexJobsCreatedByUser('');
        System.assertEquals(0, crons2.size());
        
        //List<AsyncApexJob> crons3=CronTriggerController.GetApexJobsCreatedByUser('test');
        //System.assertEquals(0, crons3.size());
        
    }
    
    @isTest
    private static void getUserFlowAndProcessBuilderDetailListTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com'); 
        insert(u);
        
        
        
        List<FlowDefinitionView> crons=CronTriggerController.GetUserFlowAndProcessBuilderDetailList(u.id);
        System.assertEquals(0, crons.size());
        
        List<FlowDefinitionView> crons2=CronTriggerController.GetUserFlowAndProcessBuilderDetailList('');
        System.assertEquals(0, crons2.size());
        
        //List<AsyncApexJob> crons3=CronTriggerController.GetApexJobsCreatedByUser('test');
        //System.assertEquals(0, crons3.size());
        
    }
    
    @isTest
    private static void getUserApprovalTaskDetailListTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com'); 
        insert(u);
        
        
        
        List<ProcessDefinition> crons=CronTriggerController.GetUserApprovalTaskDetailList(u.id);
        System.assertEquals(0, crons.size());
        
        List<ProcessDefinition> crons2=CronTriggerController.GetUserApprovalTaskDetailList('');
        System.assertEquals(0, crons2.size());
        
        //List<AsyncApexJob> crons3=CronTriggerController.GetApexJobsCreatedByUser('test');
        //System.assertEquals(0, crons3.size());
        
    }
    
    @isTest
    private static void getWorkflowRuleListTest()
    {
        
        //https://github.com/rahulmalhotra/SFDC-Integration-Tutorial/blob/restcallouttest/force-app/main/default/classes/SFDCStopCalloutTest.cls
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new WorkflowRuleMock());
        
        //Performing the API callout
        //HttpResponse response=getBlogs();
        Map<String, Object> response=CronTriggerController.GetWorkflowRuleList('test');
        
        //verifying
        
        //System.assertEquals(200, response.getStatusCode());
        //System.assertEquals(RESPONSE_HEADER_VALUE, response.getHeader(RESPONSE_HEADER_VALUE));
        //System.assertEquals('{}', response.getBody());
        
        Map<String, Object> result=CronTriggerController.GetWorkflowRuleList('test');
        System.assertEquals(null, result);           
        Test.stopTest();
        
        Map<String, Object> emptyUser=CronTriggerController.GetWorkflowRuleList('');
        System.assertEquals(null, emptyUser);
        
        
        
    }
    
    @isTest
    private static void abortTheSelectedJobTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com'); 
        insert(u);
        
        
        
        Boolean crons2=CronTriggerController.AbortTheSelectedJob('');
        System.assertEquals(false, crons2);
        
        
    }
    
    @isTest
    private static void getUserDetailTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        String userName=uid + '@myorg.com';
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= userName); 
        insert(u);
        
        
        CronTriggerController.UserDetailWrapper currentUser= CronTriggerController.getUserDetail(u.Id);
        System.assertEquals(u.ProfileId, currentUser.profileId);
        System.assertNotEquals('test', userName);
    }
   
}