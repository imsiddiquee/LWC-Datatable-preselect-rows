public with sharing class ContactController {
    @AuraEnabled
    public static List<Contact> findContacts(String searchKey){
        try {
            
            if (String.isBlank(searchKey)) {
                return[SELECT Id,Name,Phone,Email FROM Contact WITH SECURITY_ENFORCED LIMIT 10];  
            }

            String key='%'+searchKey+'%';
            return[SELECT Id,Name,Phone,Email FROM Contact WHERE Name LIKE: key WITH SECURITY_ENFORCED LIMIT 10];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   
}
