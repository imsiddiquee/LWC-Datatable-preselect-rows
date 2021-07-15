public with sharing class AccountTriggerHelper {    

    public static void copyBillingToShipping( List<Account> accList) {
        try {
            for (Account acc : accList) {
                if(acc.Active__c)
                {                
                    acc.ShippingCity=acc.BillingCity;
                }               
            }            
        } catch (Exception ex) {
            TransactionLogHandler.doHandleException(ex, 'AccountTrigger');
        }
    }
    
}
