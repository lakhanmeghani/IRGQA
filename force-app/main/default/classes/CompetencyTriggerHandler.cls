//Trigger Handler for CompetencyTrigger
public class CompetencyTriggerHandler {
    
    //Set the Competency Course title as Competency Name while Creation
    public static void setCompetencyCourseTitle (List<sirenum__TicketType__c> competencyList){
        for(sirenum__TicketType__c cmptList:competencyList){
            if((cmptList.Competence_Category__c=='RN Mandatory Training'||
                cmptList.Competence_Category__c=='Project Training'|| cmptList.Competence_Category__c=='Project Site Training') && cmptList.LMS_Course_Title__c == Null){
                    cmptList.LMS_Course_Title__c=cmptList.Name;
                }
            if((cmptList.Competence_Category__c=='RN Mandatory Training'||
                cmptList.Competence_Category__c=='Project Training')){
                    cmptList.sirenum__Expires__c = true;
                } 
        }
    }
    
    //Validation for Expire
    public static void checkExpires (List<sirenum__TicketType__c> competencyList){
        for(sirenum__TicketType__c cmptList:competencyList){
            if((cmptList.Competence_Category__c=='RN Mandatory Training'||
                cmptList.Competence_Category__c=='Project Training') && cmptList.sirenum__Expires__c == false){
                    cmptList.adderror('Expire cannot be unchecked for RN Mandatory Training and Project Training Category' );  
                } 
        }
    }
    
    //create new ticket when a new work country or work state competancy is created
    public static void createTicketOnNewCompetancyCreation(Map<Id,sirenum__TicketType__c> newCompetencyMap){
        Map<String,Id> stateCountryCompMap= new Map<String,Id>();
        List<String> workCountry= new List<String>();
        List<String> workState= new List<String>();
        List<String> splittedWorkCountry= new List<String>();
        List<String> splittedWorkState= new List<String>();
        String category='';
        String query='';
        for(sirenum__TicketType__c comp : newCompetencyMap.values()){
            if(comp.Competence_Category__c== 'Work State' || comp.Competence_Category__c=='Work Country'){
                
                if(comp.Work_State__c!=null){
                    workState.add(comp.Work_State__c);
                    splittedWorkState.addAll(comp.Work_State__c.split(';'));
                    for (String state : splittedWorkState){
                        stateCountryCompMap.put(state,comp.Id);
                    }
                    category=comp.Competence_Category__c;
                } 
                if(comp.Work_Country__c!=null){
                    workCountry.add(comp.Work_Country__c);
                    splittedWorkCountry.addAll(comp.Work_Country__c.split(';'));
                    for (String country : splittedWorkCountry){
                        stateCountryCompMap.put(country,comp.Id);
                    }
                    category=comp.Competence_Category__c;
                }
            }
        }
        
        if(stateCountryCompMap!=null && !stateCountryCompMap.isEmpty()){
            Map<Id,List<String>> contactMap=new Map<Id,List<String>>();
            List<String> contactCountryList= new List<String>();
            List<String> contactStateList= new List<String>();
            
            List<sirenum__ticket__c> ticketToBeAddedList = new List<Sirenum__Ticket__c>();
            List<String> statusList=new List<String>{'Hired', 'Inactive','Resigned','Historical Visits Only','Re-activated on Bank','Do not Contact','Withdrawn','Withdrawn by IRG','Onboarding not completed' };
                if(category=='Work State'){
                    query='SELECT Id, Name, Illing_Licenced_in_States_Province__c, Work_Country__c FROM Contact WHERE RecordType.Name=\'Resource\' AND (Illing_Licenced_in_States_Province__c INCLUDES (\'' + String.join(splittedWorkState, '\',\'') + '\')) AND  (Activity_Status__c  NOT IN (\'' + String.join(statusList, '\',\'') + '\')) AND  (Activity_Status__c != null)';
                }
            else if(category=='Work Country'){
                query='SELECT Id, Name, Illing_Licenced_in_States_Province__c, Work_Country__c FROM Contact WHERE RecordType.Name=\'Resource\' AND (Work_Country__c INCLUDES (\'' + String.join(splittedWorkCountry, '\',\'') + '\')) AND  (Activity_Status__c  NOT IN (\'' + String.join(statusList, '\',\'') + '\')) AND  (Activity_Status__c != null)';                     
            }
            
            List<Contact> queryList= Database.query(query);
            for(Contact contact : queryList){
                List<String> contactStateCountryList=new List<String>();
                if(contact.Work_Country__c!=null){
                    contactStateCountryList.addAll(contact.Work_Country__c.split(';'));   
                }
                if(contact.Illing_Licenced_in_States_Province__c!=null){
                    contactStateCountryList.addAll(contact.Illing_Licenced_in_States_Province__c.split(';'));    
                }
                contactMap.put(contact.Id,contactStateCountryList );   
            }
            
            if(contactMap!=null){
                for(Id contactId : contactMap.keySet()){
                    for(String countryState : (contactMap.get(contactId))){
                        if((splittedWorkCountry.contains(countryState) || splittedWorkState.contains(countryState)) ){
                            sirenum__ticket__c newTicket=new sirenum__ticket__c();
                            newTicket.sirenum__TicketType__c = stateCountryCompMap.get(countryState);
                            newTicket.sirenum__Owner__c=contactId;
                            ticketToBeAddedList.add(newTicket);
                        }
                    }
                }
                
                Set<String> uniqueCombos = new Set<String>();
                List<sirenum__ticket__c> uniqueTicketList = new List<sirenum__ticket__c>();
                if(ticketToBeAddedList.size()>0){
                    for (sirenum__Ticket__c ticket : ticketToBeAddedList) {
                        String combo = ticket.sirenum__TicketType__c + '_' + ticket.sirenum__Owner__c;
                        if (!uniqueCombos.contains(combo)) {
                            uniqueCombos.add(combo);
                            uniqueTicketList.add(ticket);
                        }
                    }
                    Insert uniqueTicketList;
                } 
            }
        }
    }
    
