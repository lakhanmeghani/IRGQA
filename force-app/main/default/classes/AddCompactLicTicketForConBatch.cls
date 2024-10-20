global class AddCompactLicTicketForConBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Name, Compact_Licence__c,Valid_Until_from_Compact_License__c,Status_from_Compact_License__c, Illing_Licenced_in_States_Province__c from Contact where RecordType.Name = 'Resource' and Compact_Licence__c=True and Illing_Licenced_in_States_Province__c!=null ]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> contactList){
        List<sirenum__ticket__c> newTicketInsertList = new List<sirenum__ticket__c >();
        List<String> StateListInCompactLic = new List<String >();
        Map<String,sirenum__TicketType__c> compNameMap=new Map<String,sirenum__TicketType__c>();
        for(Compact_Licence__c eachStates : [Select Id , Name , Country__c  from Compact_Licence__c]){
            StateListInCompactLic.add(eachStates.Name);
        }
        for(sirenum__TicketType__c eachStatesComp : [Select id,name, Competence_Category__c, Licensed_In_State_Competency__c, Work_State__c from sirenum__TicketType__c where Competence_Category__c='Work State' and Licensed_In_State_Competency__c=True]){
            compNameMap.put(eachStatesComp.Work_State__c,eachStatesComp);
        }
        List<String> newStateList=new List<String>();
        for(Contact eachContact:contactList){
            newStateList=(eachContact.Illing_Licenced_in_States_Province__c ).split(';');
            for(String state:newStateList){
                if(StateListInCompactLic.contains(state)){
                    sirenum__ticket__c newTicket = new sirenum__ticket__c();
                    if(compNameMap.get(state)!=null){
                    newTicket.sirenum__TicketType__c = compNameMap.get(state).Id;
                    newTicket.sirenum__Owner__c = eachContact.Id;
                    newTicket.sirenum__Valid_until__c=eachContact.Valid_Until_from_Compact_License__c ; 
                    newTicket.SK_Status__c =eachContact.Status_from_Compact_License__c ;
                        }
                    if(newTicket.sirenum__TicketType__c != null && newTicket.sirenum__Owner__c != null )
                        newTicketInsertList.add(newTicket);
                }
            }
        }
        if(newTicketInsertList.size()>0){
            Database.Insert(newTicketInsertList,False);
        }    
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }  
}