public class VisitStatusAlertHandler {
    
    @InvocableMethod
    public static void visitAlert(List<Id>visitIds){
        sirenum__Shift__c visit= [select id,Name,Participant__c, Participant_Location__c,Illingworth_Project_Team_Name__c,sirenum__Scheduled_Start_Time__c,LastModifiedBy.Name,Visit_Number__c,Project_Visit_Type__r.Name,Participant__r.Name,sirenum__Team__r.Name  from sirenum__Shift__c  where ID =:visitIds[0] limit 1];
        // get mail address 
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>();
        Set<String>EmailAddress= new Set<String>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: visit.Illingworth_Project_Team_Name__c limit 1];
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId);
        }
       	List<user> usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
            EmailAddress.add(u.email);
        }
        mailToAddresses.addAll(EmailAddress);
        if(mailToAddresses.size()>0){
        // send mail 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSenderDisplayName('Salesforce Admin');
        mail.setToAddresses(mailToAddresses);
        mail.setSubject( visit.Illingworth_Project_Team_Name__c +'Project - Visit will be set as unfulfilled');
        mail.setPlainTextBody('Dear user ,' +'\n'+
                              +'\n'+'This is to confirm that a visit will set as "unfulfilled"\n'+
                              'Visit Name:'+visit.Name+'\n'+
                              'Visit Date:'+visit.sirenum__Scheduled_Start_Time__c +'\n'+
                              'Participant:'+visit.Participant__r.Name+'\n'+
                              'Visit Type:' +visit.sirenum__Team__r.Name+'\n'+
                              'Visit Number: '+visit.Visit_Number__c+'\n'+
                              +'\n'+'Many thanks!'+'\n'+
                              visit.LastModifiedBy.Name);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        }    
}