public class WarehouseCalloutService implements Queueable, Database.AllowsCallouts  {

    /*
        To add this class as a job on the queue, call this method (form Developer Console or elsewhere):
        WarehouseCalloutService updateJob = new WarehouseCalloutService();
        Id jobId = System.enqueueJob(updateJob);
    */

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';    

    public void execute(QueueableContext context) {
        //probably a better way to optimize this IMHO
        //see if you can decipher: https://salesforce.stackexchange.com/questions/361083/queuable-apex-callout

        List<Product2> newEquipment = new List<Product2>();  
        //do callout. Separated out to do TEST.
        HttpResponse resp = doGetCallout();      
        List<Object> fetchedEquipmentList = makeListFromCallout(resp);
        for(Object listItem : fetchedEquipmentList){
            Map<String,Object> data = (Map<String,Object>)listItem;
            Product2 newProd = new Product2(
                Replacement_Part__c = true,
                Cost__c = (Decimal)data.get('cost'),
                Current_Inventory__c = (Decimal)data.get('quantity'),
                Lifespan_Months__c  = (Decimal)data.get('lifespan'),
                Maintenance_Cycle__c = (Decimal)data.get('maintenanceperiod'),
                Warehouse_SKU__c = (String)data.get('sku'),
                Name = (String)data.get('name'),
                ExternalId = (String)data.get('_id')
            );
            newEquipment.add(newProd);
        }
        system.debug(newEquipment);
        upsert newEquipment Warehouse_SKU__c;              
    }

    public static HttpResponse doGetCallout(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setMethod('GET');
        HttpResponse response = new HTTPResponse();       
        response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            //all good; process results
            makeListFromCallout(response);
        }
            
            
      
        return response;
    }

    //handle response from server:
    public static List<Object> makeListFromCallout(HttpResponse response){
        
        List<Object> results = new List<Object>();
        results = (List<Object>) JSON.deserializeUntyped(response.getBody());
        system.debug('Results: '+results); 
        return results;
    }


    
}