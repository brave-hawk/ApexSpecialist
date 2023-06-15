public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> closedList) {        
    
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
        //helper function to clone and insert new EquipmentItem children related to the new cases
        cloneEquipmentItems(newCases);
    }

    //Get all Equipment_Maintenance_Items concerned, and clone them, 
    //then assign them a new parent - the newly created case - (in their master detail rltshps)
    private static void cloneEquipmentItems(List<Case> newCases){
        //transform newCases to Map of key: newCase.ParentId, value: newCase
        //newCase.ParentId is oldCase Id
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case newCase : newCases){
            caseMap.put(newCase.ParentId, newCase);
        }

        //list to hold new Equipment_Maintenance_Items to insert
        List<Equipment_Maintenance_Item__c> itemsToInsert = new List<Equipment_Maintenance_Item__c>();
        
        for(Equipment_Maintenance_Item__c item: [SELECT Id, Maintenance_Request__r.Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__r.Id IN : caseMap.keyset()] ){
            Equipment_Maintenance_Item__c cloneItem = item.clone(false, true, false, false);
            Id oldParentId = cloneItem.Maintenance_Request__r.Id;
            Case newParent = caseMap.get(oldParentId);
            cloneItem.Maintenance_Request__c = newParent.Id;
            itemsToInsert.add(cloneItem);
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
            system.debug('Maintenance Cycle: ' + item.Equipment__r.Maintenance_Cycle__c);
            cycleDates.add(item.Equipment__r.Maintenance_Cycle__c);                
        }
        cycleDates.sort();
        //return 0 days if no maintenance cycle
        return cycleDates.size() > 0 ? (Integer)cycleDates[0] : 0;
    } 

    
}