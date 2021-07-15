public with sharing class TransactionLogHandler {
    public static void doHandleException(System.Exception ex , String processName){
        
        /*Transaction_Log__c transactionLog = new Transaction_Log__c(
            Error_Log__c = ex.getStackTraceString() +'<br/>' + ex.getMessage() 
            + '<br/>' + ex.getCause() +' <br/>'+ ex.getTypeName()+' <br/>'+ex.getLineNumber(),
            Exception_Time__c = System.Now(),
            Process_Name__c   = processName,
            Class_Name__c    = processName
        );
        //To check the field-level create permission of the Transaction_Log__c before creating a new Transaction_Log__c
        if(Schema.sObjectType.Transaction_Log__c.isCreateable()){
            insert transactionLog;
        }*/
    }
}
