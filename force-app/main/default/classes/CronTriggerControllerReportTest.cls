@isTest
public with sharing class CronTriggerControllerReportTest {
   
    @isTest(SeeAllData='true')
    public static void getUserReportsTest() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        String userName=uid + '@myorg.com';
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= userName); 

        
        List <Report> reportList = [SELECT Id,CreatedById,DeveloperName FROM Report limit 10];

                     
           
        Test.startTest();
        
        insert(u);        
        

        List<CronTriggerControllerReport.UserReportWrapper>  userReports=CronTriggerControllerReport.getUserReports(u.Id);
        

        if(reportList.size()>0)
        {
            List<CronTriggerControllerReport.UserReportWrapper>  userExistReports=CronTriggerControllerReport.getUserReports(reportList[0].CreatedById);
            
        }

        Test.stopTest();
        
        System.assertEquals(0, userReports.size());        
        
    }
}