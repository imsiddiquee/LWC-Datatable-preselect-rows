public with sharing class CronTriggerControllerReport {
    @AuraEnabled(cacheable=true)
    public static List<UserReportWrapper> getUserReports(String userId){
        try {

            List<UserReportWrapper> reports=new List<UserReportWrapper>();

            for(Report reportObj:
                [
                    SELECT 
                    Id, 
                    Name, 
                    OwnerId,
                    Owner.Name, 
                    CreatedById,
                    CreatedBy.Name, 
                    format(CreatedDate),                     
                    LastModifiedById,
                    LastModifiedBy.Name,
                    format(LastModifiedDate),                     
                    Description,
                    DeveloperName,
                    format(LastRunDate),
                    format(LastViewedDate)
                    FROM Report                    
                    WHERE CreatedById=: userId
                    ORDER BY CreatedDate DESC
                ]
            )
            {
    
                reports.add(new UserReportWrapper(reportObj) );
            }

            return reports; 
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     
    }

    public with sharing class UserReportWrapper {
        @AuraEnabled       
        public String reportId {get;set;}
        @AuraEnabled       
        public String name {get;set;}
        @AuraEnabled       
        public String ownerId {get;set;}
        @AuraEnabled       
        public String owner {get;set;}
		@AuraEnabled       
        public String createdBy {get;set;}
        @AuraEnabled       
        public String createdDate {get;set;}
        @AuraEnabled       
        public String lastModifiedBy {get;set;}        
        @AuraEnabled       
        public String lastModifiedDate {get;set;}        
        @AuraEnabled       
        public String description {get;set;}
        @AuraEnabled       
        public String lastRunDate {get;set;}
        @AuraEnabled       
        public String lastViewedDate {get;set;}

        UserReportWrapper()
        {            
        }

        UserReportWrapper(Report currentReport)
        {
            this.reportId=currentReport.Id;
            this.name=currentReport.Name;
            this.ownerId=currentReport.OwnerId;
            this.owner=currentReport.Owner.Name;
            this.createdBy=currentReport.CreatedBy.Name;
            this.createdDate=String.valueOf(currentReport.CreatedDate);
            this.lastModifiedBy=currentReport.LastModifiedBy.Name;
            this.lastModifiedDate=String.valueOf(currentReport.LastModifiedDate);
            this.description=currentReport.Description;
            this.lastRunDate=String.valueOf(currentReport.LastRunDate);
            this.lastViewedDate=String.valueOf(currentReport.LastViewedDate);
        }
    }
}