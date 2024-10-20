trigger AttachmentTrigger on Attachment (after insert) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            DocumentUploadTriggerHandler.attachmentUpload(Trigger.new);
        }
    }
   
}