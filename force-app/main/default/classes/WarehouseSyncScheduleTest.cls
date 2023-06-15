@isTest
public class WarehouseSyncScheduleTest {
    //dummy CRON because runs immediatly after Test.stopTest()
    public static String CRON_EXP = '0, 0, 1 ? * * *';
    
    @isTest
    static void testScheduledJob(){

        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock()); 
        Test.startTest();
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();

        //query the job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime FROM CronTrigger WHERE id = :jobId];
        system.debug([select id,JobType,CompletedDate,MethodName,Status from AsyncApexJob]);

        //2 because the ScheduledApex Job  calls the Queueable Job
        System.assertEquals(2 ,[SELECT count() FROM AsyncApexJob]);
        System.assertEquals(CRON_EXP,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);       

    }
}