global class RenewalOpportunity {    
    
    @InvocableMethod(label='Create Renewal Opportunity' description='create Renewal Opportunity')
    public static void createRenewalOpportunity(List<Id> requestedOpportunityId)
    {
        Integer billingTerms=0;
        Integer billingDurationInMonths=0;
        Contact toEmailAddresses;
        
        List<Opportunity> autoRenewalOpportunity=new List<Opportunity>();
        
        System.debug('p-b requestedOpportunityId::'+requestedOpportunityId);
        
        // Opportunity existingOpportunity=[SELECT Id, Name,CloseDate,AccountId,StageName, Type,Amount FROM Opportunity  where Id =: requestedOpportunityId[0] limit 1]; 
        Opportunity existingOpportunity=[
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
            Account.Client_Success_Manager_s_Email__c
            FROM Opportunity  
            WHERE Id =: requestedOpportunityId[0]
            LIMIT 1
        ]; 
        
        System.debug('p-b existingOpportunity::'+existingOpportunity.Name);
        
        //contact information
        for(Contact record: [SELECT Id,Email from Contact where AccountId=:existingOpportunity.AccountId limit 1]) {
            toEmailAddresses = record;
        }        
        System.debug('toEmailAddresses:: '+toEmailAddresses);
        
        
        List<Quote> existingQuote=[SELECT Id,Name, OpportunityId,Billing_Terms__c,Term_of_Contract__c FROM Quote where OpportunityId=: requestedOpportunityId[0]];
        System.debug('existingQuote:: '+existingQuote);
        
        if(existingQuote.size() !=0)
        {
            //System.debug('p-b existingQuote::'+existingQuote[0]);
            if(existingQuote[0].Billing_Terms__c=='Annual')
            {                
                switch on existingQuote[0].Term_of_Contract__c {
                    when '1_Year' { 
                        billingTerms=1;
                        billingDurationInMonths=12;
                    }   
                    when '2_Years' { 
                        billingTerms=2;
                        billingDurationInMonths=24;
                    }   
                    when '3_Years' { 
                        billingTerms=3;
                        billingDurationInMonths=36;
                    }   
                    when '4_Years' { 
                        billingTerms=4;
                        billingDurationInMonths=48;
                    }   
                    when '5_Years' { 
                        billingTerms=5;
                        billingDurationInMonths=60;
                    }   
                    
                    when '6_Years' { 
                        billingTerms=6;
                        billingDurationInMonths=72;
                    }   
                    when else {       // when else block, optional
                        billingTerms=0;
                        billingDurationInMonths=0;
                    }
                }
                
                if(billingTerms==0)
                    return;
                
                Date nextCloseDate=existingOpportunity.CloseDate;
                
                // System.debug('billingTerms:::'+billingTerms);
                for(Integer term=1;term<=billingTerms;term++) 
                {
                    //calculate opportunity close data
                    
                    nextCloseDate=nextCloseDate.addMonths(12);
                    
                    String autoRenewalTermName=' '+nextCloseDate.year()+' Renewal';
                    
                    if(term==billingTerms)
                    {
                        autoRenewalTermName=' '+nextCloseDate.year()+' Renewal'+' Projected';
                    }
                    
                    Opportunity currentOpportunity=new Opportunity();
                    currentOpportunity.CloseDate=nextCloseDate;//System.today();
                    currentOpportunity.Name=existingOpportunity.Name+autoRenewalTermName;
                    currentOpportunity.StageName='Hold';
                    currentOpportunity.AccountId=existingOpportunity.AccountId;
                    currentOpportunity.RecordTypeId='01236000000QafZAAS';
                    currentOpportunity.Type='Renewal Business';
                    currentOpportunity.Auto_Renewal_Parent_Opportunity_Id__c=existingOpportunity.Id;
                    autoRenewalOpportunity.add(currentOpportunity);
                }
                
                if(autoRenewalOpportunity.size()>0)
                {
                    INSERT autoRenewalOpportunity;
                    
                    if(!String.isBlank(existingOpportunity.Account.Client_Success_Manager__c))
                    {
                        //create task
                        Task tsk = new Task();
                        tsk.Subject = existingOpportunity.Name;
                        tsk.WhatId = existingOpportunity.Id;
                        //This is the default...
                        tsk.OwnerId = existingOpportunity.Account.Client_Success_Manager__c;
                        tsk.Status = 'New';
                        tsk.Type = 'Call';
                       // insert tsk;
                        
                        //send mail to client success manager.
                        //
                        if(!String.isBlank(existingOpportunity.Account.Client_Success_Manager_s_Email__c))
                        {
                            //sendEmailTo(existingOpportunity.Account.Client_Success_Manager_s_Email__c,'You have a new task ','hello',existingOpportunity.Id);                                    
                        }
                        
                        
                        
                    }
                    
                    if(toEmailAddresses !=null &&  !String.isBlank(toEmailAddresses.Email))
                    {                        
                        sendEmailTo(toEmailAddresses.Email,'Confirmation new contact is create for colsed own opportunity','hello',existingOpportunity.Id);        
                    }
                    
                    
                    
                }
                
                
            }
        }
        
        
        
    }
    
    
    public static void sendEmailTo(String toAddresses, String subject, String body,String existingOpportunity)
    {
        String isSuccess='';
        try
        {
            //get existing opportunity
            Opportunity opp=[SELECT Id, Name,CloseDate,AccountId,StageName, Type,Amount FROM Opportunity  where Id =: existingOpportunity limit 1]; 
            
            system.debug('sendEmailTo');
            //('sendEmailTo');
            Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{}; 
                sendingTo.add(toAddresses);
            
            EmailTemplate template; // is null
            for(EmailTemplate record: [SELECT Id,Body,Subject FROM EmailTemplate where DeveloperName='X30_days_template']) {
                template = record;
            }      
            
            if(template !=null)
            {
                sendEmail.setToAddresses(sendingTo);
                sendEmail.setSubject(template.Subject); 
                
                //get template body
                String plainText = template.Body;
                
                //Replace merged field with user information
                plainText = plainText.replace('{!Opportunity.Name}', opp.Name);
                plainText = plainText.replace('{!Opportunity.AccountId}', opp.AccountId);
                plainText = plainText.replace('{!Opportunity.CloseDate}', string.valueOf(opp.CloseDate));
                plainText = plainText.replace('{!Opportunity.Amount}', string.valueOf(opp.Amount));
                plainText = plainText.replace('{!Opportunity.StageName}', opp.StageName);
                
                sendEmail.setPlainTextBody(plainText); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sendEmail});
                
                isSuccess='SUCCESS';
                
                
                
            }
            
        }
        catch(Exception ex){
            isSuccess=ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getStackTraceString();
        }
        
        System.debug(isSuccess);
        
    }
}