    //State Field Mandatory Validation   
    public static void  workCountryMandatory (List<sirenum__TicketType__c> competencyList){
        
        List<String> Work_Country_selections = new List<String> ();
        List<String> State_Selection = new List<String> ();
        
        String customLableCanada = Label.Canada_States;
        List<string> canadaSplitted = Label.Canada_States.split(',');
        
        String customLableAustralia = Label.Australia_States;
        List<string> australiaSplitted = Label.Australia_States.split(',');
        
        String customLableUSA = Label.USA_States ;
        List<string> USASplitted = Label.USA_States.split(',');
        
        for(sirenum__TicketType__c loopComp : competencyList){
            if(loopComp.Competence_Category__c == 'Work State'){
                if (loopComp.Work_State__c != null) {
                    if (loopComp.Work_Country__c != null){
                        Work_Country_selections = (Work_Country_selections != null) ? loopComp.Work_Country__c.split(';') : null;
                        State_Selection = (loopComp.Work_State__c != null) ? loopComp.Work_State__c.split(';') : null;
                        Boolean canadaStateNotPresent = true, usaStateNotPresent = true, australiaStateNotPresent = true;
                        if(!Work_Country_selections.isEmpty() && !State_Selection.isEmpty()){
                            for(String state : State_Selection){
                                if(Work_Country_selections.contains('Canada') && canadaSplitted.contains(state)) canadaStateNotPresent = false;	    
                                if(Work_Country_selections.contains('USA') && USASplitted.contains(state)) usaStateNotPresent = false;	   
                                if(Work_Country_selections.contains('Australia') && australiaSplitted.contains(state)) australiaStateNotPresent = false;	
                            }
                            if(canadaStateNotPresent == true && Work_Country_selections.contains('Canada')) loopComp.adderror('The state should be of Canada because you have selected work country as Canada');
                            if(usaStateNotPresent == true && Work_Country_selections.contains('USA')) loopComp.adderror('The state should be of USA because you have selected work country as USA');
                            if(australiaStateNotPresent == true && Work_Country_selections.contains('Australia')) loopComp.adderror('The state should be of Australia because you have selected work country as Australia');
                        }
                    }
                }
                else{
                    loopComp.adderror('For Work State Competency category, the field Work State is Mandatory.');
                }
            }
        }
    }
    
