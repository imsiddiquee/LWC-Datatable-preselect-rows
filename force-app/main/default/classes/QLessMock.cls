@isTest
global  class QLessMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request)
    {
        HttpResponse response=new HttpResponse();
        response.setBody('{}');//api json 
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);

        return response;
    }
}

