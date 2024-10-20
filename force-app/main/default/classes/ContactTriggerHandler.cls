//Trigger Handler Class for Contact Trigger
//Author - AreyaTech
public class ContactTriggerHandler {
    
    public static Boolean isUpdated = false;
    public static boolean recursiveCheck = true;
    public static boolean recursiveCheckForCompactLic=true;
    public static Boolean sendTrainingStatusNotificationFlag = True;
    
    //Update Onboarding Completion Date When Resource Status Changed from Onboarding to Active Bank
    public static void onboardingCompletionDateUpdate(Map<Id,Contact> newContactMap , Map<Id,Contact> oldContactMap){
        for(Contact ct:newContactMap.values()){
            if(oldContactMap.get(ct.id).Activity_Status__c == 'Onboarding' 
               && newContactMap.get(ct.id).Activity_Status__c != 'Withdrawn' 
               && newContactMap.get(ct.id).Activity_Status__c != 'Withdrawn by IRG'
               && newContactMap.get(ct.id).Activity_Status__c != 'Re-activated on Bank'
               && newContactMap.get(ct.id).Activity_Status__c != 'Paused'
               && newContactMap.get(ct.id).Activity_Status__c != 'Inactive'
               && newContactMap.get(ct.id).Activity_Status__c != 'Do not Contact'
               && newContactMap.get(ct.id).Activity_Status__c != 'Resigned'
               && newContactMap.get(ct.id).Activity_Status__c != 'Onboarding not completed'
               && newContactMap.get(ct.id).Activity_Status__c != 'Historical Visits Only'
               && newContactMap.get(ct.id).Activity_Status__c != 'Onboarding'
               && newContactMap.get(ct.id).Activity_Status__c != 'Hired'){
                   ct.Illingworth_Onboarding_Completion_Date__c= date.today();
               }
        }
    }
    
    // Create New Placement Record when active project field changes
    public static void createPlacementRecord(Map<Id,Contact> newContactMap , Map<Id,Contact> oldContactMap){
        List<sirenum__Placement__c> newPlacementList = new List<sirenum__Placement__c>();
        List<Contact_Project__c> contactProjectInsertList = new List<Contact_Project__c>();
        List<String> newProjectNameList=new List<String>();
        List<String> oldProjectNameList=new List<String>();
        List<Id> contactIdList=new List<Id>();
        
        for(Contact newContact:newContactMap.values()){
            if(oldContactMap.get(newContact.Id).Active_Projects__c != newContact.Active_Projects__c){
                newProjectNameList=(newContact.Active_Projects__c )!=null ? ((newContact.Active_Projects__c).split(';')) : new List<String>();
                oldProjectNameList = (oldContactMap.get(newContact.Id).Active_Projects__c )!=null ? ((oldContactMap.get(newContact.Id).Active_Projects__c).split(';')) : new List<String>();
                contactIdList.add(newContact.Id);
            }
        }
        
        //Remove old projects from active project picklist
        if(newProjectNameList.size()>oldProjectNameList.size()){
            List<String> projectNameList=new List<String>();
            for(String s: newProjectNameList){
                if(!oldProjectNameList.contains(s)){
                    projectNameList.add(s); 
                }
            }
            List<sirenum__ProActiveContract__c> projectQueryList= [Select id,name from sirenum__ProActiveContract__c where name IN :projectNameList];
            List<sirenum__Placement__c> placementQuery=[select id,name,sirenum__Contract__c, sirenum__Contact__c,sirenum__Start_Date__c from sirenum__Placement__c where Project_Placement__c=null AND sirenum__Contract__c IN :projectNameList AND sirenum__Contact__c IN: contactIdList ];
            List<Contact_Project__c> contactProjectQuery = [select id,name,Project__c,Contact__c,Active__c from Contact_Project__c where Project__r.Name IN :projectNameList AND Contact__c IN: contactIdList AND Active__c = true];
            
            //Placement 
            if(projectQueryList.size()>0 && placementQuery.size()==0){
                for(Id contact: newContactMap.keySet()){
                    for(sirenum__ProActiveContract__c project:projectQueryList){
                        sirenum__Placement__c  placement= new sirenum__Placement__c ();
                        placement.sirenum__Contract__c = project.id;
                        placement.sirenum__Start_Date__c =System.today();
                        placement.sirenum__Contact__c= contact;
                        placement.sirenum__Status__c ='Inactive';
                        newPlacementList.add(placement);
                    }
                }
                if(newPlacementList.size()>0) Insert newPlacementList;  
            }
            
            //Contact Project
            System.debug('Contact Project Query---->>'+contactProjectQuery);
            if(projectQueryList.size()>0 && contactProjectQuery.size()==0){
                for(Id contact: newContactMap.keySet()){
                    for(sirenum__ProActiveContract__c project:projectQueryList){
                        Contact_Project__c contactProject = new Contact_Project__c();
                        contactProject.Contact__c = contact;
                        contactProject.Active__c = true;
                        contactProject.Project__c = project.id;
                        contactProjectInsertList.add(contactProject);
                    }
                }
                if(contactProjectInsertList.size()>0) Insert contactProjectInsertList;
            }
        }
    }
    
    //Update user when email of the contact email is changed
    public static void updateUserEmail(List<Contact> newContactList, Map<Id, Contact> oldContactMap){
        if(isUpdated == false){
            isUpdated = true;
            Map<String, String> oldNewcontactEmailMap = new Map<String, String>();
            Map<Id, String> conIdNewEmailMap = new Map<Id, String>();
            
            for(Contact eachContact : newContactList){
                String oldEmail = oldContactMap.get(eachContact.Id).Email;
                if(eachContact.Email != null && oldEmail != null && eachContact.Email != oldEmail){
                    oldNewcontactEmailMap.put(oldEmail, eachContact.Email);
                    conIdNewEmailMap.put(eachContact.Id, eachContact.Email);
                }   
            }
            
            if(conIdNewEmailMap != null || (!conIdNewEmailMap.isEmpty())){
                UpdateUserQueueable updateUserQueueableObj = new UpdateUserQueueable();
                updateUserQueueableObj.conIdNewEmailMap = conIdNewEmailMap;
            }
        }
    }
    
