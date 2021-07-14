public with sharing class AccountTriggerHelper {

    public static void copyBillingToShipping( List<Account> accList) {
        for (Account acc : accList) {
            if(acc.Active__c)
            {                
                acc.ShippingCity=acc.BillingCity;

            }
            
        }
        
    }
}
