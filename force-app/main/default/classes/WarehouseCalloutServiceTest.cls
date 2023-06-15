@IsTest
private class WarehouseCalloutServiceTest {
   @isTest static void testGetCallout(){   
    //I really hate tests :=)
   
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res =  WarehouseCalloutService.doGetCallout();   

        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"}]';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        //part 2 of tests:

        WarehouseCalloutService updateJob = new WarehouseCalloutService();
        //Force async service to run
        Test.startTest();
        System.enqueueJob(updateJob);
        Test.stopTest();
        //validate job ran; verify _id in ExternalId field is correct
       
        //Our mock has just 1 value, safe to assign direct
        Product2 newProd = [SELECT ExternalId, Name from Product2 LIMIT 1];
        System.assertEquals('55d66226726b611100aaf741', newProd.ExternalId);

   }



}