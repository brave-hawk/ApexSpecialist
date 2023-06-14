trigger MaintenanceRequest on Case (before update, after update) {
    
    //Create List of Case Obj that have been closed
    List<Case> toProcess = new List<Case>();

    /*
        When an existing maintenance request of type Repair or Routine Maintenance is closed, 
        create a new maintenance request for a future routine checkup.
    */    
    toProcess = [SELECT Id, Type, Vehicle__c, ProductId, (SELECT Id, Name, Equipment__r.Maintenance_Cycle__c FROM Equipment_Maintenance_Items__r ) FROM Case WHERE 
    (Type='Routine Maintenance' OR Type='Repair') 
    AND (IsClosed=true AND Id in : Trigger.new)];

    switch on Trigger.operationType {
        
        when BEFORE_UPDATE {
            /* Best Practices:       
                Use Before Trigger:
                In the case of validation check in the same object.
                Insert or update the same object.
            */
            system.debug('Before update trigger on Case(MaintenanceRequest) fired');
        }
        
        when AFTER_UPDATE{
            /* Best Practices:
                Insert/Update related object, not the same object.
                Notification email.
                We cannot use After trigger if we want to update a record because it causes read only error.
            */
            system.debug('After update trigger on Case(MaintenanceRequest) fired');
            MaintenanceRequestHelper.updateWorkOrders(toProcess);
        }
    }
}