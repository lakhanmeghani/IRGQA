@isTest
public class UpdateUserQueueableTest {
    @isTest
    public static void updateUser(){
        Id resourceTypeId = [SELECT Id FROM RecordType Where Name='Resource'].Id;
        Id resourcePoolId = [SELECT Id FROM RecordType Where Name='Resource Pool'].Id;
        Account testAccount = new Account(Name = 'Dhanik Sahni', RecordTypeId=resourcePoolId);
        insert testAccount;
        Contact testContact = new Contact(FirstName='Test',Lastname='McTesty',AccountId=testAccount.Id,Email='mike.sampsons2@illingworthresearch.com',Work_Country__c='UK',MailingCountry='UK',MailingCity='Cambridge',RecordTypeId=resourceTypeId);
        insert testContact;
        
        Id portalProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus User' Limit 1].Id;
        User testCommunityUser = new User(
            UserName = 'dhanik.sahni@yahoo.com' + math.random(), FirstName = 'Test-First', LastName = 'Test-Last',
            Alias = 'test', email = 'dhanik.sahni@gmail.com', ContactId = testContact.Id, ProfileId = portalProfileId,
            EmailEncodingKey = 'UTF-8', CommunityNickname = 'test12345', TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US'
        );
        insert testCommunityUser;
        
        Map<Id,String> conIdEmailMap = new Map<Id,String>();
        conIdEmailMap.put(testContact.Id, 'jai.jethanandani@areya.tech');
        UpdateUserQueueable updateUserQueue = new UpdateUserQueueable();
        updateUserQueue.conIdNewEmailMap = conIdEmailMap;
        
        Test.startTest();
        System.enqueueJob(updateUserQueue);
        Test.stopTest();
    }
}