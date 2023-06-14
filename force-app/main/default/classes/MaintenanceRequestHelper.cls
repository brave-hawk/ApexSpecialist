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
            Case c = maintenanceRequest.clone(false, true, false, false);
            //modify fields to conform to question:
            c.Subject = 'Future Routine Checkup';
            c.Date_Reported__c = System.today();
            c.Type = 'Routine Maintenance';
            c.Status = 'New';
            c.Origin = 'Web';
            c.Date_Due__c =  System.today().addDays(shortestCycleDate(maintenanceRequest));

            newCases.add(c);       
        }
        system.debug('newCases to insert: '+newCases);
        insert newCases;
        
    }
    
    private static Integer shortestCycleDate(Case closedCase){            
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