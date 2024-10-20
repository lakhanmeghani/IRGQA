trigger ContetDocumetLinkTrigger on ContentDocumentLink (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            DocumentUploadTriggerHandler.contentUpload(Trigger.new);
        }
    }
   /* Set<Id> parentIdSet = new Set<Id>();
    List<sirenum__Ticket__c> ListOfTicketToUpdate = new List<sirenum__Ticket__c>();
    List<sirenum__Ticket__c> ListOfTicket = new List<sirenum__Ticket__c>();
    for(ContentDocumentLink cdl : trigger.new){
        String sObjName = (cdl.LinkedEntityId).getSObjectType().getDescribe().getName();
        if(sObjName == 'sirenum__Ticket__c'){
            parentIdSet.add(cdl.LinkedEntityId);
        }
    }
    if(parentIdSet != null){
        ListOfTicket = [SELECT Id,Name,Proof_of_Completed__c FROM sirenum__Ticket__c WHERE Id=: parentIdSet];
    }
    if(ListOfTicket.size() > 0){
        for(sirenum__Ticket__c  tkt : ListOfTicket){
            sirenum__Ticket__c  tktUpdate = new sirenum__Ticket__c ();
            tktUpdate.Id = tkt.Id;
            tktUpdate.Proof_of_Completed__c = true;
            
            ListOfTicketToUpdate.add(tktUpdate);
        }
    }
    
    if(ListOfTicketToUpdate != null){
        UPDATE ListOfTicketToUpdate; 
    }*/
    
}