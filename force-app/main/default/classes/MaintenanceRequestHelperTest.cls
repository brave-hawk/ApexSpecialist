@isTest
public class MaintenanceRequestHelperTest {
    //I suck at writing tests, but here goes:

    public static final Integer BULK_AMOUNT = 300;

    //setUp stuff
    @TestSetup
    static void makeData(){

        //Equipment(Product2)
        List<Product2> testProductList = new List<Product2>();
        for(Integer i=0; i<BULK_AMOUNT; i++){
            Product2 testProduct = new Product2(
                Replacement_Part__c = true,
                Cost__c = 300,
                Current_Inventory__c = 10,
                Lifespan_Months__c  = 1,
                Maintenance_Cycle__c = 10,
                Warehouse_SKU__c = 'skuTest'+i,
                Name = 'Test Product '+i,
                ExternalId = 'ExternalId'+i
            );
            testProductList.add(testProduct);            
        }
        insert testProductList;

        //Vehicle__c
        List<Vehicle__c> testVehicleList = new List<Vehicle__c>();
        for(Integer i=0; i<BULK_AMOUNT; i++){
            Vehicle__c testVehicle = new Vehicle__c(
                Name = 'Test Vehicle '+i
            );  
            testVehicleList.add(testVehicle);      
        }
        insert testVehicleList;

        // MaintenanceRequest (Case)
        // Has: Vehicle        
        List<Case> maintenanceRequestTestList = new List<Case>();
        for(Integer i=0; i< BULK_AMOUNT; i++){
            Case maintenanceRequestTest = new Case(
                Type = 'Repair', //or 'Routine Maintenance'
                Status = 'New',
                Origin = 'Web',
                Vehicle__c = testVehicleList.get(i).Id                
            );
            maintenanceRequestTestList.add(maintenanceRequestTest);
        }
        insert maintenanceRequestTestList;

        //Equipment_Maintenance_Item__c
        // Has: Equipment__c(Product2) && MaintenanceRequest(Case)
        List<Equipment_Maintenance_Item__c> maintenanceItemTestList = new List<Equipment_Maintenance_Item__c>();
        for(Integer i=0; i< BULK_AMOUNT; i++){
            Equipment_Maintenance_Item__c testMaintenanceItem = new Equipment_Maintenance_Item__c(
                Equipment__c = testProductList.get(i).Id,                
                Quantity__c = 10,
                Maintenance_Request__c = maintenanceRequestTestList.get(i).id
            );
            maintenanceItemTestList.add(testMaintenanceItem);
        }
        insert maintenanceItemTestList;
        

       


    }
    
}