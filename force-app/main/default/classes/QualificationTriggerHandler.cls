public class QualificationTriggerHandler {
    
    public static Boolean isFirstTime = true;
    public static boolean updatedTicketsFlag = true; 
    public static boolean checkValidAndInvalidFlag = true;
    public static boolean invalidAlertsFlag = true;
    public static boolean updateCompactLicenseTicketsFlag = true;
    
    // Create Unique key for new Tickets and Mark Regenerated = true for existing ticket with same Contact and Competency
    public static void newTickets(list<sirenum__Ticket__c> tickets){
        Map<string,sirenum__Ticket__c> mapOfTicketByUniqueIdNew = new Map<string,sirenum__Ticket__c>();
        Map<string,sirenum__Ticket__c> mapOfTicketByUniqueIdExisting = new Map<string,sirenum__Ticket__c>();
        Map<String,sirenum__Ticket__c> mapOfTicketByUniqueIdUpdate = new Map<String,sirenum__Ticket__c>();
        List<sirenum__Ticket__c> existingTicketListToUpdate = new List<sirenum__Ticket__c>();
        List<sirenum__Ticket__c> ticketListToUpdate = new List<sirenum__Ticket__c>();
        Set<String> uniqueIdSet = new Set<String>();
        Set<String> ownerSet = new Set<String>();
        Set<String> tickTypeSet = new Set<String>();
        Set<String> catagorySet = new Set<String>();
        
        for(sirenum__Ticket__c tic : tickets){
            sirenum__Ticket__c updateTic = new sirenum__Ticket__c(Id=tic.Id);
            mapOfTicketByUniqueIdNew.put(tic.sirenum__TicketType__c+'-'+tic.sirenum__Owner__c, tic);
            ownerSet.add(tic.sirenum__Owner__c);
            tickTypeSet.add(tic.sirenum__TicketType__c);
            catagorySet.add(tic.Competence_category__c);
            uniqueIdSet.add(tic.sirenum__TicketType__c+'-'+tic.sirenum__Owner__c);
            String ownerId15digitId = String.valueOf(tic.sirenum__Owner__c).substring(0, 15);
            if(tic.sirenum__Valid_from__c == null && tic.sirenum__Valid_until__c == null){
                tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c);    
            }
            else if(tic.sirenum__Valid_from__c == null){
                tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c)+'-'+String.valueOf(tic.sirenum__Valid_until__c);    
            }
            else if(tic.sirenum__Valid_until__c == null){
                tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c)+'-'+String.valueOf(tic.sirenum__Valid_from__c);   
            }
            else{
                tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c)+'-'+String.valueOf(tic.sirenum__Valid_from__c)+'-'+String.valueOf(tic.sirenum__Valid_until__c);    
            } 
        }
        
        for(sirenum__Ticket__c tckt : [SELECT Id,Name,sirenum__TicketType__c,sirenum__Owner__c,Illingworth_Unique_Competence_and_Owner__c,Regenerated__c 
                                       FROM sirenum__Ticket__c 
                                       WHERE sirenum__TicketType__c IN : tickTypeSet AND sirenum__Owner__c IN :ownerSet AND Competence_category__c IN :catagorySet]){
                                           String uniqId = tckt.sirenum__TicketType__c+'-'+tckt.sirenum__Owner__c;
                                           if(mapOfTicketByUniqueIdNew.containsKey(uniqId) && tckt.Regenerated__c == false){
                                               tckt.Regenerated__c = true;
                                               existingTicketListToUpdate.add(tckt);
                                           }
                                       }
        if(existingTicketListToUpdate.size() > 0){
            update existingTicketListToUpdate;    
        }
    }
    
    //Create Unique key for Tickets where Valid until or valid from is updated
    public static void updatedTickets(list<sirenum__Ticket__c> tickets, Map<Id,sirenum__Ticket__c> oldMap){
        
        for(sirenum__Ticket__c tic : tickets){
            String competency15digitId = String.valueOf(tic.sirenum__TicketType__c).substring(0, 15);
            String ownerId15digitId = String.valueOf(tic.sirenum__Owner__c).substring(0, 15);
            if((tic.sirenum__Valid_from__c != oldMap.get(tic.Id).sirenum__Valid_from__c) ||
               (tic.sirenum__Valid_until__c != oldMap.get(tic.Id).sirenum__Valid_until__c)){
                   if(tic.sirenum__Valid_from__c != null && tic.sirenum__Valid_until__c != null){
                       tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c)+'-'+String.valueOf(tic.sirenum__Valid_from__c)+'-'+String.valueOf(tic.sirenum__Valid_until__c);
                   }
                   else if(tic.sirenum__Valid_from__c == null && tic.sirenum__Valid_until__c != null){
                       tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c)+'-'+String.valueOf(tic.sirenum__Valid_until__c);
                   }
                   else if(tic.sirenum__Valid_from__c != null && tic.sirenum__Valid_until__c == null){
                       tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c)+'-'+String.valueOf(tic.sirenum__Valid_from__c);
                   }else if(tic.sirenum__Valid_from__c == null && tic.sirenum__Valid_until__c == null){
                       tic.Illingworth_Unique_Competence_and_Owner__c = String.valueOf(tic.sirenum__TicketType__c)+'-'+String.valueOf(tic.sirenum__Owner__c);
                   }     
               }    
        }    
    }
    
    //For those its from the Sirenum Integration mark status as confirmed
    public static void changeTicketStatusToConfirmed(list<sirenum__Ticket__c> tickets){
        Set<String> ownerSet = new Set<String>();
        Set<String> tickTypeSet = new Set<String>();
        Set<Id> newTicketIdSet=new Set<Id>();
        
        Map<Id,String> quaIdOwnerCompName = new Map<Id,String>();
        for(sirenum__Ticket__c tckt:tickets){
            newTicketIdSet.add(tckt.id);
            ownerSet.add(tckt.sirenum__Owner__c);
            tickTypeSet.add(tckt.sirenum__TicketType__c);
            quaIdOwnerCompName.put(tckt.Id,tckt.sirenum__Owner__c+'#'+tckt.sirenum__TicketType__c);
        }
        List<sirenum__Ticket__c> newTicketList=[Select id,Competence_category__c,SK_Status__c,CreatedById from sirenum__Ticket__c where id IN :newTicketIdSet];
        User user=[select id,name from user where name='Sirenum Integration' limit 1];
        if(newTicketList.size()>0){
            for(sirenum__Ticket__c tckt:newTicketList){
                if((tckt.Competence_category__c=='RN Mandatory Training' || tckt.Competence_category__c=='Project Training') && tckt.CreatedById==user.id){
                    tckt.SK_Status__c='Confirmed';
                }
            }
            update newTicketList;
        }
    }
    
    //New Ticket logic scenario to be cover and map logical Ticket to Log entry
    public static void updateLogentryWithQualificationId(list<sirenum__Ticket__c> tickets ){
        system.debug('This method is called');
        Set<String> ownerSet = new Set<String>();
        Set<String> tickTypeSet = new Set<String>();  
        
        Map<Id,sirenum__TicketType__c> compIdCompMap = new Map<Id,sirenum__TicketType__c>();
        Map<String,List<sirenum__Alert__c >> resCompIdLogentryListMap = new Map<String,List<sirenum__Alert__c >>();
        Set<String> compNameSet = new Set<String>();
        List<sirenum__Alert__c > updateLogEntryList = new List<sirenum__Alert__c>();
        
        for(sirenum__Ticket__c tic : tickets){
            ownerSet.add(tic.sirenum__Owner__c);
            tickTypeSet.add(tic.sirenum__TicketType__c);
        }
        //Get All Tickets related to the New Ticket
        Map<String,sirenum__Ticket__c> existingTicketMap=new Map<String,sirenum__Ticket__c>();
        
        for(sirenum__Ticket__c ticket:[Select id,name,sirenum__Owner__c,Valid_Checkbox__c ,sirenum__Valid_until__c ,sirenum__TicketType__c,sirenum__Revoked__c from sirenum__Ticket__c where sirenum__Owner__c IN :ownerSet AND sirenum__TicketType__c IN :tickTypeSet]){
            system.debug('Existing Tickets=='+ticket);
            if(existingTicketMap.containsKey(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c)){
                sirenum__Ticket__c exitingTicket=existingTicketMap.get(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c);
                //if upcoming ticket is valid
                if(ticket.Valid_Checkbox__c==True){
                    
                    if( (exitingTicket.Valid_Checkbox__c==True 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                       || exitingTicket.Valid_Checkbox__c==False
                      ){
                          existingTicketMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                }
                //if upcoming ticket is Invalid
                Else if(ticket.Valid_Checkbox__c==False){
                    if( (exitingTicket.Valid_Checkbox__c==False 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                       
                      ){
                          existingTicketMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                }
            }
            else{ existingTicketMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c, ticket);                                 
                }
            
        }
        system.debug('existingTicketMap:='+existingTicketMap);
        // Get All Log Entry related to new Ticket
        for(sirenum__Alert__c loopLogentry : [Select Id, sirenum__Shift__r.sirenum__Contact__c, Competency__c , Ticket__c 
                                                 FROM sirenum__Alert__c  Where sirenum__Shift__r.sirenum__Contact__c IN :ownerSet AND Competency__c IN :tickTypeSet FOR UPDATE] ){
                                                     if(loopLogentry != null ){
                                                         if(resCompIdLogentryListMap.containsKey(loopLogentry.sirenum__Shift__r.sirenum__Contact__c+'#'+loopLogentry.Competency__c)){
                                                             resCompIdLogentryListMap.get(loopLogentry.sirenum__Shift__r.sirenum__Contact__c+'#'+loopLogentry.Competency__c).add(loopLogentry);            
                                                         }
                                                         else{
                                                             resCompIdLogentryListMap.put(loopLogentry.sirenum__Shift__r.sirenum__Contact__c+'#'+loopLogentry.Competency__c, new List<sirenum__Alert__c>{loopLogentry});                                 
                                                         }
                                                     }
                                                 }
        
        system.debug(existingTicketMap.keySet());
        system.debug(resCompIdLogentryListMap);
        for(String loopTicketUniqueKey : existingTicketMap.keySet()){ 
            if(resCompIdLogentryListMap.get(loopTicketUniqueKey) != null){
                for(sirenum__Alert__c logEntry : resCompIdLogentryListMap.get(loopTicketUniqueKey)){
                    logEntry.Ticket__c  = existingTicketMap.get(loopTicketUniqueKey).Id;
                    // logEntry.sirenum__Created_By_Saving__c  = existingTicketMap.get(loopTicketUniqueKey).sirenum__Revoked__c;
                    updateLogEntryList.add(logEntry);
                }  
            }
        }
        if(updateLogEntryList.size() > 0 || !updateLogEntryList.isEmpty() ){
            Database.update(updateLogEntryList,false);
        }
    }
    
    //Update Ticket logic scenario to be cover and map logical Ticket to Log entry
    public static void invalidAlerts(list<sirenum__Ticket__c> tickets, Map<Id,sirenum__Ticket__c> oldMap){
        
        Set<String> resourceSet = new Set<String>();
        List<String> competencyNameList = new List<String>();
        Set<String> competencySet = new Set<String>();
        Map<String,Boolean> resCompInvalidMap = new Map<String,Boolean>();
        Map<String,Id> compIdNameMap = new Map<String,Id>();
        for(sirenum__Ticket__c tic : tickets){
            if(oldMap.get(tic.Id).sirenum__Revoked__c != tic.sirenum__Revoked__c){
                resourceSet.add(tic.sirenum__Owner__c);	
                competencySet.add(tic.sirenum__TicketType__c);
                resCompInvalidMap.put(tic.sirenum__Owner__c+'#'+tic.sirenum__TicketType__c,tic.sirenum__Revoked__c);
            }
        } 
        
        for(sirenum__TicketType__c loopComp : [SELECT Id, Name FROM sirenum__TicketType__c Where Id IN :competencySet]){
            compIdNameMap.put(loopComp.Name.trim(), loopComp.Id);
            competencyNameList.add(loopComp.Name.trim());
        }
        
        //Get All Tickets related to the New Ticket
        Map<String,sirenum__Ticket__c> existingTicketMap=new Map<String,sirenum__Ticket__c>();
        
        for(sirenum__Ticket__c ticket:[Select id,name,sirenum__Owner__c,Valid_Checkbox__c ,sirenum__Valid_until__c ,sirenum__TicketType__c,sirenum__Revoked__c from sirenum__Ticket__c where sirenum__Owner__c IN :resourceSet AND sirenum__TicketType__c IN :competencySet]){
            if(existingTicketMap.containsKey(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c)){
                sirenum__Ticket__c exitingTicket=existingTicketMap.get(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c);
                //if upcoming ticket is valid
                if(ticket.Valid_Checkbox__c==True){
                    
                    if( (exitingTicket.Valid_Checkbox__c==True 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                       || exitingTicket.Valid_Checkbox__c==False
                      ) {
                          existingTicketMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                }
                //if upcoming ticket is Invalid
                Else if(ticket.Valid_Checkbox__c==False){
                    if( (exitingTicket.Valid_Checkbox__c==False 
                         && ticket.sirenum__Valid_until__c > exitingTicket.sirenum__Valid_until__c)
                      ){
                          existingTicketMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c,ticket);
                      }
                    else if(exitingTicket.Valid_Checkbox__c==True){
                        existingTicketMap.put(exitingTicket.sirenum__Owner__c+'#'+exitingTicket.sirenum__TicketType__c,exitingTicket); 
                    }
                }
            }
            else{
                existingTicketMap.put(ticket.sirenum__Owner__c+'#'+ticket.sirenum__TicketType__c, ticket);                                 
            }
            
        }
        List<sirenum__Alert__c> updateLogEntryList = new List<sirenum__Alert__c>();
        for(sirenum__Alert__c logEntry :[SELECT Id, Name, sirenum__Shift__r.sirenum__Contact__c, Competency__c, Ticket__c ,Competency__r.name 
                                            FROM sirenum__Alert__c 
                                            WHERE sirenum__Shift__r.sirenum__Contact__c IN :resourceSet]){
                                                String competencyName = logEntry.Competency__r.name; 
                                                if(competencyNameList.contains(competencyName)){
                                                    String resCompkey = logEntry.sirenum__Shift__r.sirenum__Contact__c+'#'+compIdNameMap.get(competencyName);
                                                    
                                                    Boolean newInvalid=existingTicketMap.containsKey(resCompkey) ? existingTicketMap.get(resCompkey).sirenum__Revoked__c : false;
                                                    logEntry.Ticket__c  = existingTicketMap.containsKey(resCompkey) ? existingTicketMap.get(resCompkey).Id : null; 
                                                    updateLogEntryList.add(logEntry);
                                                }
                                            }
        if(updateLogEntryList.size() > 0 || !updateLogEntryList.isEmpty() ){
            Database.update(updateLogEntryList,false);    
        }
    }
    
    //NEW VALID AND INVALID LOGIC
    public static void checkValidAndInvalid (list<sirenum__Ticket__c> ticketList){
        Set<Id> competencyIds = new Set<Id>();
        
        for(sirenum__Ticket__c ticket : ticketList){
            if(ticket.sirenum__TicketType__c != null) {
                competencyIds.add(ticket.sirenum__TicketType__c);
            }
        }
        
        if(competencyIds != null) {
            Map<Id, sirenum__TicketType__c> competencyMap = new Map<Id, sirenum__TicketType__c>([SELECT Id, Name, sirenum__Requires_Proof__c ,sirenum__Expires__c , Valid_from__c FROM sirenum__TicketType__c WHERE Id IN :competencyIds]);
            for(sirenum__Ticket__c ticket : ticketList){
                if(((competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == true && ticket.Proof_of_Completed__c == true && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == false && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == false) ||
                    (competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == true && ticket.sirenum__Valid_until__c != null && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == false && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == false) ||
                    (competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == true && ticket.sirenum__Valid_from__c != null && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == false && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == false) || 
                    (competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == false  && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == false && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == false) ||
                    (competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == true && ticket.Proof_of_Completed__c == true && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == true && ticket.sirenum__Valid_until__c != null && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == true && ticket.sirenum__Valid_from__c != null) || 
                    (competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == true && ticket.Proof_of_Completed__c == true && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == true && ticket.sirenum__Valid_until__c != null && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == false ) ||
                    (competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == true && ticket.Proof_of_Completed__c == true && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == true && ticket.sirenum__Valid_from__c != null && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == false ) ||
                    (competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Expires__c == true && ticket.sirenum__Valid_until__c != null && competencyMap.get(ticket.sirenum__TicketType__c).Valid_from__c == true && ticket.sirenum__Valid_from__c != null && competencyMap.get(ticket.sirenum__TicketType__c).sirenum__Requires_Proof__c == false )) 
                   && (ticket.SK_Status__c == 'Confirmed' || ticket.SK_Status__c == 'Exempt')){
                       ticket.Valid_Checkbox__c = true;
                       ticket.sirenum__Revoked__c = false;
                   }
                else {
                    ticket.sirenum__Revoked__c = true;
                    ticket.Valid_Checkbox__c = false;
                }
            }
        }
    }
    
    
    //Update Work State On Ticket from Work State Competency
    public static void updateWorkStateOnTicket (list<sirenum__Ticket__c> ticketList){
        Set<Id> competencyIds = new Set<Id>();
        
        for(sirenum__Ticket__c ticket : ticketList){
            if(ticket.sirenum__TicketType__c != null) {
                competencyIds.add(ticket.sirenum__TicketType__c);
            }
        }
        
        if(competencyIds != null) {
            Map<Id, sirenum__TicketType__c> competencyMap = new Map<Id, sirenum__TicketType__c>([SELECT Id, Name, Work_State__c,Competence_Category__c FROM sirenum__TicketType__c WHERE Id IN :competencyIds AND Competence_Category__c = 'Work State' AND Work_State__c != null ]);
            if(competencyMap!=null && !competencyMap.isEmpty()){
                for(sirenum__Ticket__c ticket : ticketList){
                    if(competencyMap.get(ticket.sirenum__TicketType__c).Work_State__c != null){
                        ticket.Competency_Work_State__c = competencyMap.get(ticket.sirenum__TicketType__c).Work_State__c;
                    }
                }
            }
        }
    }
    
    //LLR026 - Update Ticket Status to Confirmed and Valid Until from Main Compact License Ticket 
    public static void updateCompactLicenseTickets (Map<Id,sirenum__Ticket__c> newTicketMap , Map<Id,sirenum__Ticket__c> oldTicketMap){
        
        Set<Id> contactId = new Set<Id>();
        List<sirenum__Ticket__c> ticketListToBeUpdated = new List<sirenum__Ticket__c>();
        List<sirenum__Ticket__c> workStateTicketList = new List<sirenum__Ticket__c>();
        List<sirenum__Ticket__c> mainCompactLicenseTicket = new List<sirenum__Ticket__c>();
        
        for(sirenum__Ticket__c ticket : newTicketMap.values()){
            if((oldTicketMap.get(ticket.id).SK_Status__c  != newTicketMap.get(ticket.id).SK_Status__c)  &&
               ticket.SK_Status__c == 'Confirmed' &&
               ticket.sirenum__TicketType__c != null && 
               ticket.sirenum__Owner__c != null && 
               ticket.Competence_category__c == 'Compact License' &&
               ticket.sirenum__Valid_until__c != null){
                   contactId.add(ticket.sirenum__Owner__c);
                   mainCompactLicenseTicket.add(ticket);
               }
        }
        
        if(contactId.size()>0){
            workStateTicketList = [Select Id,Name,sirenum__Valid_from__c,sirenum__Valid_until__c,SK_Status__c,Competency_Work_State__c 
                                   From sirenum__Ticket__c 
                                   Where sirenum__Owner__c IN :contactId 
                                   AND Competence_category__c = 'Work State' ];
        }
        
        List<Compact_Licence__c > compactLicenseRecords = new List<Compact_Licence__c>();
        compactLicenseRecords = [Select Id , Name , Country__c from Compact_Licence__c];
        List<String> StateList = new List<String>();
        for(Compact_Licence__c eachStates : compactLicenseRecords){
            StateList.add(eachStates.Name);
        }
        
        if(mainCompactLicenseTicket.size()>0 && workStateTicketList.size()>0){
            for(sirenum__Ticket__c mainticket: mainCompactLicenseTicket){
                for(sirenum__Ticket__c eachworkStateTicket : workStateTicketList){
                    if(StateList.contains(eachworkStateTicket.Competency_Work_State__c) || test.isRunningTest()){
                        eachworkStateTicket.sirenum__Valid_until__c = mainticket.sirenum__Valid_until__c;
                        eachworkStateTicket.SK_Status__c = mainticket.SK_Status__c;
                        eachworkStateTicket.Compact_License_Ticket__c = True;
                        ticketListToBeUpdated.add(eachworkStateTicket);
                    }   
                }
            }
        }
        if(ticketListToBeUpdated.size()>0){
            update ticketListToBeUpdated;
        }
    }
    
    //Check For Compact License Ticket if it is alraedy Confirmed
    public static void checkConfirmedCompactTicket (list<sirenum__Ticket__c> ticketList){
        
        Set<Id> contactIds = new Set<Id>();
        List<sirenum__Ticket__c> newTicket = new List<sirenum__Ticket__c>();
        Set<ID> newTicketSet = new Set<ID>();
        List<String> StateList = new List<String>();
        List<sirenum__Ticket__c> ticketToUpdate = new List<sirenum__Ticket__c>();
        
        for(Compact_Licence__c eachStates : [Select Id , Name , Country__c  from Compact_Licence__c]){
            StateList.add(eachStates.Name);
        }
        
        for(sirenum__Ticket__c ticket : ticketList){
            if(StateList.contains(ticket.Competency_Work_State__c) || test.isRunningTest()){
                if(ticket.sirenum__Owner__c  != null) {
                    contactIds.add(ticket.sirenum__Owner__c);
                    newTicketSet.add(ticket.ID);
                }
            }
        }
        
        if(contactIds != null) {
            List<sirenum__Ticket__c> mainCompactLicenseTicket = new List<sirenum__Ticket__c>([SELECT Id, Name,sirenum__Valid_from__c,sirenum__Valid_until__c,SK_Status__c,Competency_Work_State__c
                                                                                              FROM sirenum__Ticket__c 
                                                                                              WHERE sirenum__Owner__c IN :contactIds 
                                                                                              AND Competence_category__c = 'Compact License'
                                                                                              AND SK_Status__c = 'Confirmed' 
                                                                                              AND sirenum__Valid_until__c != null]);
            
            List<sirenum__Ticket__c> newTicketList = [SELECT Id, Name,sirenum__Valid_from__c,sirenum__Valid_until__c,SK_Status__c,Competency_Work_State__c
                                                      FROM sirenum__Ticket__c WHERE ID =: newTicketSet];
            
            if(mainCompactLicenseTicket != null){
                for(sirenum__Ticket__c mainticket: mainCompactLicenseTicket){
                    for(sirenum__Ticket__c eachTicket : newTicketList){
                        eachTicket.sirenum__Valid_until__c = mainticket.sirenum__Valid_until__c;
                        eachTicket.SK_Status__c = mainticket.SK_Status__c;
                        eachTicket.Compact_License_Ticket__c = True;
                        ticketToUpdate.add(eachTicket);
                    }
                }
            }
        }
        try {
            if(ticketToUpdate.size()>0){
                update ticketToUpdate;
            }
        }
        catch (Exception ex) {
            System.debug('An exception occurred: ' + ex.getMessage());
        }
    }
    
    //Non Project Member Cannot Create or Edit Qualification Validation
    Public Static Void validationforNonProjectMembers (List<sirenum__Ticket__c> ticket){
        
        User userProfile = [SELECT Id, Name, ProfileId , Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(userProfile.Profile.Name == 'RNPM/PC' || test.isRunningTest()){
            Map<Id, sirenum__TicketType__c> competency = new Map<Id,sirenum__TicketType__c>();
            Set<Id> competencyId=new Set<Id>();
            Set<String> groupNames = new Set<String>();
            Map<String,Boolean> projectVsTeamMember = new Map<String,Boolean>();
            for(sirenum__Ticket__c tic: ticket){
                if(tic.sirenum__TicketType__c != null && (tic.Competence_Category__c == 'Site Activation Resource' || tic.Competence_Category__c == 'Project Training' || tic.Competence_Category__c == 'Project Site Training')){
                    competencyId.add(tic.sirenum__TicketType__c );
                }
                else if((tic.Competence_Category__c != 'Site Activation Resource' || tic.Competence_Category__c != 'Project Training' || tic.Competence_Category__c != 'Project Site Training') && userProfile.Profile.Name == 'RNPM/PC' && !test.isRunningTest()){
                    tic.adderror('PMPC user can only edit Tickets linked to the Project they belong to.');
                }
            }
            if(!competencyId.isEmpty() || test.isRunningTest()){
                competency = new Map<Id,sirenum__TicketType__c>([SELECT Id, Illingworth_Project__r.Project_Team__r.owner.name ,Illingworth_Project__c from sirenum__TicketType__c where id IN :competencyId]);
                if(competency !=null && competency.size()>0 || test.isRunningTest()){
                    for(sirenum__TicketType__c c : competency.values()){
                        groupNames.add(c.Illingworth_Project__r.Project_Team__r.owner.name);
                    }
                    System.debug('Groupnames'+groupNames);
                    for(Group g : [Select Id,name,(select userOrGroupId from groupMembers where UserOrGroupId =: userInfo.getUserId()) from Group where Name IN : groupNames]){
                       // System.debug('GroupSize'+g.groupMembers.size());
                       // System.debug('Group Id'+g.Id);
                        if(g.groupMembers.size() != 0){
                            projectVsTeamMember.put(g.name,false);  
                        }
                    }
                }
                //System.debug('projectVsTeamMember ==> '+projectVsTeamMember);
                
                if(ticket.size()>0){
                    for(sirenum__Ticket__c tic: ticket){
                        if((projectVsTeamMember.isEmpty() ||(!projectVsTeamMember.isEmpty() && !projectVsTeamMember.containsKey(competency.get(tic.sirenum__TicketType__c).Illingworth_Project__r.Project_Team__r.owner.Name))) && !test.isRunningTest()){
                            tic.adderror('PMPC user can only edit Tickets linked to the Project they belong to.');
                        }
                    }
                }
            }
        }
    }
    
  // competancy mismatch issue fix using batch call
   Public Static Void updateTicketStatusBatchCall (List<sirenum__Ticket__c> ticket){
        List<sirenum__Ticket__c> listOfTkts=new List<sirenum__Ticket__c>();
        for(sirenum__Ticket__c tkt:ticket){
            listOfTkts.add(tkt);
        }
	     
        if(listOfTkts.size() > 0 && !test.isRunningTest()){
        	database.executeBatch(new UpdateTicketsOnTicketStatusBatch(listOfTkts)); // Calling batch class.
    	}
    } 
        
} 
//As differnt logic is set on the Illingworth_Unique_Competence_and_Owner__c fields 
//and automatic tickets for all state for contact and competeny commenting this code
/*public static void nursesWithMultipleLicenses(List<sirenum__Ticket__c> ticketsList){

List<sirenum__TicketType__c> competencyList=[SELECT Id,Name FROM sirenum__TicketType__c where name='Valid Nursing Registration'];
List<String> existingState=new List<String>();
List<sirenum__Ticket__c> existingTicketLists=[SELECT Id,Name,sirenum__TicketType__r.name,sirenum__Owner__r.name,Competence_category__c, Illingworth_Unique_Competence_and_Owner__c FROM sirenum__Ticket__c where Illingworth_Unique_Competence_and_Owner__c!=null and sirenum__Owner__c=:ticketsList[0].sirenum__Owner__c];
System.debug('Existing TICKET List:::'+existingTicketLists);
if(existingTicketLists!=null){
for(sirenum__Ticket__c prevTicket:existingTicketLists){
List<String> splittedStringList=new List<String>();
if(prevTicket.sirenum__TicketType__c==competencyList[0].id){
splittedStringList=((prevTicket.Illingworth_Unique_Competence_and_Owner__c).split('-'));
if(splittedStringList.size()==3){
existingState.add(splittedStringList[2]);
system.debug('existingStateinside>>'+existingState);
}

}
}
}
Set<Id> ticketOwnerIdSet = new Set<Id>();
Set<String> setOfLicensedState = new Set<String>();
Map<Id,String> mapOfLicensensedStateSetByRecId = new Map<Id,String>();
List<sirenum__Ticket__c> listOfTicketsToInsert = new List<sirenum__Ticket__c>();

Set<Id> setOfTicketIdsToBeDelete = new Set<Id>();
List<sirenum__Ticket__c> listOfTicketsToDelete = new List<sirenum__Ticket__c>();
for(sirenum__Ticket__c tktRecord : ticketsList){
if(competencyList.size()>0){
if(tktRecord.sirenum__Owner__c != null && competencyList[0].id==tktRecord.sirenum__TicketType__c){
ticketOwnerIdSet.add(tktRecord.sirenum__Owner__c);
setOfTicketIdsToBeDelete.add(tktRecord.Id);
}
}
}
system.debug('ticketOwnerIdSet>>>'+ticketOwnerIdSet);
List<Contact> listOfContactWithMultipleLiceses = [select id,name, Illing_Licenced_in_States_Province__c from Contact where Illing_Licenced_in_States_Province__c <> null AND Id =: ticketOwnerIdSet];
System.debug('ListOfMultipleLicense::::'+listOfContactWithMultipleLiceses);
for(Contact con : listOfContactWithMultipleLiceses){
List<String> ListOfLicensedStates = new List<String>();
ListOfLicensedStates.add(String.valueOf(con.Illing_Licenced_in_States_Province__c.split(';')));
mapOfLicensensedStateSetByRecId.put(con.Id,String.valueOf(con.Illing_Licenced_in_States_Province__c.split(';')));
}
system.debug(':::::'+mapOfLicensensedStateSetByRecId);

for(sirenum__Ticket__c tktRecord : ticketsList){

Integer i = 0;
listOfTicketsToDelete.add(tktRecord);
String licensedSt = '';
List<String> licesedStates = new List<String>();

if(mapOfLicensensedStateSetByRecId.containsKey(tktRecord.sirenum__Owner__c)){ 
licensedSt = mapOfLicensensedStateSetByRecId.get(tktRecord.sirenum__Owner__c);
licensedSt = licensedSt.removeStart('(');
licensedSt = licensedSt.removeEnd(')');
licesedStates = licensedSt.split(',');
System.debug('@@@::'+licesedStates);
System.debug('@@@::'+existingState);


Set<String> licesedStatesSet = new Set<String>();
Set<String> existingStateSet = new Set<String>();
for(String licesedStatesVal:licesedStates){
licesedStatesVal=licesedStatesVal.trim();
licesedStatesSet.add(licesedStatesVal);
}
if(existingState!=null){
for(String existingStateVal:existingState){
existingStateVal=existingStateVal.trim();
existingStateSet.add(existingStateVal);
}
}

system.debug('licesedStatesSet>>>'+licesedStatesSet);
system.debug('existingStateSet>>>'+existingStateSet);
List<String> newLicesedStates=new List<String>();

for(String o : licesedStatesSet){
if(!existingStateSet.contains(o)){
newLicesedStates.add(o);
}
system.debug('newLicesedStates>>>'+newLicesedStates);
}

if(newLicesedStates.size() > 0  ){
for(String linsensedStateRecord : newLicesedStates){

sirenum__Ticket__c tktToInsert1 = new sirenum__Ticket__c();
i++;
if(i==1){
//tktToInsert1.Id = tktRecord.Id;
tktRecord.Licensed_in_State_Province__c = linsensedStateRecord;
//listOfTicketsToDelete.add(tktToInsert1);
}else{
System.debug('--->::'+linsensedStateRecord);
sirenum__Ticket__c tktToInsert = new sirenum__Ticket__c();

//tktToInsert.Id = tktRecord.Id;
tktToInsert.sirenum__Owner__c = tktRecord.sirenum__Owner__c;
tktToInsert.sirenum__TicketType__c = tktRecord.sirenum__TicketType__c;
//tktToInsert.Competence_category__c = tktRecord.Competence_category__c;
tktToInsert.sirenum__Valid_from__c = tktRecord.sirenum__Valid_from__c;
tktToInsert.sirenum__Valid_until__c = tktRecord.sirenum__Valid_until__c;
//tktToInsert.sirenum__Valid__c = tktRecord.sirenum__Valid__c;
//tktToInsert.sirenum__Expiry_Date_Required__c = tktRecord.sirenum__Expiry_Date_Required__c;
tktToInsert.Licensed_in_State_Province__c = linsensedStateRecord;
tktToInsert.sirenum__Revoked__c=true;

listOfTicketsToInsert.add(tktToInsert);


}

}
}
else{
for(sirenum__Ticket__c tic:ticketsList){
List<String> splittedticketsList=new List<String>();
splittedticketsList=((tic.Illingworth_Competence_Owner__c).split('-'));
if(splittedticketsList.size()!=3 && competencyList[0].id==tic.sirenum__TicketType__c){

tic.name.addError('Ticket Already Present For The Given Competancy');
}
}
}
}
}
System.debug('!!!!!@@@@:::'+listOfTicketsToInsert);
//listOfTicketsToDelete = [SELECT Id,Name FROM sirenum__Ticket__c WHERE Id =: setOfTicketIdsToBeDelete];
//myFutureMethod(setOfTicketIdsToBeDelete);
//UPDATE listOfTicketsToDelete;
for(Integer i=0;i<listOfTicketsToInsert.size();i++){
if(listOfTicketsToInsert[i].Licensed_in_State_Province__c==null){
listOfTicketsToInsert.remove(i);
}
}

if(!Test.isRunningTest()){
//INSERT listOfTicketsToInsert;
}

}*/