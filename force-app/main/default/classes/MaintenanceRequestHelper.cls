public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> closedList) {        
        /*
        When an existing maintenance request of type Repair or Routine Maintenance is closed, 
        create a new maintenance request for a future routine checkup.
        */

        //ToDo:
        //helper method to get shortest/soonest cycle date
        

        system.debug('Received justClosed: '+ closedList);

        List<Case> newCases = new List<Case>();
        for (Case maintenanceRequest: closedList){
            //clone each maintenanceRequest(Case) to preserve relationships.
            //Options: opt_preserve_id, opt_IsDeepClone, opt_preserve_readonly_timestamps, opt_preserve_autonumber
            system.debug('maintenanceRequest is: '+ maintenanceRequest);
            Case c = maintenanceRequest.clone(false, true, false, false);
            //modify fields to conform to question:
            c.Subject = 'Future Routine Checkup';
            c.Date_Reported__c = System.today();
            c.Type = 'Routine Maintenance';
            c.Status = 'New';
            c.Origin = 'Web';
            c.Vehicle__c = maintenanceRequest.Vehicle__c;
            c.Date_Due__c =  System.today().addDays(shortestCycleDate(maintenanceRequest));
            c.ParentId = maintenanceRequest.Id; //use this to map children
            newCases.add(c);       
        }
        system.debug('newCases to insert: '+newCases);
        insert newCases;
        cloneEquipmentItems(newCases);
    }

    private static void cloneEquipmentItems(List<Case> newCases){
        //get all Equipment Maintenance items for each child. 
        //SELECT Id, Name FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__r.Id = '5007R00003Ys7XOQAZ'
        List<Equipment_Maintenance_Item__c> itemsToInsert = new List<Equipment_Maintenance_Item__c>();
        for (Case newCase : newCases){
            List<Equipment_Maintenance_Item__c> items = [SELECT Id, Name FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__r.Id = :newCase.ParentId];
            for(Equipment_Maintenance_Item__c item : items){
                Equipment_Maintenance_Item__c cloneItem = item.clone(false, true, false, false);
                cloneItem.Maintenance_Request__c = newCase.Id; // the most important part

                itemsToInsert.add(cloneItem);
            }
        }
        insert itemsToInsert;
    }
    
    private static Integer shortestCycleDate(Case closedCase){   
        if (closedCase == null){
            return 0;
        }         
        //create list of MaintenanceCycle dates
        List<Decimal> cycleDates = new List<Decimal>();

        for (Equipment_Maintenance_Item__c item : closedCase.Equipment_Maintenance_Items__r){
            system.debug('Maintenance Cycle: '+item.Equipment__r.Maintenance_Cycle__c);
            cycleDates.add(item.Equipment__r.Maintenance_Cycle__c);                
        }
        cycleDates.sort();
        //return 0 days if no maintenance cycle
        return cycleDates.size() > 0 ? (Integer)cycleDates[0] : 0;
    } 

    
}