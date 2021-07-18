@RestResource(urlMapping='/ContactAPI/*')
global with sharing class ContactResource {
  
  /*
  url=/services/apexrest/ContactAPI/?limit=10
  url=/services/apexrest/ContactAPI/?limit=10&leadsource='test'
   */
  // Get Method
  @HTTPGet
  global static List<Contact> getContactIdNameAndLeadSource() {
      // Initializing the request parameter with the incoming request
      RestRequest contactRequest = RestContext.request;
      // Getting the URL parameters from the request
      Map<String, String> contactRequestParams = contactRequest.params;
      // Getting the limit and leadsource from the request URL params
      Integer contactLimit = Integer.valueOf(contactRequestParams.get('limit'));
      String leadSource = contactRequestParams.get('leadsource');
      System.debug('leadsource::'+leadSource);
      // Querying contacts
      List<Contact> contactList = [SELECT Id, Name, LeadSource FROM Contact WHERE LeadSource =:leadSource LIMIT :contactLimit];
      // Returning the contacts in the response
      return contactList;
  }

  /**
   * post base on parameter pass
   * url=/services/apexrest/ContactAPI
   * {
   * firstName:mike
   * lstName:wheeler
   * birthDate:"04/09/1987",//dd/mm/yyyy
   * leadSource:"Web"
   * }
   
   */
      // POST Method
      @HTTPPost
      global static Contact createNewContact(String firstName, String lastName, String birthDate, String leadSource) {
          // Initializing New Contact
          Contact contact = new Contact();
          contact.FirstName = firstName;
          contact.LastName = lastName;
          contact.Birthdate = Date.parse(birthDate);
          contact.LeadSource = leadSource;
          // Inserting Contact
          insert contact;
          // Returning the contact in the response
          return contact;
      }
      /**
       * post base on request body data
        * url=/services/apexrest/ContactAPI
        * {
        * firstName:mike
        * lstName:wheeler
        * birthDate:"04/09/1987",// yyyy-mm-dd
        * leadSource:"Web"
        * }
       */

      @HTTPPost
      global static Contact createNewContact() {
          // Initializing the request parameter with the incoming request
          RestRequest contactRequest = RestContext.request;
          // Getting the request body from the request
          String requestBody = contactRequest.requestBody.toString();
          // Deserializing the JSON response body and assigning it to an instance of Contact object
          Contact contact = (Contact) JSON.deserialize(requestBody, Contact.class);
          // Inserting Contact
          insert contact;
          // Returning the contact in the response
          return contact;
      }

    /**
     * single item delete from contact.
     * /services/apexrest/ContactAPI/0037F00001hw4nG
     * 
     */

      // DELETE Method
    @HTTPDelete
    global static Map<String, String> deleteContact() {
        // Initializing the response map
        Map<String, String> responseMap = new Map<String, String>();
        // Initializing the request parameter with the incoming request
        RestRequest contactRequest = RestContext.request;
        // Getting the request URI
        String contactRequestURI = contactRequest.requestURI;
        // Getting the contact id from the request URI
        Id contactId = Id.valueOf(contactRequestURI.substring(contactRequestURI.lastIndexOf('/') + 1));
        // Initializing contact to delete
        Contact contact = new Contact(Id=contactId);
        // Deleting contact
        try {
            delete contact;
            responseMap.put('success', '1');
            responseMap.put('message', 'Record Deleted Successfully');
        } catch(DmlException ex) {
            responseMap.put('success', '0');
            responseMap.put('message', ex.getMessage());
        }
        // Returning the response map in the response
        return responseMap;
    }

    /**
     * Delete multiple items from contact.
     * 
     * 
    */

      // Creating a response wrapper class
      global class ResponseWrapper {
        String success;
        String message;
    }   

    // DELETE Method
    @HTTPDelete
    global static List<ResponseWrapper> deleteContacts() {
        // Initializing the response wrapper list
        List<ResponseWrapper> responseWrapperList = new List<ResponseWrapper>();
        // Initializing the request parameter with the incoming request
        RestRequest contactRequest = RestContext.request;
        // Getting the request URI
        String contactRequestURI = contactRequest.requestURI;
        // Getting the contact ids from the request URI
        String[] contactIds = (contactRequestURI.substring(contactRequestURI.lastIndexOf('/') + 1)).split(',');
        // Initializing contacts list to delete
        List<Contact> contactsToDelete = new List<Contact>();
        // Adding contacts in the contacts list
        for(String contactId : contactIds) {
            Contact contact = new Contact(Id=contactId);
            contactsToDelete.add(contact);
        }
        // Deleting contacts with partial success enabled
        Database.DeleteResult[] deleteResults = Database.delete(contactsToDelete, false);
        // Checking the result of delete operation for each contact
        for(Database.DeleteResult deleteResult : deleteResults) {
            // Initializing the response wrapper
            ResponseWrapper wrapper = new ResponseWrapper();
            if (deleteResult.isSuccess()) {
                // Delete successful, setting up the appropriate message in response wrapper
                wrapper.success = '1';
                wrapper.message = 'Successfully deleted contact with Id: ' + deleteResult.getId();
            }
            else {
                // Delete failed, getting errors and setting up the error message in response wrapper
                wrapper.success = '0';
                for(Database.Error error : deleteResult.getErrors()) {
                    wrapper.message = 'The following error has occurred for contact with Id: ' + deleteResult.getId() + '. ';
                    wrapper.message += error.getStatusCode() + ': ' + error.getMessage() + '. ';
                    wrapper.message += 'Contact fields that affected this error: ' + error.getFields();
                }
            }
            // Adding response wrapper instance to the response wrapper list
            responseWrapperList.add(wrapper);
        }
        // Returning the response wrapper list in the response
        return responseWrapperList;
    }

}
