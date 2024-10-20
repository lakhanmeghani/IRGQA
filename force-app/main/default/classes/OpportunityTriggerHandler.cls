public without sharing class OpportunityTriggerHandler implements TDispatch.THandlerClass {

    public static Boolean mainHasRun = false;
    public static Boolean inProgressHasRun = false;   
    public static Boolean isBeforeInsertRan = false;
    public static Boolean isAfterInsertRan = false;
    public static Boolean isBeforeUpdateRan = false;
    public static Boolean isAfterUpdateRan = false;
    public static Boolean isBeforeDeleteRan = false;
    public static Boolean isAfterDeleteRan = false;
    public static Boolean isAfterUndeleteRan = false;

    public void mainEntry(TDispatch.TContext tc) {
        System.debug('--OpportunityTriggerHandler.mainEntry()');
        mainHasRun = true;

        if (tc.handler == 'OpportunityTriggerHandler') {
            if (tc.isBefore && tc.isInsert) { onBeforeInsert(tc); }
            else if (tc.isAfter && tc.isInsert) { onAfterInsert(tc); }
            else if (tc.isBefore && tc.isUpdate) { onBeforeUpdate(tc); }
            else if (tc.isAfter && tc.isUpdate) { onAfterUpdate(tc); }
            else if (tc.isBefore && tc.isDelete) { onBeforeDelete(tc); }
            else if (tc.isAfter && tc.isDelete) { onAfterDelete(tc); }
            else if (tc.isAfter && tc.isUndelete) { onAfterUndelete(tc); }
        }
    }

    public void inProgressEntry(TDispatch.TContext tc) {
        System.debug('--OpportunityTriggerHandler.inProgressEntry()');
        inProgressHasRun = true;

        if (tc.handler == 'OpportunityTriggerHandler') {
            if (tc.isBefore && tc.isInsert) { onBeforeInsert(tc); }
            else if (tc.isAfter && tc.isInsert) { onAfterInsert(tc); }
            else if (tc.isBefore && tc.isUpdate) { onBeforeUpdate(tc); }
            else if (tc.isAfter && tc.isUpdate) { onAfterUpdate(tc); }
            else if (tc.isBefore && tc.isDelete) { onBeforeDelete(tc); }
            else if (tc.isAfter && tc.isDelete) { onAfterDelete(tc); }
            else if (tc.isAfter && tc.isUndelete) { onAfterUndelete(tc); }
        } else if (tc.handler != 'OpportunityTriggerHandler') {
            TDispatch.forwardTrigger(tc, this);
        }
    }

    public static void setAllRanTrue() {
        inProgressHasRun = true;   
        isBeforeInsertRan = true;
        isAfterInsertRan = true;
        isBeforeUpdateRan = true;
        isAfterUpdateRan = true;
        isBeforeDeleteRan = true;
        isAfterDeleteRan = true;
        isAfterUndeleteRan = true;
    }

    public static void setAllRanFalse() {
        System.debug('--setAllRanFalse Called');
        inProgressHasRun = false;   
        isBeforeInsertRan = false;
        isAfterInsertRan = false;
        isBeforeUpdateRan = false;
        isAfterUpdateRan = false;
        isBeforeDeleteRan = false;
        isAfterDeleteRan = false;
        isAfterUndeleteRan = false;
        System.debug('--isBeforeUpdateRan==' + isBeforeUpdateRan);
    }

    public void onBeforeInsert(TDispatch.TContext tc) {
        System.debug('before insert');
    }

    public void onBeforeUpdate(TDispatch.TContext tc) {
        // Logic for before update
    }

    public void onBeforeDelete(TDispatch.TContext tc) {
        System.debug('before delete');
    }

    public void onAfterInsert(TDispatch.TContext tc) {
        System.debug('after insert');
    }

    public void onAfterUpdate(TDispatch.TContext tc) {
        System.debug('after update');
    }

    public void onAfterDelete(TDispatch.TContext tc) {
        System.debug('after delete');
    }

    public void onAfterUnDelete(TDispatch.TContext tc) {
        System.debug('after undeleteupdate');
    }
}