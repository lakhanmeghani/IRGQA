@isTest
public class SendUsernameChangeEmailQueueableTest {
     @isTest
    public static void sendMail(){
        SendUsernameChangeEmailQueueable emailQueue = new SendUsernameChangeEmailQueueable();
        emailQueue.oldEmail = 'testvalidation@syneoshealth.com';
        emailQueue.newEmail = 'testvalidation@syneoshealth.com';
        emailQueue.oldUsername = 'Test@test.com';
        emailQueue.newUsername = 'NewTest@test.com';
        emailQueue.clientName = 'Test User'; 
        
        Test.startTest();
        System.enqueueJob(emailQueue);
        Test.stopTest();
    }
}