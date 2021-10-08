/**
 * To test use below syntax
List<Id> oppIds=new List<Id>();
oppIds.add('0067c00000DgoClAAJ');
RenewalOpportunity.createRenewalOpportunity(oppIds);
 * 
 */

global class RenewalOpportunity {
  @InvocableMethod(
    label='Create Renewal Opportunity'
    description='create Renewal Opportunity'
  )
  public static void createRenewalOpportunity(List<Id> requestedOpportunityId) {
    Id reqOpportunityId = requestedOpportunityId[0];

    Opportunity existingOpportunity = oppDetails(reqOpportunityId);

    String contactToEmail = conDetails(existingOpportunity.AccountId);

    QuoteWrapper quoteBillTerm = quoteDetails(reqOpportunityId);
    if (quoteBillTerm.billTerm == 0) {
      return;
    }

    List<Opportunity> reOppList = prepareAutoRenewalOpps(
      existingOpportunity,
      quoteBillTerm.billTerm
    );

    if (reOppList.size() > 0) {
      //System.debug('working+:: ' + reOppList);
      insert reOppList;
      createTaskAndSendMailToCSM(existingOpportunity);
      sendMailToAccContact(contactToEmail, existingOpportunity);
    }
  }

  private static Opportunity oppDetails(Id oppId) {
    return [
      SELECT
        Id,
        Name,
        CloseDate,
        StageName,
        Type,
        Amount,
        AccountId,
        Account.Name,
        Account.Client_Success_Manager__c,
        Account.Client_Success_Manager__r.Email,
        Account.Client_Success_Manager_s_Email__c
      FROM Opportunity
      WHERE Id = :oppId
      LIMIT 1
    ];
  }

  private static String conDetails(Id accId) {
    return [
      SELECT Id, Email
      FROM Contact
      WHERE AccountId = :accId
      ORDER BY LastModifiedDate DESC
      LIMIT 1
    ]
    ?.Email;
  }

  private static QuoteWrapper quoteDetails(Id oppId) {
    Integer billingTerms = 0;
    Integer billingDurationInMonths = 0;

    List<Quote> quote = [
      SELECT Id, Name, OpportunityId, Billing_Terms__c, Term_of_Contract__c
      FROM Quote
      WHERE OpportunityId = :oppId AND Billing_Terms__c = 'Annual'
      LIMIT 1
    ];

    if (quote != null && !quote.isEmpty()) {
      switch on quote[0].Term_of_Contract__c {
        when '1_Year' {
          billingTerms = 1;
          billingDurationInMonths = 12;
        }
        when '2_Years' {
          billingTerms = 2;
          billingDurationInMonths = 24;
        }
        when '3_Years' {
          billingTerms = 3;
          billingDurationInMonths = 36;
        }
        when '4_Years' {
          billingTerms = 4;
          billingDurationInMonths = 48;
        }
        when '5_Years' {
          billingTerms = 5;
          billingDurationInMonths = 60;
        }
        when '6_Years' {
          billingTerms = 6;
          billingDurationInMonths = 72;
        }
        when else {
          billingTerms = 0;
          billingDurationInMonths = 0;
        }
      }
    }

    QuoteWrapper qWre = new QuoteWrapper();
    qWre.billTerm = billingTerms;
    qWre.billDuration = billingDurationInMonths;

    return qWre;
  }

  public class QuoteWrapper {
    public Integer billTerm;
    public Integer billDuration;
  }

  private static List<Opportunity> prepareAutoRenewalOpps(
    Opportunity existingOpportunity,
    Integer billTerm
  ) {
    List<Opportunity> oppList = new List<Opportunity>();
    String autoRenewalTermName = '';
    Date nextCloseDate = existingOpportunity.CloseDate;

    for (Integer term = 1; term <= billTerm; term++) {
      //calculate opportunity close data
      nextCloseDate = nextCloseDate.addMonths(12);
      autoRenewalTermName = (term == billTerm)
        ? ' ' + nextCloseDate.year() + ' Renewal' + ' Projected'
        : ' ' + nextCloseDate.year() + ' Renewal';
      Opportunity currentOpportunity = new Opportunity();
      currentOpportunity.CloseDate = nextCloseDate;
      currentOpportunity.Name = existingOpportunity.Name + autoRenewalTermName;
      currentOpportunity.StageName = 'Hold';
      currentOpportunity.AccountId = existingOpportunity.AccountId;
      currentOpportunity.RecordTypeId = '01236000000QafZAAS';
      currentOpportunity.Type = 'Renewal Business';
      currentOpportunity.Auto_Renewal_Parent_Opportunity_Id__c = existingOpportunity.Id;
      oppList.add(currentOpportunity);
    }

    return oppList;
  }

  private static void createTaskAndSendMailToCSM(Opportunity extOpp) {
    if (String.isNotBlank(extOpp.Account.Client_Success_Manager__c)) {
      //create task
      Task currentTask = new Task();
      currentTask.Subject = extOpp.Name;
      currentTask.ActivityDate = System.today();
      currentTask.Activity_Type__c = 'Discovery Call';
      currentTask.Status = 'Open';
      currentTask.Priority = 'Normal';
      currentTask.Type = 'Call';
      currentTask.WhatId = extOpp.Id;
      //This is the default...
      currentTask.OwnerId = extOpp.Account.Client_Success_Manager__c;
      insert currentTask;

      sendEmailTo(
        //need to working
        //String.valueOf(extOpp.Account.Client_Success_Manager__r.Email),
        String.valueOf(extOpp.Account.Client_Success_Manager_s_Email__c),
        'A task with Opportunity ' +
        extOpp.Id +
        ' has been created',
        '',
        extOpp
      );
    }
  }

  private static void sendMailToAccContact(
    String toEmailAddresses,
    Opportunity opp
  ) {
    if (toEmailAddresses != null && !String.isBlank(toEmailAddresses)) {
      sendEmailTo(toEmailAddresses, '', 'hello', opp);
    }
  }

  public static void sendEmailTo(
    String toAddresses,
    String emailSubject,
    String body,
    Opportunity opp
  ) {
    String isSuccess = '';
    try {
      Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
      String[] sendingTo = new List<String>{};
      sendingTo.add(toAddresses);

      EmailTemplate currentTemplate; // is null
      for (EmailTemplate record : [
        SELECT Id, Body, Subject
        FROM EmailTemplate
        WHERE DeveloperName = 'X30_days_template'
      ]) {
        currentTemplate = record;
      }

      if (currentTemplate != null) {
        sendEmail.setToAddresses(sendingTo);
        sendEmail.setSubject(
          String.isNotEmpty(emailSubject)
            ? emailSubject
            : currentTemplate.Subject
        );

        //get template body
        String plainText = currentTemplate.Body;

        //Replace merged field with user information
        plainText = plainText.replace('{!Opportunity.Name}', opp.Name);
        plainText = plainText.replace(
          '{!Opportunity.AccountId}',
          opp.AccountId
        );
        plainText = plainText.replace(
          '{!Opportunity.CloseDate}',
          string.valueOf(opp.CloseDate)
        );
        plainText = plainText.replace(
          '{!Opportunity.Amount}',
          string.valueOf(opp.Amount)
        );
        plainText = plainText.replace(
          '{!Opportunity.StageName}',
          opp.StageName
        );

        sendEmail.setPlainTextBody(plainText);
        Messaging.sendEmail(
          new List<Messaging.SingleEmailMessage>{ sendEmail }
        );

        isSuccess = 'SUCCESS';
      }
    } catch (Exception ex) {
      isSuccess =
        ex.getMessage() +
        '\n' +
        ex.getLineNumber() +
        '\n' +
        ex.getCause() +
        '\n' +
        ex.getStackTraceString();
    }

    System.debug(isSuccess);
  }
}
