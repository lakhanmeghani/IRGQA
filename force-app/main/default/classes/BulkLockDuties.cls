// Bug 22080 - Bulk lock functionality on Duties is not working

public class BulkLockDuties {
	@InvocableMethod(label='Bulk Lock Worker Duties' description='Bulk Lock Worker Duties by FSU' category='Duty')
    public static List<Integer> BulkLockDuty(List<Date> dt)
    {
    Date LockDate=dt[0];
    List<Duty__c> dutiesToUpdate=new List<Duty__c>();
    Id workerDutyRecordTypeId = [SELECT Id 
                                     FROM RecordType 
                                     WHERE DeveloperName = 'WorkerDuty'
                                     LIMIT 1].Id;
    List<Duty__c> dutyList=[SELECT Id, Name,Date_of_Duty__c, Locked__c, Bulk_Locked_Duty_Date__c 
                             	FROM Duty__c WHERE Locked__c= FALSE
                             	AND Date_of_Duty__c <= : LockDate
                            	AND RecordTypeId =:workerDutyRecordTypeId];
    System.debug('ListToUpdateSize-->'+dutyList.size());    
        if(!dutyList.isEmpty()){
            for(Duty__c duty:dutyList){
            	duty.Locked__c=TRUE;
            	duty.Bulk_Locked_Duty_Date__c=System.today();
            	dutiesToUpdate.add(duty);
      		}
        }
      
       if(!dutiesToUpdate.isEmpty()){
          update dutiesToUpdate;
          System.debug('Update successful');
       }
        
       Integer UpdatedDutiesCount=dutiesToUpdate.size();
       List<Integer> UpdatedDutiesCountList=new List<Integer>();
       UpdatedDutiesCountList.add(UpdatedDutiesCount);
       return UpdatedDutiesCountList;
    }
}