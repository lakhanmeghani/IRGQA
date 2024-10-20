public class UpdateUserQueueable implements Queueable {
    public Map<Id, String> conIdNewEmailMap;
    
    public void execute(QueueableContext context) {
    	system.debug('UpdateUserQueueable -->'+conIdNewEmailMap);
        List<User> updateEmailAndUsernameList = new List<User>();
        List<User> updateOnlyUserEmailList = new List<User>();
        String customDomain = URL.getSalesforceBaseUrl().toExternalForm().substringAfter('https://').substringBefore('.').substringAfter('--');
        customDomain = (String.isNotEmpty(customDomain)) ? customDomain : 'prod';
        String oldEmail = ''; String oldUserName = ''; String newEmail = ''; String newUserName = ''; String clientName ='';
        if(conIdNewEmailMap != null && !conIdNewEmailMap.isEmpty()){		
            for(User eachUser : [SELECT Id, ContactId, Contact.Email, Name, Email, Username 
                                 FROM User 
                                 WHERE ContactId IN :conIdNewEmailMap.keySet() AND IsPortalEnabled = true]){                
                oldEmail = eachUser.Email; oldUserName = eachUser.Username; clientName = eachUser.Name;
                newEmail = conIdNewEmailMap.get(eachUser.ContactId);
                newUserName = newEmail+'.'+customDomain;
                System.debug('newUserName '+newUserName);
                If(oldEmail != newEmail){
                    eachUser.Email = newEmail;
                    updateOnlyUserEmailList.add(eachUser);
                    eachUser.Username = newUserName;
                    updateEmailAndUsernameList.add(eachUser);
                }
                System.debug('updated User '+eachUser);
            }
            Savepoint sp = Database.setSavepoint();
            //Update both Usename and email on Patrner User
            if(!updateEmailAndUsernameList.isEmpty()){
                Database.SaveResult[] srList = Database.update(updateEmailAndUsernameList, false);
                for(Database.SaveResult sr : srList) {
                    if(sr.isSuccess()) {
                        System.debug('oldEmail '+oldEmail+' newEmail '+newEmail+' oldUserName '+oldUserName+' newUserName '+newUserName);
                        callEmailQueue(oldEmail,newEmail,oldUserName,newUserName,clientName);
                    }
                    else {
                        // Operation failed due to Duplicate Username of user so updating only email on user              
                        for(Database.Error err : sr.getErrors()) {   
                            String errorMessage = err.getMessage();
                            If(errorMessage.contains('Username')  && !updateOnlyUserEmailList.isEmpty()){
                                updateOnlyUserEmailList[0].Username = oldUserName;
                                System.debug('Inside the duplicate user Error '+ updateOnlyUserEmailList);
                                Database.SaveResult[] resultList = Database.update(updateOnlyUserEmailList, false);
                                for(Database.SaveResult result : resultList) {
                                    System.debug('Only update Email');
                                    if(result.isSuccess()) {
                                    	System.debug('Inside Error Success --'+resultList);
                                       	callEmailQueue(oldEmail,newEmail,oldUserName,oldUserName,clientName);
                                    }
                            	}
                            	System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        		System.debug('Error Field ' + err.getFields());
                        	}
                    	}
                	}
            	}        
        	}   
        }   
	}
    
    public void callEmailQueue(String oldEmail,String newEmail,String oldUserName,String newUserName, String clientName){
        SendUsernameChangeEmailQueueable sendEmailQueueable = new SendUsernameChangeEmailQueueable();
        sendEmailQueueable.oldEmail = oldEmail;
        sendEmailQueueable.newEmail = newEmail;
        sendEmailQueueable.oldUsername = oldUserName;
        sendEmailQueueable.newUsername = newUserName;
        sendEmailQueueable.clientName = clientName;
        if(!Test.isRunningTest()) system.enqueueJob(sendEmailQueueable); 
    }
}