    //State Field Mandatory Validation
    public static void  stateMandatory (List<sirenum__TicketType__c> competencyList){
        
        List<String> Work_Country_selections = new List<String> ();
        List<String> State_Selection = new List<String> ();
        List<string> canadaSplitted = Label.Canada_States.split(',');
        List<string> australiaSplitted = Label.Australia_States.split(',');
        List<string> USASplitted = Label.USA_States.split(',');
        
        for(sirenum__TicketType__c loopComp : competencyList){
            if(loopComp.Competence_Category__c == 'Work State' || (loopComp.Competence_Category__c == 'RN Mandatory Training' && loopComp.Work_State__c  != null) ){
                if (loopComp.Work_State__c != null) {
                    if (loopComp.Work_Country__c != null){
                        Work_Country_selections = (Work_Country_selections != null) ? loopComp.Work_Country__c.split(';') : null;
                        State_Selection = (loopComp.Work_State__c  != null) ? loopComp.Work_State__c.split(';') : null;
                        Boolean canadaStateNotPresent = true, usaStateNotPresent = true, australiaStateNotPresent = true;
                        if(!Work_Country_selections.isEmpty() && !State_Selection.isEmpty()){
                            for(String state : State_Selection){
                                if(canadaSplitted.contains(state)){
                                    if (Work_Country_Selections.contains('Canada')){
                                        canadaStateNotPresent = false ;
                                    }
                                    else{
                                        loopComp.adderror('The Country should be as Canada because you have selected work state of Canada');
                                    }
                                }
                                if(USASplitted.contains(state)){
                                    if (Work_Country_Selections.contains('USA')){
                                        usaStateNotPresent = false ;
                                    }
                                    else{
                                        loopComp.adderror('The Country should be as USA because you have selected work state of USA');
                                    }
                                }
                                if(australiaSplitted.contains(state)){
                                    if (Work_Country_Selections.contains('Australia')){
                                        australiaStateNotPresent = false ;
                                    }
                                    else{
                                        loopComp.adderror('The Country should be as Australia because you have selected work state of Australia');
                                    }
                                }
                            }
                        }
                    }
                    else{
                        loopComp.adderror('Work Country is mandatory');
                    }
                    
                }
                else{
                    loopComp.adderror('Work State is mandatory');
                }
            }
        }
    }
    
