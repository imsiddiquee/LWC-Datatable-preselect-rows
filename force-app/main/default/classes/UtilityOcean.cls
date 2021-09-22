public with sharing class UtilityOcean {
    public UtilityOcean() {

    }


  public static void sendMail(String toAddresses, String subject, String body)
    {       
        Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{}; 
            sendingTo.add(toAddresses);
        sendEmail.setToAddresses(sendingTo);
        sendEmail.setSubject(subject); 
        sendEmail.setPlainTextBody(body); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sendEmail});
    }

    public static Boolean sendMailWithAttachment(String toEmailAddress, List<SObject> records)    
    {
        SendMail_sendMailWithAttachment(new ReceiptGenerationWrapper(),'123@gmail.com');
    }

    private void SendMail_sendMailWithAttachment(List<ReceiptGenerationWrapper> wrapperList,String branchOwnerEmail)
    {
        
        String generatedCSVFile ='';
        List<String> queryFields = new List<String>{'RollNo','Term','Exam Type','Date','Status','Branch'};
            String fileRow = '';
        //col
        for(String col: queryFields)
        {
            fileRow =fileRow+col+',';
            
        }          
        generatedCSVFile = generatedCSVFile+fileRow +'\n';
        
        //row
        for(ReceiptGenerationWrapper row: wrapperList){
            fileRow = '';
            fileRow = fileRow +','+ row.rollNo;
            fileRow = fileRow +','+ row.term;
            
            fileRow = fileRow +','+ row.examType;
            fileRow = fileRow +','+ row.createdDate;
            fileRow = fileRow +','+ row.status;
            fileRow = fileRow +','+ row.branch;
            
            fileRow = fileRow.replaceFirst(',','');
            generatedCSVFile = generatedCSVFile + fileRow + '\n';
            
        }
        
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'AESL_Receipt_Generation_Batch_6AM.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[]{'harsh.raghaw@gmail.com'};
        String[] toAddresses = new String[]{branchOwnerEmail};
            String subject = 'AESL Receipt Generation Batch 6AM CSV';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('AESL Receipt Generation Batch 6AM CSV');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }


    public class ReceiptGenerationWrapper {        
        public String  rollNo;
        public String  term ;
        public String  examType ;
        public String  createdDate ;
        public String  status ;
        public String  branch ;
        public String  branchOwnerEmail ;
        
        ReceiptGenerationWrapper(Opportunity opp)
        {
            this.rollNo=String.isBlank(opp.AESL_Roll_No__c)?'-':opp.AESL_Roll_No__c;
            this.term=String.isBlank(opp.AESL_Level__r.AESL_strm__c)?'-':opp.AESL_Level__r.AESL_strm__c;
            this.examType=String.isBlank(opp.AESL_Exam_Master__r.AESL_Exam_Type__c)?'-':opp.AESL_Exam_Master__r.AESL_Exam_Type__c;
            this.createdDate=String.valueOf(opp.CreatedDate);
            this.status=String.isBlank(opp.AESL_Status__c)?'-':opp.AESL_Status__c;            
            
            this.branch=String.isBlank(opp.AESL_Branch_LK__r.Name)?'-':opp.AESL_Branch_LK__r.Name;
            this.branchOwnerEmail=String.isBlank(opp.AESL_Branch_LK__r.Branch_Owner_Email_ID__c)?'-':opp.AESL_Branch_LK__r.Branch_Owner_Email_ID__c;
        }
    }
    
}
