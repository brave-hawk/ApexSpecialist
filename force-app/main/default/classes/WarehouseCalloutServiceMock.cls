@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        //fake a response:
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]');
        response.setStatusCode(200);
        return response; 
    }
}