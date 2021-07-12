public inherited sharing class SessionHelper { 

   public static String getSessionId()  {
     return Test.isRunningTest() ? '' :  Page.PageSession.getContent().toString().trim(); 
   }
  }