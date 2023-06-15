global class WarehouseSyncSchedule implements Schedulable {
    /*
        Run every day at 1 am. To schedule:
        WarehouseSyncSchedule m = new WarehouseSyncSchedule();
        String sch = '0, 0, 1 ? * * *';
        String jobId = System.schedule('WarehouseSyncScheduleJob', sch, m);
    */
    

    global void execute(SchedulableContext SC){
        System.enqueueJob(new WarehouseCalloutService());       
    }

    
}