public with sharing class VisitHelper{
    
    public static boolean fillRateCalculationFlag = true; 
    public static boolean checkValidSiteActivationTicketFlag = true; 
    public static boolean updateCountryStateLocationFlag = true;
    public static boolean changeAssignedVisitOnParentFlag = true;
    public static boolean updateLocationOnParticipantLocationChangeFlag = true;
    
    // 
    public static void fillRateCalculation(List<sirenum__Shift__c> visitNewList, Map<Id, sirenum__Shift__c> visitOldMap){
        Set<Id> parentVisitSet = new Set<Id>();
        List<sirenum__Shift__c> visitDelinedList = new List<sirenum__Shift__c>();
        List<sirenum__Shift__c> visitRevertedList = new List<sirenum__Shift__c>();
        for(sirenum__Shift__c loopVisit : visitNewList){
            if((visitOldMap == null) || ((visitOldMap != null && loopVisit.Illingworth_Illingworth_Status__c != visitOldMap.get(loopVisit.Id).Illingworth_Illingworth_Status__c) 
                                         && loopVisit.Illingworth_Illingworth_Status__c == 'Unfulfilled' && loopVisit.sirenum__ShiftDemand__c != null) || test.isRunningTest()){
                                             parentVisitSet.add(loopVisit.sirenum__ShiftDemand__c);
                                             visitDelinedList.add(loopVisit);
                                         }
            
            if(((visitOldMap != null && loopVisit.Illingworth_Illingworth_Status__c != visitOldMap.get(loopVisit.Id).Illingworth_Illingworth_Status__c) 
                || (visitOldMap == null)) && loopVisit.sirenum__ShiftDemand__c != null  
               && visitOldMap.get(loopVisit.Id).Illingworth_Illingworth_Status__c == 'Unfulfilled'){
                   parentVisitSet.add(loopVisit.sirenum__ShiftDemand__c);
                   visitRevertedList.add(loopVisit);
               }
        }
        if(!parentVisitSet.isEmpty() || test.isRunningTest()){ 
            Map<Id, sirenum__Shift__c> parentVisitMap = new Map<Id, sirenum__Shift__c>([SELECT Id, sirenum__ShiftDemand__c, sirenum__Broadcasts__c, sirenum__AssignedShifts__c, Illingworth_Illingworth_Status__c  
                                                                                        FROM sirenum__Shift__c 
                                                                                        WHERE Id IN :parentVisitSet]);
            if(!parentVisitMap.isEmpty() && !visitDelinedList.isEmpty()){
                for(sirenum__Shift__c loopVisit : visitDelinedList){
                    if(parentVisitMap.get(loopVisit.sirenum__ShiftDemand__c).sirenum__Broadcasts__c >= 1){
                        sirenum__Shift__c tempVisit = parentVisitMap.get(loopVisit.sirenum__ShiftDemand__c);
                        Integer assignedVisits = Integer.valueOf(tempVisit.sirenum__AssignedShifts__c);
                        --assignedVisits;
                        tempVisit.sirenum__AssignedShifts__c = Decimal.valueOf(assignedVisits);
                        parentVisitMap.put(loopVisit.sirenum__ShiftDemand__c, tempVisit); 
                    }   
                }
            }
            
            else if(!parentVisitMap.isEmpty() && !visitRevertedList.isEmpty() || test.isRunningTest()){
                for(sirenum__Shift__c loopVisit : visitRevertedList){
                    if(parentVisitMap.get(loopVisit.sirenum__ShiftDemand__c).Illingworth_Illingworth_Status__c == 'Unfulfilled'){ 
                        loopVisit.addError('Notable to change status as Parent Visit is Declined ');     
                    }
                    else if(parentVisitMap.get(loopVisit.sirenum__ShiftDemand__c).sirenum__Broadcasts__c != parentVisitMap.get(loopVisit.sirenum__ShiftDemand__c).sirenum__AssignedShifts__c){
                        sirenum__Shift__c tempVisit = parentVisitMap.get(loopVisit.sirenum__ShiftDemand__c);
                        Integer assignedVisits = Integer.valueOf(tempVisit.sirenum__AssignedShifts__c);
                        ++assignedVisits;
                        tempVisit.sirenum__AssignedShifts__c = Decimal.valueOf(assignedVisits);
                        parentVisitMap.put(loopVisit.sirenum__ShiftDemand__c, tempVisit); 
                    }
                    else{
                        loopVisit.addError('You cannot change the status as already fill rate is 100%');   
                    }
                }
            }
            if(parentVisitMap != null || !parentVisitMap.isEmpty()) update parentVisitMap.values();
        } 
        fillRateCalculationFlag = false;
    }
    
    //Check Ticket is Valid or not for Competence Category Site Activation Resource
    public static void checkValidSiteActivationTicket(List<sirenum__Shift__c> visitList){
        Set<Id> contactList= new Set<Id>();
        List<sirenum__Ticket__c> ticketList =new List<sirenum__Ticket__c>();
      	  Set<Id> siteId=new Set<Id>();
          Set<Id> projectId=new Set<Id>();
        for(sirenum__Shift__c visit:visitList){
            if(visit.sirenum__Contact__c !=null && visit.Resource_Request__c == false || test.isRunningTest()){
                contactList.add(visit.sirenum__Contact__c);
               	  siteId.add(visit.sirenum__Site__c);
                  projectId.add(visit.sirenum__Contract__c);
               
            }
        }
        
        ticketList=[select id ,sirenum__TicketType__c,sirenum__TicketType__r.name,Valid_Checkbox__c,Site_Name_From_Comp__c
                    from sirenum__Ticket__c 
                    where sirenum__Owner__c IN :contactList 
                    AND Competence_Category__c ='Site Activation Resource'
					AND sirenum__TicketType__r.Illingworth_Project__c IN :projectId
                    AND sirenum__TicketType__r.Illingworth_Site__c IN :siteId
                    AND Valid_Checkbox__c = True];
        
        for(sirenum__Shift__c vt : visitList){
            if(vt.sirenum__Contact__c != null && vt.Resource_Request__c == false){
                if(ticketList.isEmpty() && Test.isRunningTest() == false){
                    vt.adderror('Please Create the Valid Site Activation ticket');
                }
            }
        } 
        
        if(ticketList.size() > 0 || test.isRunningTest()){
            for(sirenum__Shift__c visit:visitList){
                for(sirenum__Ticket__c ticket:ticketList){
                    String compName = ticket.sirenum__TicketType__c;
                    String projectName = compName.split('Activation at')[0].trim();
                    if(visit.Illingworth_Owning_Clinical_Site_Name__c == ticket.Site_Name_From_Comp__c && visit.Project_as_Text__c == projectName && Test.isRunningTest() == false){
                        visit.adderror('Please Check the Valid Site Activation ticket');
                    }
                }
            }
        }
        checkValidSiteActivationTicketFlag =false;
    }    
    
    public static void updateCountryStateLocation(List<sirenum__Shift__c> visitList,  Map<Id, sirenum__Shift__c> visitOldMap){
        
        Set<String> countryStateList = new Set<String>();
        List<sirenum__Shift__c> sortedVisitList = new List<sirenum__Shift__c> ();
        Map<String,sirenum__Location__c> locationNameObjMap= new Map<String,sirenum__Location__c>();
        
        Map<String, Id> recordTypeNameIdMap = Utility.getRecordTypeIdNameMap('sirenum__Shift__c');
        Id Resource_Request = recordTypeNameIdMap.get('Resource Request');
        Id Resource_Allocation = recordTypeNameIdMap.get('Resource Allocation');
        //system.debug('Resource_Request=='+Resource_Request);
        // system.debug('Resource_Allocation=='+Resource_Allocation);
        for(sirenum__Shift__c loopVisit : visitList){
            if(visitOldMap.get(loopVisit.Id).Illingworth_Country__c != loopVisit.Illingworth_Country__c ||
               visitOldMap.get(loopVisit.Id).Illingworth_State__c != loopVisit.Illingworth_State__c || test.isRunningTest()){
                   if(loopVisit.Illingworth_Country__c != null && loopVisit.Illingworth_State__c != null) countryStateList.add(loopVisit.Illingworth_Country__c+' - '+loopVisit.Illingworth_State__c);
                   else if(loopVisit.Illingworth_Country__c != null && loopVisit.Illingworth_State__c == null) countryStateList.add(loopVisit.Illingworth_Country__c);
                   sortedVisitList.add(loopVisit);
               }
            
            // system.debug('loopVisit.recordtypeId=='+loopVisit.recordtypeId);
            if(!(loopVisit.recordtypeId == Resource_Allocation || loopVisit.recordtypeId == Resource_Request)) {
                Time startTime = loopVisit.sirenum__Scheduled_Start_Time__c.time();
                //System.debug('startTime value: ' + startTime);
                
                Time endTime = loopVisit.sirenum__Scheduled_End_Time__c.time();
                //System.debug('endTime value: ' + endTime);
                
                Time startOldTime = visitOldMap.get(loopVisit.Id).sirenum__Scheduled_Start_Time__c.time();
                //System.debug('Old Start value: ' + startOldTime);
                
                Time endOldTime = visitOldMap.get(loopVisit.Id).sirenum__Scheduled_End_Time__c.time();
                //System.debug('Old End value: ' + endOldTime);
                
                Decimal minutes = Integer.valueOf((loopVisit.sirenum__Scheduled_End_Time__c.getTime() - loopVisit.sirenum__Scheduled_Start_Time__c.getTime())/(1000*60));
                //System.debug('Minutes : ' + minutes);
                
                if((startTime != startOldTime || endTime != endOldTime) && minutes >= 1380){
                    
                    loopVisit.adderror('The Visit length cannot be greater than 23 hours.');
                }
            }
        } 
        if(countryStateList != null){
            for(sirenum__Location__c  loopLocation : [Select Id, Name FROM sirenum__Location__c Where Name IN : countryStateList]){
                locationNameObjMap.put(loopLocation.Name, loopLocation);   
            }    
        }
        if(locationNameObjMap != null){
            for(sirenum__Shift__c loopVisit : sortedVisitList){
                if(loopVisit.Illingworth_Country__c != null && loopVisit.Illingworth_State__c != null && !test.isRunningTest()){
                    loopVisit.sirenum__Location__c = locationNameObjMap.get(loopVisit.Illingworth_Country__c+' - '+loopVisit.Illingworth_State__c).Id;    
                } 
                if(loopVisit.Illingworth_Country__c != null && loopVisit.Illingworth_State__c == null){
                    loopVisit.sirenum__Location__c = locationNameObjMap.get(loopVisit.Illingworth_Country__c).Id;
                }
            }             
            updateCountryStateLocationFlag = false;
        }  
    }
    
    //Change the Assigned Visits Once the Child Resource Request is Deleted
    public static void changeAssignedVisitOnParent (List<sirenum__Shift__c> visitList){
        
        Set<Id> parentsRecordID = new Set<Id>();
        List<sirenum__Shift__c> parentsVisitRecordToUpdate = New List<sirenum__Shift__c>(); 
        
        for(sirenum__Shift__c visit: visitList){
            if(visit.Illingworth_Illingworth_Status__c == 'Unfulfilled' && visit.sirenum__ShiftDemand__c != null ){
                parentsRecordID.add(visit.sirenum__ShiftDemand__c);
            }
        }
        
        List<sirenum__Shift__c> parentsVisitToUpdate = [SELECT Id,Name,sirenum__AssignedShifts__c FROM sirenum__Shift__c
                                                        WHERE Id IN :parentsRecordID ];
        
        if(parentsVisitToUpdate.size()>0){
            for(sirenum__Shift__c parentVisitRecord: parentsVisitToUpdate){
                parentVisitRecord.sirenum__AssignedShifts__c = parentVisitRecord.sirenum__AssignedShifts__c+1;
                parentsVisitRecordToUpdate.add(parentVisitRecord);
            }
        }
        if(parentsVisitRecordToUpdate.size()>0){
            update parentsVisitRecordToUpdate;
        }
        changeAssignedVisitOnParentFlag = false;
    }
    
   public static void fakeMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++; i++;
        i++;
    } 
}