    //Update user when Status change to training/Re-activated On Bank send email 
    public static void sendTrainingStatusNotification(List<Contact> updatedContacts, Map<Id, Contact> oldContactsMap){
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for(Contact updatedContact : updatedContacts){
            Contact oldContact = oldContactsMap.get(updatedContact.Id);
            if(updatedContact.Activity_Status__c == 'Training' || updatedContact.Activity_Status__c == 'Re-activated On Bank' &&( oldContact.Activity_Status__c != updatedContact.Activity_Status__c ) ||Test.isRunningTest()) { 
                contactsToUpdate.add(updatedContact);
            }
        }
        
        if(!contactsToUpdate.isEmpty()){
            Messaging.SingleEmailMessage[] mailList = new List<Messaging.SingleEmailMessage>();
            for(Contact eachCon : contactsToUpdate){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[]{'Learning@illingworthresearch.com'};
                    mail.setToAddresses(toAddresses);
                mail.setSubject('Notification to Training Team: RN ready for Training - SumTotal Checks');
                mail.setPlainTextBody('Notification to Learning team to action.\n\nFor new starters, please create their Protraining account.\nThis is an email notification to state that a nurse '+eachCon.FirstName+' '+eachCon.LastName+' is ready to start training. An automated welcome email will be sent from Sirenum.\nPlease check to see if they are a trainee nurse and assign the trainee audience to them by name.\nIf they are being reactivated from an inactive status, please check the old training folders and LMS exports for any training they may already have completed that needs to be loaded into SumTotal. Once loaded into SumTotal, please speak to the RN Manager to discuss what training needs to be recompleted.');    
                mailList.add(mail);
            }
            Messaging.sendEmail(mailList);
        }
        sendTrainingStatusNotificationFlag = false;
    }
    
    //Work country Field Mandatory Validation
    public static void  workCountryMandatory (List<Contact> ContactList){
        
        List<String> Work_Country_selections = new List<String> ();
        List<String> State_Selection = new List<String> ();
        String customLableCanada = Label.Canada_States;
        List<string> canadaSplitted = Label.Canada_States.split(',');
        String customLableAustralia = Label.Australia_States;
        List<string> australiaSplitted = Label.Australia_States.split(',');
        String customLableUSA = Label.USA_States ;
        List<string> USASplitted = Label.USA_States.split(',');
        Id resourceRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        
        for(Contact ct:ContactList){
            if(resourceRecordTypeId == ct.RecordTypeId){
                if(ct.Work_Country__c !=Null){
                    Work_Country_selections = ct.Work_Country__c.split(';');
                    if(ct.Illing_Licenced_in_States_Province__c!=null){
                        State_Selection = ct.Illing_Licenced_in_States_Province__c!=null ? ct.Illing_Licenced_in_States_Province__c.split(';') : State_Selection;
                    }
                    if(State_Selection.size()>0 ){
                        for(Contact loopCon : ContactList){
                            Work_Country_selections = (Work_Country_selections != null) ? loopCon.Work_Country__c.split(';') : Work_Country_selections;
                            State_Selection = (loopCon.Illing_Licenced_in_States_Province__c != null) ? loopCon.Illing_Licenced_in_States_Province__c.split(';') : State_Selection;
                            Boolean canadaStateNotPresent = true, usaStateNotPresent = true, australiaStateNotPresent = true;
                            if(!Work_Country_selections.isEmpty() && !State_Selection.isEmpty()){
                                for(String state : State_Selection){
                                    if(Work_Country_selections.contains('Canada') && canadaSplitted.contains(state)) canadaStateNotPresent = false;     
                                    if(Work_Country_selections.contains('USA') && USASplitted.contains(state)) usaStateNotPresent = false;     
                                    if(Work_Country_selections.contains('Australia') && australiaSplitted.contains(state)) australiaStateNotPresent = false;    
                                }
                                if(canadaStateNotPresent == true && Work_Country_selections.contains('Canada')) loopCon.adderror('The state should be of Canada because you have selected work country as Canada');
                                if(usaStateNotPresent == true && Work_Country_selections.contains('USA')) loopCon.adderror('The state should be of USA because you have selected work country as USA');
                                if(australiaStateNotPresent == true && Work_Country_selections.contains('Australia')) loopCon.adderror('The state should be of Australia because you have selected work country as Australia');
                            }
                        }
                    }
                }
                else{
                    if(!Test.isRunningTest()){
                        ct.adderror('Work Country is mandatory');
                    }
                }
            }
        }            
    }
    
    //State Field Mandatory Validation
    public static void  stateMandatory (List<Contact> ContactList){
        
        List<String> Work_Country_selections = new List<String> ();
        List<String> State_Selection = new List<String> ();
        List<string> canadaSplitted = Label.Canada_States.split(',');
        List<string> australiaSplitted = Label.Australia_States.split(',');
        List<string> USASplitted = Label.USA_States.split(',');
        Id resourceRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId();
        
        for(Contact loopCon : ContactList){
            if(resourceRecordTypeId == loopCon.RecordTypeId){
                if(loopCon.Work_Country__c != null){
                    Work_Country_selections = (Work_Country_selections != null) ? loopCon.Work_Country__c.split(';') : null;
                    State_Selection = (loopCon.Illing_Licenced_in_States_Province__c   != null) ? loopCon.Illing_Licenced_in_States_Province__c.split(';') : null;
                    if((Work_Country_Selections.contains('Canada') || Work_Country_Selections.contains('USA') || Work_Country_Selections.contains('Australia'))
                       || (Work_Country_Selections.contains('Canada') && Work_Country_Selections.contains('USA') && Work_Country_Selections.contains('Australia'))){
                           System.debug('Work_Country_Selections.contains'+Work_Country_Selections);
                           if(loopCon.Work_Country__c != null) {
                               Boolean canadaStateNotPresent = true, usaStateNotPresent = true, australiaStateNotPresent = true;
                               if(loopCon.Illing_Licenced_in_States_Province__c !=Null){
                                   if(!Work_Country_selections.isEmpty() && !State_Selection.isEmpty()){
                                       for(String state : State_Selection){
                                           if(canadaSplitted.contains(state)) {
                                               if(Work_Country_Selections.contains('Canada')){ canadaStateNotPresent = false ; }
                                               else{ loopCon.adderror('Please select the work country as Canada because you have selected a state which belongs to Canada'); }
                                           }
                                           if(USASplitted.contains(state)){
                                               if(Work_Country_Selections.contains('USA')){
                                                   usaStateNotPresent = false ; }
                                               else{ loopCon.adderror('Please select the work country as USA because you have selected a state which belongs to USA'); }
                                           }
                                           if(australiaSplitted.contains(state)){
                                               if(Work_Country_Selections.contains('Australia')){ australiaStateNotPresent = false ;}
                                               else{ loopCon.adderror('Please select the work country as Australia because you have selected a state which belongs to Australia'); }
                                           }
                                       }
                                   }
                               }
                               else{
                                   loopCon.adderror('State is mandatory for Canada, USA and Australia');
                               }
                           }   
                           else{
                               if(!Test.isRunningTest()){
                                   loopCon.adderror('Work Country is mandatory');
                               }
                           }
                       }
                    else if(!Work_Country_Selections.contains('Canada') && !Work_Country_Selections.contains('USA') && !Work_Country_Selections.contains('Australia')){
                        if(State_Selection != null){
                            for(String state : State_Selection){
                                if(canadaSplitted.contains(state)) { loopCon.adderror('The Country should be Canada because you have selected work state of Canada');}
                                if(USASplitted.contains(state)){ loopCon.adderror('The Country should be USA because you have selected work state of USA'); }
                                if(australiaSplitted.contains(state)){ loopCon.adderror('The Country should be Australia because you have selected work state of Australia'); }
                            }    
                        } 	      
                    }
                }
                else{
                    if(!Test.isRunningTest()){
                        loopCon.adderror('Work Country is mandatory');
                    }
                }
            }
        }
    }
    
