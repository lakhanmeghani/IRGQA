global class PopulateLastLoginDateOnContactBatch implements System.Schedulable, Database.Batchable<sObject>{    
    global Database.Querylocator start (Database.BatchableContext BC){
        string sQuery = 'SELECT Id, contactid,LastLoginDate FROM User WHERE ContactId != null'+(Test.isRunningTest()? ' LIMIT 100':'');
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id, DateTime> contactIdToLastLoginMap = new Map<Id, DateTime>();
        list<LoginHistory> listLoginHistory = [select id, Application, UserId,LoginTime from LoginHistory where userId IN: scope];

        for (LoginHistory login : listLoginHistory) {
            if(login.Application == 'IRG-TrialGO'){
                if (!contactIdToLastLoginMap.containsKey(login.UserId) || login.LoginTime > contactIdToLastLoginMap.get(login.UserId)) {
                    contactIdToLastLoginMap.put(login.UserId, login.LoginTime);
                }
            }
        }
       // system.debug('contactIdToLastLoginMap=='+contactIdToLastLoginMap);
        
        for (User u : scope) {
            Id contactId = u.ContactId;
            if (contactIdToLastLoginMap.containsKey(u.Id)) {
                DateTime lastLoginTime = contactIdToLastLoginMap.get(u.Id);
                contactsToUpdate.add(new Contact(Id = contactId, Last_Log_In__c = lastLoginTime));
            }
        }
        
        if (!contactsToUpdate.isEmpty()) {
            //system.debug('contactsToUpdate=='+contactsToUpdate);
            update contactsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Batch Execution is finished');
    }
    
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new PopulateLastLoginDateOnContactBatch());
    }
}