trigger QualificationTrigger on sirenum__Ticket__c (before insert, after insert,before update,after update) {
    
    if( Label.Qualification_Trigger_Flag =='True') { 
        
        if(trigger.isbefore){ 
            
            if(trigger.isinsert){
                QualificationTriggerHandler.newTickets(trigger.new);
                QualificationTriggerHandler.updateWorkStateOnTicket(trigger.new);
                QualificationTriggerHandler.checkValidAndInvalid(trigger.new);
                if(QualificationTriggerHandler.isFirstTime){
                    QualificationTriggerHandler.isFirstTime = false; 
                }   
            }
            if(trigger.isupdate){
                QualificationTriggerHandler.validationforNonProjectMembers(trigger.new);
                QualificationTriggerHandler.updatedTickets(trigger.new, trigger.oldMap);
                QualificationTriggerHandler.checkValidAndInvalid(trigger.new);
                QualificationTriggerHandler.updateCompactLicenseTickets(Trigger.newMap,Trigger.oldMap);
            }
        }
        
        if(trigger.isAfter){
            
            if(trigger.isinsert){
                QualificationTriggerHandler.updateLogentryWithQualificationId(trigger.new);
                QualificationTriggerHandler.checkConfirmedCompactTicket(trigger.new);
                QualificationTriggerHandler.changeTicketStatusToConfirmed(trigger.new);
                QualificationTriggerHandler.updateTicketStatusBatchCall(trigger.new);
             
            }
            if(trigger.isupdate){
                QualificationTriggerHandler.invalidAlerts(trigger.new, trigger.oldMap);  
            } 
        }
    }
}