    //Create Ticket for Resource when Job Type is Added on Comptency
    public static void createTicketforJobType (Map<Id,sirenum__TicketType__c> newCompMap , Map<Id,sirenum__TicketType__c> oldCompMap){
        
        List<sirenum__Ticket__c> newTicketList=new List<sirenum__Ticket__c>();
        List<String> newJobTypeNameList = new List<String>();
        List<String> oldJobTypeNameList = new List<String>();
        List <String> jobTypeNameList =new List<String>();
        List<sirenum__TicketType__c> filteredList = new List<sirenum__TicketType__c>();
        List<String> splittedJobType = new List<String>();
        
        for(sirenum__TicketType__c newComp :newCompMap.values()){
            
            //For Insert
            if(newComp.Competence_Category__c != 'RN Mandatory Training' && newComp.Competence_Category__c != 'Project Training' && newComp.Job_Type__c != null){
                newJobTypeNameList.add(newComp.Job_Type__c);
                splittedJobType = (newComp.Job_Type__c.split(';'));
            } 
            
            // Checking condition for competency condition record creation...(Updated)
            if(newComp.Job_Type__c != NULL && newComp.Generate_Competency_Condition__c == true && (oldCompMap == NULL  ||
                                                                                                   (newComp.Generate_Competency_Condition__c != oldCompMap.get(newComp.Id).Generate_Competency_Condition__c))
               && (newComp.Competence_Category__c == 'RN Mandatory Training' || newComp.Competence_Category__c == 'Compliance Documentation')){
                   filteredList.add(newComp);
               }
        }
        
        List<Contact> ContactList= [Select id,name,Activity_Status__c,Job_Type__r.name from Contact where (Job_Type__r.name IN :splittedJobType) and (Activity_Status__c !='Resigned' AND 
                                                                                                                                                      Activity_Status__c !='Inactive' AND 
                                                                                                                                                      Activity_Status__c !='Do not Contact' AND 
                                                                                                                                                      Activity_Status__c !='Re-activated on Bank' AND 
                                                                                                                                                      Activity_Status__c !='Historical Visits Only' AND 
                                                                                                                                                      Activity_Status__c !='Hired' AND
                                                                                                                                                      Activity_Status__c !='Onboarding not completed' AND 
                                                                                                                                                      Activity_Status__c !='Withdrawn by IRG' AND 
                                                                                                                                                      Activity_Status__c !='Withdrawn' AND 
                                                                                                                                                      Activity_Status__c != null)];
        
        
        if(ContactList.size() > 0){
            for(sirenum__TicketType__c newComp :newCompMap.values()){
                for(Contact eachContact:ContactList){
                    sirenum__ticket__c newTicket = new sirenum__ticket__c();
                    newTicket.sirenum__TicketType__c = newComp.Id;
                    newTicket.sirenum__Owner__c = eachContact.Id;
                    if(newTicket.sirenum__TicketType__c != null && newTicket.sirenum__Owner__c != null ) 
                        newTicketList.add(newTicket);
                } 
            }
        }
        try {
            if(newTicketList.size()>0){
                Insert newTicketList;
            }
        }
        catch (Exception ex) {
            System.debug('An exception occurred: ' + ex.getMessage());
        }
        
        // Invoking createCompetencyCondition method...
        if(filteredList.size() > 0){
            createCompetencyConditionForJobType(filteredList);
        }
    }
    
    //
    public static void createCompetencyConditionForJobType(List<sirenum__TicketType__c> lstNewRecList){
        List<String> jobTypeList = new List<String>();
        Set<String> jobTypeSet = new Set<String>();
        Map<String,sirenum__Job_Type__c> jobTypeMap = new Map<String,sirenum__Job_Type__c>();
        Map<Id,List<String>> competencyMap = new Map<Id,List<String>>();
        Map<Id,sirenum__TicketType__c> competencyGenericMap = new Map<Id,sirenum__TicketType__c>();
        List<sirenum__Sirenum_Condition_Membership__c> compConditionToInsertList = new List<sirenum__Sirenum_Condition_Membership__c>();
        Set<String> competencyJobTypeSet = new Set<String>();
        
        for(sirenum__TicketType__c competency : lstNewRecList){
            jobTypeList = (competency.Job_Type__c).split(';');   
            competencyMap.put(competency.Id,jobTypeList);        
            competencyGenericMap.put(competency.Id,competency);
        }
        
        for(Id compId : competencyMap.keySet()){ 
            for(String s : competencyMap.get(compId)){ 
                jobTypeSet.add(s); 
            }
        }
        
        for(sirenum__Job_Type__c job : [SELECT Id,Name FROM sirenum__Job_Type__c WHERE Name IN: jobTypeSet]){
            jobTypeMap.put(job.Name,job); 
        }
        
        for(sirenum__Sirenum_Condition_Membership__c conditionComp : [SELECT Id,sirenum__TicketType__c,sirenum__Job_Type__r.Name 
                                                                      FROM sirenum__Sirenum_Condition_Membership__c WHERE sirenum__TicketType__c IN: competencyGenericMap.keySet() AND sirenum__Job_Type__r.Name IN: jobTypeSet]){
                                                                          competencyJobTypeSet.add(conditionComp.sirenum__TicketType__c+'_'+conditionComp.sirenum__Job_Type__r.Name);
                                                                      }
        
        for(Id competencyId : competencyMap.keySet()){ 
            for(String jobTypeName : competencyMap.get(competencyId)){
                if(!competencyJobTypeSet.contains(competencyId+'_'+jobTypeName)){
                    sirenum__Sirenum_Condition_Membership__c compCondition = new sirenum__Sirenum_Condition_Membership__c();
                    compCondition.sirenum__TicketType__c = competencyId;
                    compCondition.sirenum__Job_Type__c = jobTypeMap.containsKey(jobTypeName) ? jobTypeMap.get(jobTypeName).Id : '';
                    compCondition.sirenum__Severity__c = competencyGenericMap.containsKey(competencyId) ? competencyGenericMap.get(competencyId).Severity__c : '';
                    compConditionToInsertList.add(compCondition);
                }
            }
        }
        
        if(compConditionToInsertList.size() > 0){
            try{
                insert compConditionToInsertList;
            }
            catch(Exception e){
            }
        }
    }
    
