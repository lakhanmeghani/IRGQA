public without sharing class TDispatch {
    public interface THelperClass {
        void beforeInsert();  
        void afterInsert();
        void beforeUpdate();
        void afterUpdate();
        void beforeDelete();
        void afterDelete();
        void afterUndelete();
    }

    public interface THandlerClass {
        void mainEntry(TContext tc);
        void inProgressEntry(TContext tc);
        void onBeforeInsert(TContext tc);
        void onBeforeUpdate(TContext tc);
        void onBeforeDelete(TContext tc);
        void onAfterInsert(TContext tc);
        void onAfterUpdate(TContext tc);
        void onAfterDelete(TContext tc);
        void onAfterUnDelete(TContext tc);
    }
    
    public class TException extends Exception {
    }

    public class TContext {
        public Boolean isExecuting { get; private set; }
        public Boolean isInsert { get; private set; }
        public Boolean isUpdate { get; private set; }
        public Boolean isDelete { get; private set; }
        public Boolean isBefore { get; private set; }
        public Boolean isAfter { get; private set; }
        public Boolean isUndelete { get; private set; }
        public List<SObject> newList { get; private set; }
        public Map<Id, SObject> newMap { get; private set; }
        public List<SObject> oldList { get; private set; }
        public Map<Id, SObject> oldMap { get; private set; }
        public Integer size { get; private set; }
        public String handler { get; private set; }

        public TContext(Boolean isExecuting, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter, Boolean isUndelete,
                        List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap, Integer size, String handler) {
            this.isExecuting = isExecuting;
            this.isInsert = isInsert;
            this.isUpdate = isUpdate;
            this.isDelete = isDelete;
            this.isBefore = isBefore;
            this.isAfter = isAfter;
            this.isUndelete = isUndelete;
            this.newList = newList;
            this.newMap = newMap;
            this.oldList = oldList;
            this.oldMap = oldMap;
            this.size = size;
            this.handler = handler;
        }   
    }

    private static Map<String, Integer> dispatchCounter = new Map<String, Integer>();
    private static THandlerClass activeTriggerHandler = null;

    public static Integer getHandlerCount(String handler) {
        if (dispatchCounter.containsKey(handler)) {           
            return dispatchCounter.get(handler);
        } else {
            return 0;
        }
    }

    public static void dispatchTriggerHandler(TContext tc) {
        System.debug('TDispatch.dispatchTriggerHandler() tc.handler:' + tc.handler);
        if (activeTriggerHandler != null) {
            activeTriggerHandler.inProgressEntry(tc);
            return;
        } else {
            if (!String.isEmpty(tc.handler)) {
                Type handlerClass = Type.forName(tc.handler);
                activeTriggerHandler = (THandlerClass)handlerClass.newInstance();
                activeTriggerHandler.mainEntry(tc);

                if (dispatchCounter.containsKey(tc.handler)) {   
                    dispatchCounter.put(tc.handler, dispatchCounter.get(tc.handler) + 1);
                } else {
                    dispatchCounter.put(tc.handler, 1);
                }
            }
        } 
    }

    public static void forwardTrigger(TContext tc, THandlerClass currentTriggerHandler) {  
        System.debug('TDispatch.forwardTrigger() tchandler:' + tc.handler);
        TDispatch.activeTriggerHandler = null;
        TDispatch.dispatchTriggerHandler(tc);
        TDispatch.activeTriggerHandler = currentTriggerHandler;
    }
}