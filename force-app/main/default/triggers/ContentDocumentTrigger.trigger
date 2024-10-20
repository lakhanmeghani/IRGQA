trigger ContentDocumentTrigger on ContentDocument (before delete) {
	if( Label.Content_Document_Trigger_Flag =='True' || Test.isRunningTest() ) { 
		if(Trigger.isDelete){
            UpdateCdlHandler.setAttachmentAvailableAsFalse(trigger.old);
        }
    }
}