    //
    public static void createCompetencyConditionForProjectTrainingComp(Map<Id,sirenum__TicketType__c> newComp,Map<Id,sirenum__TicketType__c>oldComp){
        List<String> siteList = new List<String>();
        Set<String> siteSet = new Set<String>();
        Map<Id,sirenum__TicketType__c> competencyGenericMap = new Map<Id,sirenum__TicketType__c>();
        Map<String,sirenum__Site__c> siteMap = new Map<String,sirenum__Site__c>();
        Map<Id,List<String>> competencyMap = new Map<Id,List<String>>();
        List<sirenum__Sirenum_Condition_Membership__c> compConditionToInsertList = new List<sirenum__Sirenum_Condition_Membership__c>();
        Set<String> competencySiteSet = new Set<String>();
        Set<Id> projectIdSet = new Set<Id>();
        
        for(sirenum__TicketType__c competency : newComp.values()){
            if((competency.Competence_Category__c=='Project Training' || competency.Competence_Category__c=='Project Site Training') && competency.Generate_Competency_Condition__c==True && competency.Generate_Competency_Condition__c!=oldComp.get(competency.Id).Generate_Competency_Condition__c){
                competencyGenericMap.put(competency.Id,competency);
                if(competency.Site__c!=null){
                    siteList = (competency.Site__c).split(', ');   
                    competencyMap.put(competency.Id,siteList);    
                }
                if(competency.Illingworth_Project__c!=null){
                    projectIdSet.add(competency.Illingworth_Project__c);
                }
            }
        }
        for(Id compId : competencyMap.keySet()){ 
            for(String s : competencyMap.get(compId)){ 
                siteSet.add(s); 
            }
        }
        if(siteSet.size()>0){
            for(sirenum__Site__c site : [SELECT Id,Name FROM sirenum__Site__c WHERE Name IN: siteSet]){
                siteMap.put(site.Name,site); 
            }
        }
        
        for(sirenum__Sirenum_Condition_Membership__c conditionComp : [SELECT Id,sirenum__TicketType__c,sirenum__Site__r.Name, sirenum__Site__c  
                                                                      FROM sirenum__Sirenum_Condition_Membership__c WHERE sirenum__TicketType__c IN: competencyGenericMap.keySet() AND sirenum__Site__r.Name IN: siteSet]){
                                                                          competencySiteSet.add(conditionComp.sirenum__TicketType__c+'_'+conditionComp.sirenum__Site__r.Name);
                                                                      }
        
        for(Id competencyId : competencyMap.keySet()){ 
            for(String siteName : competencyMap.get(competencyId)){
                if(!competencySiteSet.contains(competencyId+'_'+siteName) && competencyGenericMap.get(competencyId).Competence_Category__c=='Project Site Training'){
                    sirenum__Sirenum_Condition_Membership__c compCondition = new sirenum__Sirenum_Condition_Membership__c();
                    compCondition.sirenum__TicketType__c = competencyId;
                    compCondition.Project__c  = competencyGenericMap.containsKey(competencyId) ? competencyGenericMap.get(competencyId).Illingworth_Project__c  : '';
                    compCondition.sirenum__Site__c = siteMap.containsKey(siteName) ? siteMap.get(siteName).Id : '';
                    compCondition.sirenum__Severity__c = competencyGenericMap.containsKey(competencyId) ? competencyGenericMap.get(competencyId).Severity__c : '';
                    compConditionToInsertList.add(compCondition);
                }
            }
        }
        Map<Id,Id> ProjectIdAccIdMap=new Map<Id,Id>();
        for(sirenum__ProActiveContract__c proj:[Select id,name, sirenum__Client__c,sirenum__Client__r.Name from sirenum__ProActiveContract__c where id=:projectIdSet]){
            ProjectIdAccIdMap.put(proj.Id,proj.sirenum__Client__c);
        }
        for(Id competencyId : competencyGenericMap.keySet()){ 
            if(competencyGenericMap.get(competencyId).Competence_Category__c=='Project Training'){
                sirenum__Sirenum_Condition_Membership__c compCondition = new sirenum__Sirenum_Condition_Membership__c();
                compCondition.sirenum__TicketType__c = competencyId;
                compCondition.Project__c  = competencyGenericMap.containsKey(competencyId) ? competencyGenericMap.get(competencyId).Illingworth_Project__c  : '';
                compCondition.sirenum__Client__c=competencyGenericMap.containsKey(competencyId) ? ProjectIdAccIdMap.get(competencyGenericMap.get(competencyId).Illingworth_Project__c):'';
                compCondition.sirenum__Severity__c = competencyGenericMap.containsKey(competencyId) ? competencyGenericMap.get(competencyId).Severity__c : '';
                compConditionToInsertList.add(compCondition);
            }
        }
        if(compConditionToInsertList.size() > 0){
            try{
                insert compConditionToInsertList;
            }
            catch(Exception e){
                System.debug('Line Number -->>'+e.getLineNumber());
            }
        }
    }
    