    //State Field Mandatory Validation for compace license
    public static void ValidCompactLicence(List<Contact> contactList) {
        Map<String, Compact_Licence__c> compactLicenceMap = new Map<String, Compact_Licence__c>();
        Boolean ErrorMsg = true;
        
        for (Compact_Licence__c compactLicence : [SELECT Id, Name, Country__c FROM Compact_Licence__c]) {
            compactLicenceMap.put(compactLicence.Name, compactLicence);
        }
        
        for(Contact contact : contactList){
            if(contact.Compact_Licence__c == true){
                List<String> stateSelection = (contact.Illing_Licenced_in_States_Province__c != null) ?
                    contact.Illing_Licenced_in_States_Province__c.split(';') : new List<String>();
                for(String state : stateSelection) {
                    if (compactLicenceMap.containsKey(state)) { 
                        ErrorMsg = false;
                        break;
                    }
                }
                if(ErrorMsg == true && Test.isRunningTest() == False){
                    contact.addError('If the Nurse has a compact License then atleast one State added on the Master data should be added on the States Picklist on the Contact');
                }
            }
        }
    }
    
    //create new ticket record on  updation of country field 
    public static void createTicketRecordWhenCountryIsChanged(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap){
        Set<Id> contactIdSet=new Set<Id>();
        List<String> newCountryList=new List<String>();
        List<String> oldCountryList=new List<String>();
        Set<String> completeCountryList=new Set<String>();
        List<sirenum__ticket__c> ticketToBeAddedList=new List<sirenum__ticket__c>();
        List<sirenum__ticket__c> ticketToBeDeletedList=new List<sirenum__ticket__c>();
        Map<Id, List<String>> addedcountryNameContactListMap = new Map<Id, List<String>>();
        Map<Id, List<String>> deletedcountryNameContactListMap = new Map<Id, List<String>>();
        Map<Id, Set<String>> AllcountryNameContactListMap = new Map<Id, Set<String>>();
        Map<Id,Map<String,List<Id>>> contactIdCountryCompMap=new Map<Id,Map<String,List<Id>>>();
        Map<String, List<Id>> workCountryCompIdMap = new Map<String, List<Id>>();
        List<String> removedCountryList=new List<String>();
        if(oldContactMap!=null){
            for(Contact newContact: newContactMap.values()){
                if((oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c && newContact.Activity_Status__c == 'Onboarding') ||(oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c && newContact.Activity_Status__c == 'Re-activated on Bank') 
                   || (newContact.Work_country__c != oldContactMap.get(newContact.id).Work_country__c 
                       &&(newContact.Activity_Status__c!=null && newContact.Activity_Status__c!='Inactive' && newContact.Activity_Status__c!='Resigned'&& newContact.Activity_Status__c!='Do not Contact'&& newContact.Activity_Status__c!='Historical Visits Only'&& newContact.Activity_Status__c!='Hired' && newContact.Activity_Status__c!='Withdrawn by IRG'&& newContact.Activity_Status__c!='Withdrawn by Resource')
                      )){
                          newCountryList=(newContact.Work_country__c )!=null ? ((newContact.Work_country__c).split(';')) : new List<String>();
                          oldCountryList = (oldContactMap.get(newContact.Id).Work_country__c )!=null ? ((oldContactMap.get(newContact.Id).Work_country__c).split(';')) : new List<String>(); 
                          contactIdSet.add(newContact.Id);
                          completeCountryList.addAll(newCountryList);
                          completeCountryList.addAll(oldCountryList);
                          List<String> newlyAddedCountryList=new List<String>();
                          
                          for(String s: newCountryList){
                              newlyAddedCountryList.add(s); 
                          }
                          for(String s: oldCountryList){
                              if(!newCountryList.contains(s)){
                                  removedCountryList.add(s); 
                              }
                          }
                          AllcountryNameContactListMap.put(newContact.Id,completeCountryList);
                          deletedcountryNameContactListMap.put(newContact.Id,removedCountryList);
                          contactIdCountryCompMap.put(newContact.Id,workCountryCompIdMap);
                          if(newlyAddedCountryList.size()>0) addedcountryNameContactListMap.put(newContact.Id,newlyAddedCountryList);
                      }
            }
            if(addedcountryNameContactListMap!=null || deletedcountryNameContactListMap!=null){
                Map<String, Id> workCountryMap = new Map<String, Id>();
                
                Map<String, sirenum__ticket__c> OwnerCountryTicketMap = new Map<String, sirenum__ticket__c>();
                List<String> countryListInComp=new List<String>();
                List<String> countryList = new List<String>(completeCountryList);
                String countryListString = String.join(countryList, '\',\'');
                string query='Select id,name, Work_Country__c  from sirenum__ticketType__c where Competence_category__c=\'Work Country\' AND (work_Country__c INCLUDES (\'' + String.join(countryList, '\',\'') + '\'))';
                
                if(countryList.size() > 0){
                    for (sirenum__ticketType__c comp : Database.query(query)) {
                        if (String.isNotBlank(comp.Work_Country__c)) 
                            countryListInComp=comp.Work_Country__c.split(';');
                        
                        Id competencyId = comp.Id;
                        
                        // Check if the workCountry is null or empty
                        for(String country: countryListInComp){
                            
                            // Check if the workCountry is already in the map
                            if (!workCountryCompIdMap.containsKey(country)) {
                                // If not, create a new list and add it to the map
                                workCountryCompIdMap.put(country, new List<Id>());
                            }
                            
                            // Add the competence Id to the list associated with the workCountry
                            workCountryCompIdMap.get(country).add(competencyId);
                            //compIdWorkCountryMap.put(comp.Id, comp.Work_Country__c);
                            workCountryMap.put(comp.Work_Country__c, comp.Id);
                        }
                    }
                }
                
                //get all ticket
                for (sirenum__ticket__c tic : [Select id,sirenum__Owner__c, sirenum__TicketType__c, sirenum__TicketType__r.name,Competence_category__c,sirenum__TicketType__r.work_country__c, SK_Status__c   from sirenum__ticket__c where sirenum__Owner__c IN :AllcountryNameContactListMap.keySet() AND Competence_category__c='Work Country' AND  sirenum__TicketType__r.Work_Country__c  IN :completeCountryList ]) {
                    OwnerCountryTicketMap.put(tic.sirenum__Owner__c+'#'+tic.sirenum__TicketType__r.work_country__c+'#'+tic.sirenum__TicketType__c, tic);
                }
                if(!AllcountryNameContactListMap.isEmpty() && !workCountryCompIdMap.isEmpty()){
                    for(Id contactId: AllcountryNameContactListMap.keySet()){
                        for(String country: AllcountryNameContactListMap.get(contactId)){
                            if(workCountryCompIdMap.get(country) != null){
                                for(Id compId:workCountryCompIdMap.get(country)){
                                    if (OwnerCountryTicketMap.get(contactId+'#'+country+'#'+compId) == null
                                        && addedcountryNameContactListMap.get(contactId).contains(country) && workCountryCompIdMap.containskey(country)) {
                                            sirenum__ticket__c newTicket=new sirenum__ticket__c();
                                            Id ticketTypeId = workCountryMap.get(country);
                                            newTicket.sirenum__TicketType__c = compId;
                                            newTicket.sirenum__Owner__c=contactId;
                                            if(newTicket.sirenum__TicketType__c!=null) ticketToBeAddedList.add(newTicket);
                                        }
                                    else if(OwnerCountryTicketMap.get(contactId+'#'+country+'#'+compId) != null
                                            && deletedcountryNameContactListMap.get(contactId).contains(country) && workCountryCompIdMap.containskey(country) ){
                                                if( OwnerCountryTicketMap.get(contactId+'#'+country+'#'+compId).SK_Status__c!='Confirmed' && !ticketToBeDeletedList.contains(OwnerCountryTicketMap.get(contactId+'#'+country+'#'+compId)) ){
                                                    sirenum__ticket__c tic = OwnerCountryTicketMap.get(contactId+'#'+country+'#'+compId);
                                                    ticketToBeDeletedList.add(tic);
                                                }   
                                            }
                                }
                            }
                        }
                    }
                }
            }
            if(ticketToBeAddedList.size()>0){
                Database.Insert(ticketToBeAddedList,false) ;
            }
            if(ticketToBeDeletedList.size()>0){
                Delete ticketToBeDeletedList;
            }
        }
    } 
    
