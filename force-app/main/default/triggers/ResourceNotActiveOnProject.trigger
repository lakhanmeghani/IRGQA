trigger ResourceNotActiveOnProject on sirenum__Shift__c (before insert,before update, after insert, after update) {
    /*if(trigger.isAfter && trigger.isInsert){
        ResourceNotActiveOnProjectHandler.CheckActiveOnProject(trigger.new);
    }
    if(trigger.isBefore && trigger.isInsert){
        ResourceNotActiveOnProjectHandler.checkTargetDate(trigger.new);
    }*/
}