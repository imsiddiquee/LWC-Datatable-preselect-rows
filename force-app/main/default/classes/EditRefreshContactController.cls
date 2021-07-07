public with sharing class EditRefreshContactController {
   
    @AuraEnabled(cacheable=true)
    public static List<Contact> GetContactList(){
        try {
            
            return [Select Id,FirstName,LastName,Email FROM Contact LIMIT 10];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
