public class DocumentUploadTriggerHandler {
    public static Set<Id> parentIdSet = new Set<Id>();
    public static void attachmentUpload(List<Attachment> attchmentList){
        
        for(Attachment attachment : attchmentList){
        String sObjName = (attachment.ParentId).getSObjectType().getDescribe().getName();
        //Id attachmentLinkedId=attachment.ParentId;
        if(sObjName == 'sirenum__Ticket__c'){
            parentIdSet.add(attachment.ParentId);
        }
    }
        setProofOfCompletedAsTrue(parentIdSet);
        
    }
    public static void contentUpload(List<ContentDocumentLink> contentDocumentLinkList){
        for(ContentDocumentLink cdl : contentDocumentLinkList){
        String sObjName = (cdl.LinkedEntityId).getSObjectType().getDescribe().getName();
        if(sObjName == 'sirenum__Ticket__c'){
            parentIdSet.add(cdl.LinkedEntityId);
        }
    }
        setProofOfCompletedAsTrue(parentIdSet);
        
    }
    public static void setProofOfCompletedAsTrue(Set<Id> parentIdCollection){
        List<sirenum__Ticket__c> ListOfTicketToUpdate = new List<sirenum__Ticket__c>();
    	List<sirenum__Ticket__c> ListOfTicket = new List<sirenum__Ticket__c>();
        if(parentIdCollection != null){
        ListOfTicket = [SELECT Id,Name,Proof_of_Completed__c FROM sirenum__Ticket__c WHERE Id=: parentIdCollection];
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
    }

        
    }

}