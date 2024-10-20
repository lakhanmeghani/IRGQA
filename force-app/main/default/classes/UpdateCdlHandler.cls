public class UpdateCdlHandler {
    
    //
    public static void afterInsert(List<ContentDocumentLink> cdls ){
        
        Set<ID> parentIds = new Set<ID>();
        Set<ID> parentIdForAsset = new Set<ID>();
        for( ContentDocumentLink cdl : cdls ){
            
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName()=='Asset'){
                parentIdForAsset.add(cdl.LinkedEntityId); 
                setAttachmentAvailableAsTrue(parentIdForAsset);
            }
            else {
                parentIds.add( cdl.LinkedEntityId);
            }
        }
        if(parentIds.size()>0){
            List<sirenum__Shift__c> visit = [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM sirenum__Shift__c WHERE Id IN :parentIds Limit 10];            
            if(visit.size()>0){    
                for ( sirenum__Shift__c q : visit ) {
                    if(q.ContentDocumentLinks.size() > 0){
                        q.Has_Attachment__c = true;
                    }
                }
            }
            update visit;
            List<Task> task = [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Task WHERE Id IN :parentIds ] ;        
            if(task.size()>0){    
                for ( Task t : task ) {
                    if(t.ContentDocumentLinks.size() > 0){
                        t.Task_has_Attachment__c = true;
                    }
                    else{
                        t.Task_has_Attachment__c = false;   
                    }
                }
            }
            update task;
        }
    }
    
    //Check Attachment_available__c in asset when  file are uploaded
    //Trigger in updatecdl
    public static void setAttachmentAvailableAsTrue(Set<Id> parentIdForAsset){
        List<Asset> assetQuery=new List<Asset>();
        List<Asset> assetRecordsToUpdate=new List<Asset>();
        if(parentIdForAsset.size()>0){
            assetQuery = [ SELECT Id,Attachment_available__c, ( SELECT Id FROM ContentDocumentLinks LIMIT 1 ) FROM Asset WHERE Id IN :parentIdForAsset]; 
            
            if(assetQuery.size()>0){    
                for ( Asset assetRec : assetQuery ) {
                    if(assetRec.ContentDocumentLinks.size() > 0){
                        if(assetRec.Attachment_available__c==False){
                            assetRec.Attachment_available__c  = true;
                            assetRecordsToUpdate.add(assetRec);
                        }
                    }
                }
            }
            if(assetRecordsToUpdate.size()>0) update assetRecordsToUpdate;
        }
    }
    
    //Uncheck Attachment_available__c checkbox in asset when all files are deleted
    //Trigger Written in content document
    public static void setAttachmentAvailableAsFalse(List<ContentDocument> contentDoc){
        Set<Id> parentIds=new Set<Id>();
        Set<Id> contentDocumentIdSet=new Set<Id>();
        List<ContentDocumentLink> cdls=new List<ContentDocumentLink>();
        for(ContentDocument cd:contentDoc){
            contentDocumentIdSet.add(cd.Id);
        }
        
        if(contentDocumentIdSet.size()>0){
            cdls =[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIdSet];
        }
        
        for ( ContentDocumentLink cdl : cdls ) {
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName()=='Asset'){
                parentIds.add( cdl.LinkedEntityId);
            }
        }
        
        List<Asset> assetQuery=new List<Asset>();
        List<Asset> assetRecordsToUpdate = new List<Asset>();
        if(parentIds.size()>0){
            assetQuery = [ SELECT Id,Attachment_available__c, ( SELECT Id FROM ContentDocumentLinks  ) FROM Asset WHERE Id IN :parentIds]; 
            
            if(assetQuery.size()>0){    
                for ( Asset assetRec : assetQuery ) {
                    if(assetRec.ContentDocumentLinks.size() ==1){
                        if(assetRec.Attachment_available__c==True){
                            assetRec.Attachment_available__c  = False;
                            assetRecordsToUpdate.add(assetRec);
                        }
                    }
                }
            }
            if(assetRecordsToUpdate.size()>0) update assetRecordsToUpdate;
        }
    }
}