    //Create Competancy Condition On creation and updation of Country competancy 
    public static void createCompConditionOnNewCompetancyCreation(Map<Id,sirenum__TicketType__c> newCompetencyMap,Map<Id,sirenum__TicketType__c> oldCompetencyMap){
        try{
            Map<String,Id> stateCountryCompMap= new Map<String,Id>();
            List<String> workCountry= new List<String>();
            List<String> splittedWorkCountry= new List<String>();
            List<String> splittedWorkState = new List<String>();
            List<string> canadaSplitted = Label.Canada_States.split(',');
            List<string> australiaSplitted = Label.Australia_States.split(',');
            List<string> USASplitted = Label.USA_States.split(',');
            List<sirenum__Sirenum_Condition_Membership__c> compConditionList=new List<sirenum__Sirenum_Condition_Membership__c>();
            for(sirenum__TicketType__c comp : newCompetencyMap.values()){
                if((comp.Generate_Competency_Condition__c ==True && (comp.Competence_Category__c=='Work Country' || comp.Competence_Category__c=='RN Mandatory Training'))&&( oldCompetencyMap==Null || comp.Generate_Competency_Condition__c!=oldCompetencyMap.get(comp.Id).Generate_Competency_Condition__c ) ){
                    if(comp.Work_Country__c!=null && comp.Work_State__c == null){
                        workCountry.add(comp.Work_Country__c);
                        splittedWorkCountry.addAll(comp.Work_Country__c.split(';'));
                        if(comp.Work_State__c != null)splittedWorkState.addAll(comp.Work_State__c.split(';'));
                        for (String country : splittedWorkCountry){
                            if(country == 'Canada'){
                                stateCountryCompMap.put(country,comp.Id);
                                for(String State : canadaSplitted){
                                    if(splittedWorkState != null && !splittedWorkState.contains(State)){
                                        String countryState = country+' - '+State;
                                        stateCountryCompMap.put(countryState,comp.Id);      
                                    }
                                }
                            }
                            if(country == 'Australia'){
                                stateCountryCompMap.put(country,comp.Id);
                                for(String State : australiaSplitted){
                                    if(splittedWorkState != null && !splittedWorkState.contains(State)){
                                        String countryState = country+' - '+State;
                                        stateCountryCompMap.put(countryState,comp.Id);   
                                    }
                                }
                            }
                            if(country == 'USA'){
                                stateCountryCompMap.put(country,comp.Id);
                                for(String State : USASplitted){
                                    if(splittedWorkState != null && !splittedWorkState.contains(State)){
                                        String countryState = country+' - '+State;
                                        stateCountryCompMap.put(countryState,comp.Id);   
                                    }
                                }
                            }
                            else{
                                stateCountryCompMap.put(country,comp.Id);    
                            }
                        }
                    }
                }
            }
            if(stateCountryCompMap!=null){
                List<sirenum__Location__c> locationList=[Select id,Name from sirenum__Location__c where name in:stateCountryCompMap.keySet()];
                Map<String,Id> locationNameIdMap=new Map<String,Id>();
                if(locationList.size()>0){
                    for(sirenum__Location__c location:locationList){
                        locationNameIdMap.put(location.Name, location.Id);
                    }
                    for(String comp: stateCountryCompMap.keySet()){
                        sirenum__Sirenum_Condition_Membership__c  compCondition=new sirenum__Sirenum_Condition_Membership__c ();
                        compCondition.sirenum__TicketType__c =stateCountryCompMap.get(comp);
                        compCondition.sirenum__Location__c=locationNameIdMap.get(comp)!=null ? locationNameIdMap.get(comp): null;
                        compCondition.sirenum__Severity__c=newCompetencyMap.get(stateCountryCompMap.get(comp)).Severity__c ;
                        if(comp.contains('-')){
                            compCondition.Work_Country__c= comp.split('-')[0];
                            compCondition.Work_State__c=comp.split('-')[1]; 
                        }
                        else{
                            compCondition.Work_Country__c=comp;     
                        }
                        
                        if(compCondition.sirenum__Location__c!=null) compConditionList.add(compCondition);
                    }
                }
                if(compConditionList.size()>0) Insert compConditionList; 
            }
        }
        Catch(Exception e){
            System.debug('>>>'+e.getMessage());
        }
    }
    
