trigger UpdateCDL on ContentDocumentLink (after insert, after update,after delete) {
    
    if(Trigger.isAfter ){     
    	UpdateCdlHandler.afterInsert(trigger.new);
        
        }

}