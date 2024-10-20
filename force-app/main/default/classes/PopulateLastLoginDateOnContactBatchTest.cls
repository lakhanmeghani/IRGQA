@isTest
private class PopulateLastLoginDateOnContactBatchTest {
    @isTest
    static void testBatch() {
        User RecruitmentManager1 = DataFactory.createUser();
        Id roleId = [Select Id from UserRole where Name ='Admin'].Id;
        RecruitmentManager1.UserRoleId = roleId;
        update RecruitmentManager1;
        Id contactId = null;
        System.RunAs(RecruitmentManager1) {
            
            Test.startTest();
            Account account = DataFactory.createAccount();
            account.ownerid = RecruitmentManager1.Id;
            update account;
            
            sirenum__Job_Type__c jobtype = DataFactory.createJobType();
            List<Contact> resource1 = DataFactory.createContact(RecruitmentManager1, account, jobtype);
            resource1[0].ownerId = RecruitmentManager1.Id;
            update resource1[0];
            contactId = resource1[0].Id;
            
            id profileId = [select id from profile where name = 'BH Connect Default'].Id;
            User RecruitmentManager2=new User(firstname = 'Mrunal', 
                                              lastName = 'Bhingare', 
                                              email ='mrunal.bhingare1@areya.tech', 
                                              Username = 'testClass6191@illingworthresearch.com.irgprod', 
                                              EmailEncodingKey = 'ISO-8859-1', 
                                              Alias = 'monty', 
                                              TimeZoneSidKey = 'America/Los_Angeles', 
                                              LocaleSidKey = 'en_US',
                                              LanguageLocaleKey = 'en_US', 
                                              ProfileId = profileId,
                                              contactId = resource1[0].Id
                                              //UserRoleId  = roleId 
                                             ); 
            insert RecruitmentManager2;
            
            
            //PopulateLastLoginDateOnContactBatch batchInstance = new PopulateLastLoginDateOnContactBatch();
            //Database.executeBatch(batchInstance);
            
            String sch = '0 0 23 * * ?';
            system.schedule('Schedule Job', sch, new PopulateLastLoginDateOnContactBatch() );
            Test.stopTest();
            
            Contact c = [Select Id,Last_Log_In__c from Contact where Id =: contactId];
            
           System.assert(c.Last_Log_In__c == null);
            
        }
    }
}