    //Create Competancy Condition On creation and updation of State competancy 
    public static void createCompConditionOnNewStateCompetancyCreation(Map<Id,sirenum__TicketType__c> newCompetencyMap,Map<Id,sirenum__TicketType__c> oldCompetencyMap){
        try{
            Map<String,Id> stateCountryCompMap= new Map<String,Id>();
            List<String> workState= new List<String>();
            List<String> splittedWorkCountry= new List<String>();
            List<sirenum__Sirenum_Condition_Membership__c> compConditionList=new List<sirenum__Sirenum_Condition_Membership__c>();
            for(sirenum__TicketType__c comp : newCompetencyMap.values()){
                if((comp.Generate_Competency_Condition__c ==True && (comp.Competence_Category__c=='Work State'|| comp.Competence_Category__c=='RN Mandatory Training'))&&( oldCompetencyMap==Null || comp.Generate_Competency_Condition__c!=oldCompetencyMap.get(comp.Id).Generate_Competency_Condition__c ) ){
                    if(comp.Work_State__c !=null){
                        splittedWorkCountry.addAll(comp.Work_State__c .split(';'));
                        for (String state : splittedWorkCountry){
                            stateCountryCompMap.put(state,comp.Id);
                            workState.add('%'+state+'%');
                        }
                    }
                }
            }
            if(stateCountryCompMap!=null){
                List<sirenum__Location__c> locationList=[Select id,Name from sirenum__Location__c where name LIKE :workState];
                Map<String,Id> locationNameIdMap=new Map<String,Id>();
                if(locationList.size()>0){
                    for(sirenum__Location__c location:locationList){
                        List<String> state=location.Name.split('- ');
                        locationNameIdMap.put((state.size() == 2) ? state[1] : location.Name,location.Id);
                    }
                    List<String> canadaSplitted = Label.Canada_States.split(',');
                    List<String> australiaSplitted = Label.Australia_States.split(',');
                    List<String> USASplitted = Label.USA_States.split(',');
                    
                    for(String comp: stateCountryCompMap.keySet()){
                        sirenum__Sirenum_Condition_Membership__c  compCondition=new sirenum__Sirenum_Condition_Membership__c ();
                        compCondition.sirenum__TicketType__c =stateCountryCompMap.get(comp);
                        compCondition.sirenum__Location__c=locationNameIdMap.get(comp)!=null ? locationNameIdMap.get(comp): null;
                        compCondition.sirenum__Severity__c=newCompetencyMap.get(stateCountryCompMap.get(comp)).Severity__c ;
                        compCondition.Work_State__c=comp; 
                        if(canadaSplitted.contains(comp)){
                            compCondition.Work_Country__c='Canada'; 
                        }
                        Else if(australiaSplitted.contains(comp)){
                            compCondition.Work_Country__c='Australia'; 
                        }
                        else if(USASplitted.contains(comp)){
                            compCondition.Work_Country__c='USA'; 
                        }
                        else{
                            compCondition.Work_Country__c=''; 
                        }
                        if(compCondition.sirenum__Location__c!=null) compConditionList.add(compCondition);
                    }
                }
                if(compConditionList.size()>0) Insert compConditionList; 
            }
        }
        Catch(Exception e){
            System.debug('>>>'+e.getMessage());
        }
    }
    
