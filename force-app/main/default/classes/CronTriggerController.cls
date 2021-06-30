public with sharing class CronTriggerController {

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
    public static List<AsyncApexJob> GetApexJobsCreatedByUser(Id userId){
        try {

           return [ select ApexClassId, ApexClass.name, Id, JobItemsProcessed, JobType, Status, NumberOfErrors, MethodName,CreatedById
            from AsyncApexJob
            where CreatedById =:userId limit 1000];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     
    }

    @AuraEnabled(cacheable=true)
    public static List<FlowDefinitionView> GetUserFlowAndProcessBuilderDetailList(Id userId){
        try {

            User currentUser=[SELECT Username, Id, Name FROM User where id=:userId LIMIT 1];

            return
            [SELECT Id, ApiName, ProcessType, TriggerType, Description, Label, Builder, IsActive, LastModifiedDate, 
            LastModifiedBy, DurableId, ManageableState  
            FROM FlowDefinitionView 
            WHERE LastModifiedBy=:currentUser.Name
            ORDER BY ProcessType
            ];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProcessDefinition> GetUserApprovalTaskDetailList(Id userId){
        try {

           // User currentUser=[SELECT Username, Id, Name FROM User where id=:userId LIMIT 1];

            return
            [SELECT Id, Name, Type, Description, TableEnumOrId,  State, CreatedDate,
             CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
              FROM ProcessDefinition WHERE CreatedById=:userId
            ];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
