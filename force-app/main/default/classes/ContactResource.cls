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
   * url=/services/apexrest/ContactAPI
   * 
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



}
