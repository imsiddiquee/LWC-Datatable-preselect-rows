public with sharing class ToDoListController {
    @AuraEnabled(cacheable=true)
    public static List<Task> getTasks(){
        try {
            
            return [SELECT Subject,OwnerId  FROM Task where ownerid=:UserInfo.getUserId() ];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Task insertTask(String subject){
        try {
            Task task=new Task(
                Subject=subject,
                OwnerId=UserInfo.getUserId(),
                Status='Not Started',
                Priority='Normal'
                
            );
            insert task;
            return task;
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Boolean deleteTask(Id recordId){
        try {
            Database.delete(recordId);
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return false;
    }
}
