trigger CheckSiteProjectTeamMembers on sirenum__Site__c (before insert,before update,after update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            CheckSiteProjectTeamMemberHandler.updateCountry(trigger.new);
        }
        else if(Trigger.isUpdate){
            CheckSiteProjectTeamMemberHandler.updateCountry(trigger.new);
        }
    }
    else if(trigger.isAfter){ 
        if(Trigger.isUpdate){
            CheckSiteProjectTeamMemberHandler.updateCompetancyNameOnSiteChange(trigger.newMap,trigger.oldMap);
            CheckSiteProjectTeamMemberHandler.updatePlacementNameOnSiteNumberChange(trigger.newMap,trigger.oldMap);
        }
    }
}