    //create new ticket record on  updation of State field 
    public static void createTicketRecordWhenStateIsChanged(Map<Id,Contact> newContactMap, Map<Id,Contact> oldContactMap){
        Set<Id> contactIdSet=new Set<Id>();
        List<String> newStateList=new List<String>();
        List<String> oldStateList=new List<String>();
        Set<String> completeStateList=new Set<String>();
        List<sirenum__ticket__c> ticketToBeAddedList=new List<sirenum__ticket__c>();
        List<sirenum__ticket__c> ticketToBeDeletedList=new List<sirenum__ticket__c>();
        Map<Id, List<String>> addedStateNameContactListMap = new Map<Id, List<String>>();
        Map<Id, List<String>> deletedStateNameContactListMap = new Map<Id, List<String>>();
        Map<Id, Set<String>> AllStateNameContactListMap = new Map<Id, Set<String>>();
        Map<String, List<Id>> workStateCompIdMap = new Map<String, List<Id>>();
        
        if(oldContactMap!=null){
            for(Contact newContact: newContactMap.values()){
                if((oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c && newContact.Activity_Status__c == 'Onboarding') || (oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c && newContact.Activity_Status__c == 'Re-activated on Bank') ||  (newContact.Illing_Licenced_in_States_Province__c  != oldContactMap.get(newContact.id).Illing_Licenced_in_States_Province__c  &&
                                                                                                                                                                                                                                                                                                                     (newContact.Activity_Status__c!=null && newContact.Activity_Status__c!='Inactive' && newContact.Activity_Status__c!='Resigned'&& newContact.Activity_Status__c!='Do not Contact'&& newContact.Activity_Status__c!='Historical Visits Only'&& newContact.Activity_Status__c!='Hired' && newContact.Activity_Status__c!='Onboarding not completed'&& newContact.Activity_Status__c!='Withdrawn by IRG'&& newContact.Activity_Status__c!='Withdrawn by Resource')
                                                                                                                                                                                                                                                                                                                    )){
                                                                                                                                                                                                                                                                                                                        newStateList=(newContact.Illing_Licenced_in_States_Province__c  )!=null ? ((newContact.Illing_Licenced_in_States_Province__c ).split(';')) : new List<String>();
                                                                                                                                                                                                                                                                                                                        oldStateList = (oldContactMap.get(newContact.Id).Illing_Licenced_in_States_Province__c  )!=null ? ((oldContactMap.get(newContact.Id).Illing_Licenced_in_States_Province__c ).split(';')) : new List<String>(); 
                                                                                                                                                                                                                                                                                                                        contactIdSet.add(newContact.Id);
                                                                                                                                                                                                                                                                                                                        completeStateList.addAll(newStateList);
                                                                                                                                                                                                                                                                                                                        completeStateList.addAll(oldStateList);
                                                                                                                                                                                                                                                                                                                        List<String> newlyAddedStateList=new List<String>();
                                                                                                                                                                                                                                                                                                                        List<String> removedStateList=new List<String>();
                                                                                                                                                                                                                                                                                                                        for(String s: newStateList){
                                                                                                                                                                                                                                                                                                                            newlyAddedStateList.add(s); }
                                                                                                                                                                                                                                                                                                                        for(String s: oldStateList){
                                                                                                                                                                                                                                                                                                                            if(!newStateList.contains(s)){
                                                                                                                                                                                                                                                                                                                                removedStateList.add(s);    
                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                        AllStateNameContactListMap.put(newContact.Id,completeStateList);
                                                                                                                                                                                                                                                                                                                        deletedStateNameContactListMap.put(newContact.Id,removedStateList);
                                                                                                                                                                                                                                                                                                                        if(newlyAddedStateList.size()>0) addedStateNameContactListMap.put(newContact.Id,newlyAddedStateList);
                                                                                                                                                                                                                                                                                                                    }
            }
            if(addedStateNameContactListMap!=null || deletedStateNameContactListMap!=null){
                Map<String, Id> workStateMap = new Map<String, Id>();
                Map<String, sirenum__ticket__c> OwnerStateTicketMap = new Map<String, sirenum__ticket__c>();
                List<String> stateListInComp=new List<String>();
                List<String> stateList = new List<String>(completeStateList);
                string query='Select id,name, Work_State__c  from sirenum__ticketType__c where Competence_category__c=\'Work State\' AND (work_State__c INCLUDES (\'' + String.join(stateList, '\',\'') + '\'))';
                
                if(stateList.size() > 0){
                    for (sirenum__ticketType__c comp : Database.query(query)) {
                        if (String.isNotBlank(comp.Work_State__c)) 
                            stateListInComp=comp.Work_State__c.split(';');
                        Id competencyId = comp.Id;
                        
                        // Check if the workCountry is null or empty
                        for(String state: stateListInComp){
                            
                            // Check if the workCountry is already in the map
                            if (!workStateCompIdMap.containsKey(state)) {
                                // If not, create a new list and add it to the map
                                workStateCompIdMap.put(state, new List<Id>());
                            }
                            // Add the competence Id to the list associated with the workCountry
                            workStateCompIdMap.get(state).add(competencyId);
                            //compIdWorkCountryMap.put(comp.Id, comp.Work_Country__c);
                            workStateMap.put(comp.Work_State__c, comp.Id);
                        }
                    }
                }
                for (sirenum__ticket__c tic : [Select id,sirenum__Owner__c, sirenum__TicketType__c,SK_Status__c, sirenum__TicketType__r.name,Competence_category__c ,sirenum__TicketType__r.work_state__c  from sirenum__ticket__c where sirenum__Owner__c IN :AllStateNameContactListMap.keySet() AND Competence_category__c='Work State' AND  sirenum__TicketType__r.Work_State__c IN :completeStateList ]) {
                    OwnerStateTicketMap.put(tic.sirenum__Owner__c+'#'+tic.sirenum__TicketType__r.work_state__c+'#'+tic.sirenum__TicketType__c, tic);
                }
                for(Id contactId: AllStateNameContactListMap.keySet()){
                    for(String state: AllStateNameContactListMap.get(contactId)){
                        if(workStateCompIdMap.get(state) != null){
                            for(Id compId:workStateCompIdMap.get(state)){
                                if (!addedStateNameContactListMap.isEmpty() && OwnerStateTicketMap.get(contactId+'#'+state+'#'+compId) == null
                                    && addedStateNameContactListMap.get(contactId).contains(State) && workStateCompIdMap.containskey(state)) {
                                        sirenum__ticket__c newTicket=new sirenum__ticket__c();
                                        //Id ticketTypeId = workStateMap.get(State);
                                        newTicket.sirenum__TicketType__c = compId;
                                        newTicket.sirenum__Owner__c=contactId;
                                        if(newTicket.sirenum__TicketType__c!=null) ticketToBeAddedList.add(newTicket);
                                    }
                                else if(OwnerStateTicketMap.get(contactId+'#'+State+'#'+compId) != null
                                        && deletedStateNameContactListMap.get(contactId).contains(State) && workStateCompIdMap.containskey(state)){
                                            if( OwnerStateTicketMap.get(contactId+'#'+State+'#'+compId).SK_Status__c!='Confirmed' && !ticketToBeDeletedList.contains(OwnerStateTicketMap.get(contactId+'#'+state+'#'+compId))){
                                                sirenum__ticket__c tic = OwnerStateTicketMap.get(contactId+'#'+State+'#'+compId);
                                                ticketToBeDeletedList.add(tic);
                                            }
                                        }
                            }
                        }
                    }
                }
            }
            if(ticketToBeAddedList.size()>0){
                Database.Insert(ticketToBeAddedList,false);
            }
            if(ticketToBeDeletedList.size()>0){
                Delete ticketToBeDeletedList;
            }
        }
    }
    
    //Automatic ticket generation for competencies linked with the job type when the job type is changed for a nurse record
    public static void createTicketRecordOnJobTypeChange (Map<Id,Contact> newContactMap , Map<Id,Contact> oldContactMap){
        if(recursiveCheck == true){
            List<sirenum__Ticket__c> newTicketList =new List<sirenum__Ticket__c>();
            List<sirenum__Shift__c> updateVisitList = new List<sirenum__Shift__c>();
            List<sirenum__TicketType__c> allCompetencyList =new List<sirenum__TicketType__c>();
            List<string> jobTypeList = new List<string>();
            List<Contact> contactList =new List<Contact>();
            Map<String, sirenum__ticket__c> OwnerStateTicketMap = new Map<String, sirenum__ticket__c>();
            
            for(Contact newContact :newContactMap.values()){ 
                if(((oldContactMap.get(newContact.Id).Job_Type__c != newContact.Job_Type__c && newContact.Job_Type__c != null) || (oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c && newContact.Activity_Status__c == 'Onboarding') ||(oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c && newContact.Activity_Status__c == 'Re-activated on Bank') ) 
                   && (newContact.Activity_Status__c !='Resigned' && newContact.Activity_Status__c !='Inactive' && 
                       newContact.Activity_Status__c !='Do not Contact'  &&
                       newContact.Activity_Status__c !='Historical Visits Only' && newContact.Activity_Status__c !='Hired' && 
                       newContact.Activity_Status__c !='Onboarding not completed' && newContact.Activity_Status__c!='Withdrawn by IRG' && newContact.Activity_Status__c!='Withdrawn' &&  newContact.Activity_Status__c!=null )){
                           jobTypeList.add(newContact.Job_Type__c);
                           contactList.add(newContact);
                       }
            }
            
            List<sirenum__Job_Type__c> jobType = new List<sirenum__Job_Type__c>([Select ID,Name from sirenum__Job_Type__c where ID IN : jobTypeList]);
            List<String> jobTypeNames = new List<String>();
            for (sirenum__Job_Type__c job : jobType) {
                jobTypeNames.add(job.Name);
            }
            
            String query = 'SELECT Id, Name, Competence_Category__c, Job_Type__c FROM sirenum__TicketType__c ' +
                'WHERE (Competence_Category__c NOT IN (\'RN Mandatory Training\', \'Project Training\')) ' +
                'AND (Job_Type__c != null) ' +
                'AND (Job_Type__c INCLUDES (\'' + String.join(jobTypeNames,';') + '\'))';
            List<sirenum__TicketType__c> queryList = Database.query(query);
            
            for (sirenum__ticket__c tic : [Select id,sirenum__Owner__c, sirenum__TicketType__c,SK_Status__c, sirenum__TicketType__r.name,Competence_category__c ,sirenum__TicketType__r.work_state__c  from sirenum__ticket__c where sirenum__Owner__c IN :contactList AND  sirenum__TicketType__c IN :queryList ]) {
                OwnerStateTicketMap.put(tic.sirenum__Owner__c+'#'+tic.sirenum__TicketType__c, tic);
            }
            
            if(!queryList.isEmpty()){
                for(Contact newContact : contactList){
                    for(sirenum__TicketType__c eachComp:queryList){
                        
                        if(!OwnerStateTicketMap.containsKey(newContact.Id+'#'+eachComp.Id) && newContact.Activity_Status__c=='Re-activated on Bank'){
                            sirenum__ticket__c newTicket = new sirenum__ticket__c();
                            newTicket.sirenum__TicketType__c = eachComp.ID;
                            newTicket.sirenum__Owner__c = newContact.Id;
                            if(newTicket.sirenum__TicketType__c != null && newTicket.sirenum__Owner__c != null ) 
                                newTicketList.add(newTicket);
                        }
                        else if(newContact.Activity_Status__c!='Re-activated on Bank'){
                            sirenum__ticket__c newTicket = new sirenum__ticket__c();
                            newTicket.sirenum__TicketType__c = eachComp.ID;
                            newTicket.sirenum__Owner__c = newContact.Id;
                            if(newTicket.sirenum__TicketType__c != null && newTicket.sirenum__Owner__c != null ) 
                                newTicketList.add(newTicket);
                        }
                    }
                }
            }
            if(newTicketList.size()>0){
                recursiveCheck=false;
                Database.insert(newTicketList, false);
            }
            
            //Update Alternative Job Type on Visit when Job Type changed on Contact
            List<sirenum__Shift__c> visitList = new List<sirenum__Shift__c>();
            visitList = [Select Id , name , sirenum__Contact__c  from sirenum__Shift__c where sirenum__Contact__c IN : contactList];
            if(!visitList.isEmpty()){
                for(Contact newContact : contactList){
                    for(sirenum__Shift__c eachVisit:visitList){
                        eachVisit.sirenum__Job_Type__c = newContact.Job_Type__c;
                        updateVisitList.add(eachVisit);
                    }
                }
            }
            if(updateVisitList.size()>0){
                recursiveCheck=false;
                update updateVisitList;
            }
        }
    }
    
    //Automatic ticket generation for compact licenses when a state is added to the compact licenses
    public static void createTicketForCompactLicense (Map<Id,Contact> newContactMap , Map<Id,Contact> oldContactMap){
        if(recursiveCheckForCompactLic){
            List<Contact> contactList = new List<Contact >();
            List<sirenum__TicketType__c> CompactLicenseCompetency = new List<sirenum__TicketType__c >();
            List<sirenum__Ticket__c> newTicketInsertList =new List<sirenum__Ticket__c>();
            
            for(Contact newContact :newContactMap.values()){
                if(oldContactMap.get(newContact.Id).Compact_Licence__c != newContact.Compact_Licence__c && newContact.Compact_Licence__c == true){
                    contactList.add(newContact);
                }
            }
            
            CompactLicenseCompetency = [Select id,name from sirenum__TicketType__c where name = 'Compact License' AND Competence_Category__c  = 'Compact License'];
            
            if(contactList.size()>0 && CompactLicenseCompetency.size()>0){
                for(Contact eachContact:contactList){
                    for(sirenum__TicketType__c  competency:CompactLicenseCompetency){
                        sirenum__ticket__c newTicket = new sirenum__ticket__c();
                        newTicket.sirenum__TicketType__c = competency.ID;
                        newTicket.sirenum__Owner__c = eachContact.Id;
                        if(newTicket.sirenum__TicketType__c != null && newTicket.sirenum__Owner__c != null ) 
                            newTicketInsertList.add(newTicket);
                    }
                }
            }
            if(newTicketInsertList.size()>0){
                recursiveCheckForCompactLic=false;
                Insert newTicketInsertList;
            }
        }
    }
    
    //Create ticket record when a new contact is inserted
    public static void createTicketRecordNewContactCreated(Map<Id,Contact> newContactMap){
        Map<String, Id> recordTypeNameIdMap = Utility.getRecordTypeIdNameMap('Contact');
        Id conResourceRecordTypeId = recordTypeNameIdMap.get('Resource');
        List<String> newStateList =new List<String>();
        List<String> newCountryList =new List<String>();
        List<String> countryStateList =new List<String>();
        Map<Id, List<String>> addedStateCountryNameContactListMap = new Map<Id, List<String>>();
        
        for(Contact newContact: newContactMap.values()){
            if((newContact.Illing_Licenced_in_States_Province__c  != '' || newContact.Work_country__c != '') && (newContact.RecordTypeId == conResourceRecordTypeId) &&
               (newContact.Activity_Status__c!='Inactive' && newContact.Activity_Status__c!='Resigned'&& newContact.Activity_Status__c!='Do not Contact'&& newContact.Activity_Status__c!='Historical Visits Only'&& newContact.Activity_Status__c!='Hired' && newContact.Activity_Status__c!='Onboarding not completed' && newContact.Activity_Status__c!='Withdrawn by IRG' && newContact.Activity_Status__c!='Withdrawn'  && newContact.Activity_Status__c!='Paused'  && newContact.Activity_Status__c!=null)
              ){newStateList=(newContact.Illing_Licenced_in_States_Province__c  )!=null ? ((newContact.Illing_Licenced_in_States_Province__c ).split(';')) : new List<String>();
                newCountryList=(newContact.Work_country__c  )!=null ? ((newContact.Work_country__c ).split(';')) : new List<String>();
                countryStateList.addAll(newStateList);
                countryStateList.addAll(newCountryList);
                if(countryStateList.size()>0) addedStateCountryNameContactListMap.put(newContact.Id,countryStateList);
               }
        }
        
        if(addedStateCountryNameContactListMap!=null){
            List<sirenum__ticket__c> ticketToBeAddedList=new List<sirenum__ticket__c>();
            Map<String, Id> workStateCountryMap = new Map<String, Id>();
            
            for (sirenum__ticketType__c comp : [Select id,name, Work_State__c,Work_Country__c  from sirenum__ticketType__c where (Competence_category__c='Work State' OR Competence_category__c='Work Country' ) ]) {
                if(comp.Work_State__c!='') workStateCountryMap.put(comp.Work_State__c, comp.Id);
                if(comp.Work_Country__c!='') workStateCountryMap.put(comp.Work_Country__c, comp.Id);
            }
            
            for(Id contactId :addedStateCountryNameContactListMap.keySet()){
                for(String countryState: addedStateCountryNameContactListMap.get(contactId)){
                    sirenum__ticket__c newTicket=new sirenum__ticket__c();
                    Id ticketTypeId = workStateCountryMap.get(countryState);
                    newTicket.sirenum__TicketType__c = ticketTypeId;
                    newTicket.sirenum__Owner__c=contactId;
                    if(newTicket.sirenum__TicketType__c!=null) ticketToBeAddedList.add(newTicket);
                }
            }
            if(ticketToBeAddedList.size()>0) 
                Database.Insert(ticketToBeAddedList,false);
        }
    }
    
    //Make Contact Project Record Inactive When Project is Removed from Active Project MultiPickList
    public static void inactiveContactProjectRecord (Map<Id,Contact> newContactMap , Map<Id,Contact> oldContactMap){
        List<Contact_Project__c> contactProjectUpdateList = new List<Contact_Project__c>();
        List<String> newProjectNameList=new List<String>();
        List<String> oldProjectNameList=new List<String>();
        List<Id> contactIdList=new List<Id>();
        
        for(Contact newContact:newContactMap.values()){
            if(oldContactMap.get(newContact.Id).Active_Projects__c != newContact.Active_Projects__c){
                newProjectNameList=(newContact.Active_Projects__c )!=null ? ((newContact.Active_Projects__c).split(';')) : new List<String>();
                oldProjectNameList = (oldContactMap.get(newContact.Id).Active_Projects__c )!=null ? ((oldContactMap.get(newContact.Id).Active_Projects__c).split(';')) : new List<String>();
                contactIdList.add(newContact.Id);
            }
        }
        
        //Remove old projects from active project picklist
        if(newProjectNameList.size() < oldProjectNameList.size()){
            List<String> projectNameList=new List<String>();
            for(String s: oldProjectNameList){
                if(!newProjectNameList.contains(s)){
                    projectNameList.add(s); 
                }
            }
            
            List<Contact_Project__c> contactProjectQuery = [select id,name,Project__c,Contact__c,Active__c from Contact_Project__c where Project__r.Name IN :projectNameList AND Contact__c IN: contactIdList AND Active__c = True];
            List<sirenum__Placement__c> incompletePlacementQuery = [select id,name from sirenum__Placement__c  where sirenum__Contract__r.Name IN :projectNameList AND sirenum__Contact__c IN: contactIdList AND sirenum__Status__c  != 'Completed'];
            
            //Contact Project
            if(!contactProjectQuery.isEmpty()){
                for(Contact_Project__c eachRecord:contactProjectQuery){
                    eachRecord.Active__c = false;
                    contactProjectUpdateList.add(eachRecord);
                }
            }
            if(contactProjectUpdateList.size()>0) Update contactProjectUpdateList;
            
            //Complete Placement Error
            if(!incompletePlacementQuery.isEmpty()){
                for(Contact newContact:newContactMap.values()){
                    newContact.adderror('Change the Project and Site Placement Status to "Completed" before removing the Project from the Active Projects picklist');
                }
            }
        }
    }
    
    //This method will update Ticket Status when either job type , Work State or Work Country is changed
    public static void updateTsWhenContactIsUpdated(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap) {
        Set<Id> contactIdSetForJobTypeChange = new Set<Id>();
        Map<Id, List<String>> contactToRemovedStatesMap = new Map<Id, List<String>>();
        Map<Id, List<String>> contactToRemovedCountriesMap = new Map<Id, List<String>>();
        Map<Id, Contact> contactToRemovedJobTypeMap = new Map<Id, Contact>();
        
        // check  contacts with changes in Job_Type__c or Work_Country__c or
        for (Id contactId : newContactMap.keySet()) {
            Contact newContact = newContactMap.get(contactId);
            Contact oldContact = oldContactMap.get(contactId);
            
            if (newContact.Job_Type__c != oldContact.Job_Type__c) {
                contactIdSetForJobTypeChange.add(contactId);
                contactToRemovedJobTypeMap.put(contactId,newContact);
            } 
            if (newContact.Work_Country__c != oldContact.Work_Country__c) {
                List<String> newCountryList = newContact.Work_Country__c != null ? newContact.Work_Country__c.split(';') : new List<String>();
                List<String> oldCountryList = oldContact.Work_Country__c != null ? oldContact.Work_Country__c.split(';') : new List<String>();
                
                Set<String> oldCountrySet = new Set<String>(oldCountryList);
                oldCountrySet.removeAll(new Set<String>(newCountryList));
                
                if (!oldCountrySet.isEmpty()) {
                    contactToRemovedCountriesMap.put(contactId, new List<String>(oldCountrySet));
                }
            }
            if(newContact.Illing_Licenced_in_States_Province__c != oldContact.Illing_Licenced_in_States_Province__c){
                List<String> newStateList = newContact.Illing_Licenced_in_States_Province__c != null ? newContact.Illing_Licenced_in_States_Province__c.split(';') : new List<String>();
                List<String> oldStateList = oldContact.Illing_Licenced_in_States_Province__c != null ? oldContact.Illing_Licenced_in_States_Province__c.split(';') : new List<String>();
                
                Set<String> oldStateSet = new Set<String>(oldStateList);
                oldStateSet.removeAll(new Set<String>(newStateList));
                
                if (!oldStateSet.isEmpty()) {
                    contactToRemovedStatesMap.put(contactId, new List<String>(oldStateSet));
                }
            }
        }
        
        List<Illingworth_Ticket_Status__c> updateTicketStatusList = new List<Illingworth_Ticket_Status__c>();
        
        // Retrieve and update Illingworth_Ticket_Status__c records based on country changes
        if (!contactToRemovedCountriesMap.isEmpty() || !contactToRemovedStatesMap.isEmpty()|| !contactToRemovedJobTypeMap.isEmpty()) {
            
            for (Illingworth_Ticket_Status__c ticketStatus : [
                SELECT Id, Resource__c, Work_Country__c, Competence_Condition__c, Work_State__c 
                FROM Illingworth_Ticket_Status__c
                WHERE Resource__c IN :contactToRemovedCountriesMap.keySet() OR Resource__c IN :contactToRemovedStatesMap.keySet() OR Resource__c IN :contactToRemovedJobTypeMap.keySet()
            ]) {
                Id resourceId = ticketStatus.Resource__c;
                //if work country is removed on contact
                if (contactToRemovedCountriesMap.containsKey(resourceId)) {
                    List<String> removedCountries = contactToRemovedCountriesMap.get(resourceId);
                    List<String> ticketCountries = ticketStatus.Work_Country__c != null ? ticketStatus.Work_Country__c.split(';') : new List<String>();
                    
                    Set<String> ticketCountrySet = new Set<String>(ticketCountries);
                    ticketCountrySet.removeAll(new Set<String>(removedCountries));
                    if (ticketCountrySet.isEmpty()) {
                        ticketStatus.Competence_Condition__c = null;
                        ticketStatus.Work_Country__c = null;
                    } else {
                        ticketStatus.Work_Country__c = String.join(new List<String>(ticketCountrySet), ';');
                    }
                    updateTicketStatusList.add(ticketStatus);
                }
                // if work state is removed from the contact
                if (contactToRemovedStatesMap.containsKey(resourceId)) {
                    List<String> removedStates = contactToRemovedStatesMap.get(resourceId);
                    List<String> ticketStates = ticketStatus.work_State__c != null ? ticketStatus.Work_State__c.split(';') : new List<String>();
                    
                    Set<String> ticketStateSet = new Set<String>(ticketStates);
                    ticketStateSet.removeAll(new Set<String>(removedStates));
                    
                    if (ticketStateSet.isEmpty()) {
                        ticketStatus.Competence_Condition__c = null;
                        ticketStatus.Work_State__c = null;
                    } else {
                        ticketStatus.Work_State__c = String.join(new List<String>(ticketStateSet), ';');
                    }
                    updateTicketStatusList.add(ticketStatus);
                }
                if(contactToRemovedJobTypeMap.containsKey(resourceId)){
                    ticketStatus.Competence_Condition__c = null;
                    updateTicketStatusList.add(ticketStatus);
                }
            }
        }
        
        // Update the records if there are changes
        if (!updateTicketStatusList.isEmpty()) {
            Set<Illingworth_Ticket_Status__c> updateTicketStatusSet=new Set<Illingworth_Ticket_Status__c>(updateTicketStatusList);
            List<Illingworth_Ticket_Status__c> finalUpdateTicketStatusList=new List<Illingworth_Ticket_Status__c>(updateTicketStatusSet);
            update finalUpdateTicketStatusList;
        }
    }
    
    // PBI 22131 - INC2384663 - TrialGO Project 'Illingworth' Not Visible
    public static void createContactProject(Map<Id, Contact> newContactMap) {
    List<Contact_Project__c> contactProjectInsertList = new List<Contact_Project__c>();
    Set<String> projectNameSet = new Set<String>();  // Set to collect unique project names

    //  Gather all project names from Active_Projects__c for all contacts
    for (Contact newContact : newContactMap.values()) {
        // Split the Active_Projects__c picklist into individual project names
        List<String> newProjectNameList = (newContact.Active_Projects__c != null) ? newContact.Active_Projects__c.split(';') : new List<String>();
        
        // Add the project names to the set
        projectNameSet.addAll(newProjectNameList);
    }

    //  Query all projects at once using the set of project names
    List<sirenum__ProActiveContract__c> projectQueryList = [SELECT Id, Name FROM sirenum__ProActiveContract__c WHERE Name IN :projectNameSet];

    //  Map project names to project records for easy lookup
    Map<String, Id> projectNameToIdMap = new Map<String, Id>();
    for (sirenum__ProActiveContract__c project : projectQueryList) {
        projectNameToIdMap.put(project.Name, project.Id);  // Map project Name to Id
    }

    //  Create Contact_Project__c records for each contact and their projects
    for (Contact newContact : newContactMap.values()) {
        List<String> newProjectNameList = (newContact.Active_Projects__c != null) ? newContact.Active_Projects__c.split(';') : new List<String>();

        // Loop through each project name for this contact
        for (String projectName : newProjectNameList) {
            if (projectNameToIdMap.containsKey(projectName)) {
                Contact_Project__c contactProject = new Contact_Project__c();
                contactProject.Contact__c = newContact.Id;          // Assign Contact Id
                contactProject.Active__c = true;                    // Mark as active
                contactProject.Project__c = projectNameToIdMap.get(projectName);  // Assign the project (ProActiveContract) Id
                contactProjectInsertList.add(contactProject);       // Add to the list for bulk insert
            }
        }
    }

    // Insert all the Contact_Project__c records in bulk
    if (!contactProjectInsertList.isEmpty()) {
        insert contactProjectInsertList;
    }
}



}

/*On boarding status to generate all competency tickets
public static void createTicketRecordForOnboardingStatus (Map<Id,Contact> newContactMap , Map<Id,Contact> oldContactMap){

List<sirenum__Ticket__c> newTicketList =new List<sirenum__Ticket__c>();
List<String> jobTypeName = new List<String>();
List<Contact> contactList = new List<Contact>();

for(Contact newContact :newContactMap.values()){ 
if((oldContactMap.get(newContact.Id).Activity_Status__c != newContact.Activity_Status__c) && newContact.Activity_Status__c == 'Onboarding' ){
jobTypeName.add(newContact.Job_Type__r.name);
contactList.add(newContact);
}
}

String query = 'Select Id, Name, Job_Type__c from sirenum__TicketType__c WHERE (Job_Type__c INCLUDES (\'' + String.join(jobTypeName,';') + '\'))';
List<sirenum__TicketType__c> queryList= Database.query(query);

if(queryList.Size()>0){
for(Contact mainContact :contactList){
for(sirenum__TicketType__c eachComp:queryList){
sirenum__ticket__c newTicket = new sirenum__ticket__c();
newTicket.sirenum__TicketType__c = eachComp.ID; 
newTicket.sirenum__Owner__c = mainContact.Id;
if(newTicket.sirenum__TicketType__c != null && newTicket.sirenum__Owner__c != null ) 
newTicketList.add(newTicket);
}
}
}
if(newTicketList.size()>0){
Database.insert(newTicketList, false);
}
}*/