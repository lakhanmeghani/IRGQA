public class SendUsernameChangeEmailQueueable implements Queueable {
    public String oldEmail, newEmail, oldUsername, newUsername, clientName;
    public void execute(QueueableContext context) {
        String customDomain = URL.getSalesforceBaseUrl().toExternalForm().substringAfter('https://').substringBefore('.').substringAfter('--');
        customDomain = (String.isNotEmpty(customDomain)) ? customDomain : 'Production';
        List<String> senderEmailList = new List<String>{oldEmail};
        String customEmailBody = '<br>Hi '+clientName+','+
        '<br>'+
        '<br>Your Username and Email has been updated, please use the same for login</br>'+'</br>'+
        '<br>'+
        '<br>Email: '+newEmail+
        '<br>Username : '+newUserName+'</br>'+
        '<br>'+
        '<br>Thank you'+
        '<br>IRG Team</br>';
       
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Trial Go app Username and Email has been updated');
        email.setToAddresses(senderEmailList);
        email.setHtmlBody(customEmailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});          
    }
}