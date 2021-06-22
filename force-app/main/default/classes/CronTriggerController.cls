public with sharing class CronTriggerController {
    
    @AuraEnabled(cacheable=true)
    public static List<CronTrigger> GetUserCronJobDetailList(Id userId){
        try {

            return [select Id, CronJobDetail.Id,CronJobDetail.Name,CronJobDetail.JobType,State,NextFireTime,PreviousFireTime, ownerId
             from CronTrigger
             where ownerId=:userId 
             ORDER BY CreatedDate];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> GetAllActiveUsersMap(){
        try {

            Map<String,String> userMap = new Map<String,String>();

            for(User userObj:[select Id,IsActive,Name from User where IsActive=true Order by Name]){
    
                userMap.put(userObj.Id,userObj.Name);
            }
            return userMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     
    }

    @AuraEnabled(cacheable=true)
    public static List<AsyncApexJob> GetApexJobsCreatedByUser(Id userId){
        try {

           return [ select ApexClassId, ApexClass.name, Id, JobItemsProcessed, JobType, Status, NumberOfErrors, MethodName,CreatedById
            from AsyncApexJob
            where CreatedById =:userId limit 1000];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     
    }
}
