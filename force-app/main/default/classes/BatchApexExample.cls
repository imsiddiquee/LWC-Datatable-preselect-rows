/*
BatchApexExample myBatchObject = new BatchApexExample(); 
Id batchId = Database.executeBatch(myBatchObject);
 */

public with sharing class BatchApexExample implements Database.Batchable<sObject>  {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name FROM Account';
        return Database.getQueryLocator([SELECT Id,Name FROM Account limit 10]);
    }
    public void execute(Database.BatchableContext bc, List<Account> records){
        for (Account acc : records) {
            acc.Name=acc.Name+'update';
            
        }

        try {
            //update records;
            
        } catch (Exception ex) {
            System.debug(ex);            
        }
    }    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}