    //Non Project Member Cannot Create or Edit Competency Validation
    public static void validationforNonProjectMembers (List<sirenum__TicketType__c> competency){
        
        User userProfile = [SELECT Id, Name, ProfileId , Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        if(userProfile.Profile.Name != 'System Administrator' || test.isRunningTest()){
            Map<Id,sirenum__ProActiveContract__c> project = new Map<Id,sirenum__ProActiveContract__c>();
            Set<Id> projectId=new Set<Id>();
            Set<String> groupNames = new Set<String>();
            Map<String,Boolean> projectVsTeamMember = new Map<String,Boolean>();
            
            for(sirenum__TicketType__c comp: competency){
                if(comp.Illingworth_Project__c  != null && (comp.Competence_Category__c == 'Site Activation Resource' || comp.Competence_Category__c == 'Project Training' || comp.Competence_Category__c == 'Project Site Training')){
                    projectId.add(comp.Illingworth_Project__c);
                }
                else if(comp.Illingworth_Project__c == null && userProfile.Profile.Name == 'RNPM/PC' && !test.isRunningTest()){
                    comp.adderror('PMPC user can only edit or create competencies linked to the Project they belong to');
                }
            }
            if(!projectId.isEmpty()){
                project = new Map<Id,sirenum__ProActiveContract__c>([SELECT Id, Project_Team__r.Name , Project_Team__c from sirenum__ProActiveContract__c where id IN : projectId]);
                if(project !=null && project.size()>0 ){
                    for(sirenum__ProActiveContract__c c : project.values()){
                        groupNames.add(c.Project_Team__r.Name);
                    }
                    for(Group g : [Select Id,Name,(select userOrGroupId from groupMembers where UserOrGroupId =: userInfo.getUserId()) from Group where Name IN : groupNames]){
                        
                        if(g.groupMembers != null && g.groupMembers.size() != 0){
                            projectVsTeamMember.put(g.Name,false);  
                        }
                        
                    }
                }
                if(competency.size()>0){
                    for(sirenum__TicketType__c comp: competency){
                        if((userProfile.Profile.Name == 'RNPM/PC' && (projectVsTeamMember.isEmpty() || (!projectVsTeamMember.isEmpty() && !projectVsTeamMember.containsKey(project.get(comp.Illingworth_Project__c).Project_Team__r.Name)))) && !test.isRunningTest()){
                            comp.adderror('PMPC user can only edit or create competencies linked to the Project they belong to.');
                        }
                    }
                }
            }
        }
    }
}