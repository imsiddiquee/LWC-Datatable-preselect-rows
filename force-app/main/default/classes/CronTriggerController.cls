public with sharing class CronTriggerController {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> GetAllActiveUsersMap() {
        try {
            Map<String, String> userMap = new Map<String, String>();

            for (User userObj : [SELECT Id, IsActive, Name FROM User WHERE IsActive = TRUE ORDER BY Name]) {
                userMap.put(userObj.Id, userObj.Name);
            }
            return userMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static UserDetailWrapper getUserDetail(String userId) {
        try {
            List<UserDetailWrapper> details = new List<UserDetailWrapper>();

            for (User userObj : [
                SELECT
                    Id,
                    Name,
                    Title,
                    ProfileId,
                    Profile.Name,
                    Profile.UserLicenseId,
                    Profile.UserLicense.Name,
                    UserRoleId,
                    UserRole.Name,
                    UserType,
                    IsActive,
                    format(LastLoginDate)
                FROM User
                WHERE Id = :userId
            ]) {
                UserDetailWrapper currentUserDetail = new UserDetailWrapper(userObj);
                fillCurrentUserLoginStatusInfo(currentUserDetail);
                fillCurrentUserSharedGroupInfo(currentUserDetail);

                details.add(currentUserDetail);
            }

            if (details.size() > 0) {
                return details[0];
            }

            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static UserDetailWrapper fillCurrentUserLoginStatusInfo(UserDetailWrapper currentUserDetail) {
        List<UserLogin> loginObj = [
            SELECT Id, UserId, IsFrozen, IsPasswordLocked, LastModifiedDate, LastModifiedById
            FROM UserLogin
            WHERE UserId = :currentUserDetail.userId
        ];
        for (UserLogin loginStatus : loginObj) {
            currentUserDetail.isFrozen = String.valueOf(loginStatus.IsFrozen);
            currentUserDetail.isPasswordLocked = String.valueOf(loginStatus.IsPasswordLocked);
        }

        return currentUserDetail;
    }

    private static UserDetailWrapper fillCurrentUserSharedGroupInfo(UserDetailWrapper currentUserDetail) {
        String userGroups = '';
        List<Group> userGroupList = [
            SELECT Id, Name, DeveloperName, RelatedId, Type, Email, OwnerId
            FROM Group
            WHERE Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :currentUserDetail.userId)
        ];
        for (Group currentGroup : userGroupList) {
            userGroups += currentGroup.Name + ' ,';
        }
        if (!String.isBlank(userGroups)) {
            currentUserDetail.sharedGroups = userGroups.removeEnd(',');
        }

        return currentUserDetail;
    }

    @AuraEnabled(cacheable=true)
    public static List<CronTriggerWrapper> GetUserCronJobDetailList(String userId) {
        List<CronTriggerWrapper> cronTriggerList = new List<CronTriggerWrapper>();

        for (CronTrigger currentCron : [
            SELECT
                Id,
                CronJobDetail.Id,
                CronJobDetail.Name,
                CronJobDetail.JobType,
                State,
                format(NextFireTime),
                format(PreviousFireTime),
                ownerId
            FROM CronTrigger
            WHERE ownerId = :userId
            ORDER BY CreatedDate
        ]) {
            cronTriggerList.add(new CronTriggerWrapper(currentCron));
        }

        return cronTriggerList;
    }

    @AuraEnabled(cacheable=true)
    public static List<AsyncApexJob> GetApexJobsCreatedByUser(String userId) {
        try {
            if (String.isEmpty(userId)) {
                return new List<AsyncApexJob>();
            }

            return [
                SELECT
                    ApexClassId,
                    ApexClass.name,
                    Id,
                    JobItemsProcessed,
                    JobType,
                    Status,
                    NumberOfErrors,
                    MethodName,
                    CreatedById
                FROM AsyncApexJob
                WHERE CreatedById = :userId
                LIMIT 1000
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FlowDefinitionView> GetUserFlowAndProcessBuilderDetailList(String userId) {
        try {
            if (String.isEmpty(userId)) {
                return new List<FlowDefinitionView>();
            }

            User currentUser = [SELECT Username, Id, Name FROM User WHERE id = :userId LIMIT 1];

            return [
                SELECT
                    Id,
                    ApiName,
                    ProcessType,
                    TriggerType,
                    Description,
                    Label,
                    Builder,
                    IsActive,
                    LastModifiedDate,
                    LastModifiedBy,
                    DurableId,
                    ManageableState
                FROM FlowDefinitionView
                WHERE LastModifiedBy = :currentUser.Name
                ORDER BY ProcessType
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ProcessDefinition> GetUserApprovalTaskDetailList(String userId) {
        try {
            if (String.isEmpty(userId)) {
                return new List<ProcessDefinition>();
            }

            // User currentUser=[SELECT Username, Id, Name FROM User where id=:userId LIMIT 1];

            return [
                SELECT
                    Id,
                    Name,
                    Type,
                    Description,
                    TableEnumOrId,
                    State,
                    CreatedDate,
                    CreatedById,
                    LastModifiedDate,
                    LastModifiedById,
                    SystemModstamp
                FROM ProcessDefinition
                WHERE CreatedById = :userId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> GetWorkflowRuleList(String userId) {
        if (String.isEmpty(userId)) {
            return null;
        }

        String sToken = SessionHelper.getSessionId(); //UserInfo.getSessionId();
        Map<String, Object> flowJsonData = new Map<String, Object>();
        String body = null;

        try {
            String toolingSOQL = '/services/data/v36.0/tooling/query?q=Select+Id,Name,TableEnumOrId,createdById,lastModifiedById+From+WorkflowRule';
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String endPoint = baseURL + toolingSOQL;

            Http h = new Http();
            HttpRequest hr = new HttpRequest();
            hr.setHeader('Authorization', 'Bearer ' + sToken);
            hr.setTimeout(60000);
            hr.setHeader('Content-Type', 'application/json');
            hr.setHeader('Accept', 'application/json');
            hr.setEndpoint(endPoint);
            hr.setMethod('GET');
            HttpResponse r = h.send(hr);

            if (r.getStatusCode() == 200) {
                body = r.getBody();
            } else {
                throw new CalloutException(r.getBody());
            }
        } catch (Exception ex) {
            throw ex;
        }

        if (!String.isBlank(body)) {
            flowJsonData = (Map<String, Object>) JSON.deserializeUntyped(body);
            // System.debug('ResponseBody:::'+flowJsonData);
        }
        if (!flowJsonData.isEmpty()) {
            return flowJsonData;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean AbortTheSelectedJob(String jobId) {
        try {
            if (String.isEmpty(jobId)) {
                return false;
            }

            System.abortJob(jobId);
            return true;
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return false;
    }

    public with sharing class CronTriggerWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String jobId { get; set; }
        @AuraEnabled
        public String jobName { get; set; }
        @AuraEnabled
        public String jobType { get; set; }
        @AuraEnabled
        public String state { get; set; }
        @AuraEnabled
        public String previousFireTime { get; set; }
        @AuraEnabled
        public String nextFireTime { get; set; }
        @AuraEnabled
        public String ownerId { get; set; }

        CronTriggerWrapper(CronTrigger currentCron) {
            this.id = currentCron.Id;
            this.jobId = currentCron.CronJobDetail.Id;
            this.jobName = currentCron.CronJobDetail.Name;
            this.jobType = currentCron.CronJobDetail.JobType;
            this.state = currentCron.State;
            this.previousFireTime =String.valueOf(currentCron.PreviousFireTime);
            this.nextFireTime =String.valueOf(currentCron.NextFireTime);
            this.ownerId = currentCron.OwnerId;
        }
    }

    public with sharing class UserDetailWrapper {
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String profileId { get; set; }
        @AuraEnabled
        public String profileName { get; set; }
        @AuraEnabled
        public String userLicenseId { get; set; }
        @AuraEnabled
        public String userLicense { get; set; }
        @AuraEnabled
        public String isActive { get; set; }
        @AuraEnabled
        public String isFrozen { get; set; }
        @AuraEnabled
        public String isPasswordLocked { get; set; }
        @AuraEnabled
        public String lastLoginDate { get; set; }
        @AuraEnabled
        public String userRole { get; set; }
        @AuraEnabled
        public String userRoleId { get; set; }
        @AuraEnabled
        public String userType { get; set; }
        @AuraEnabled
        public String sharedGroups { get; set; }

        UserDetailWrapper() {
        }

        UserDetailWrapper(User currentUser) {
            this.userId = currentUser.Id;
            this.name = currentUser.Name;
            this.title = currentUser.Title;
            this.profileId = currentUser.ProfileId;
            this.profileName = currentUser.Profile.Name;
            this.userLicenseId = currentUser.Profile.UserLicenseId;
            this.userLicense = currentUser.Profile.UserLicense.Name;
            this.userRoleId = currentUser.UserRoleId;
            this.userRole = currentUser.UserRole.Name;
            this.userType = currentUser.UserType;
            this.isActive = String.valueOf(currentUser.IsActive);
            this.lastLoginDate = String.valueOf(currentUser.LastLoginDate);
        }
    }
}
