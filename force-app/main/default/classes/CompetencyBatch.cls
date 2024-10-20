global class CompetencyBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
      /*  String query = 'SELECT Id, Name, sirenum__TicketType__c, sirenum__TicketType__r.Effective_From__c, sirenum__TicketType__r.Date_Received_by_Illingworth__c, Inactive__c ' + 
                       'FROM sirenum__Sirenum_Condition_Membership__c ' + 
                       'WHERE (sirenum__TicketType__r.Effective_From__c != null OR sirenum__TicketType__r.Date_Received_by_Illingworth__c != null)';  */
        String query = 'SELECT Id, Name, sirenum__TicketType__c, sirenum__TicketType__r.Effective_From__c, sirenum__TicketType__r.Date_Received_by_Illingworth__c, Inactive__c ' + 
                       'FROM sirenum__Sirenum_Condition_Membership__c ';
        System.debug('Query -- ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sirenum__Sirenum_Condition_Membership__c> scope) {
        List<sirenum__Sirenum_Condition_Membership__c> compConditionToUpdateList = new List<sirenum__Sirenum_Condition_Membership__c>();
        Date today = System.today();
        

        for (sirenum__Sirenum_Condition_Membership__c compCondition : scope) {
            Date effectiveDate = compCondition.sirenum__TicketType__r.Effective_From__c;
            Date lmsDate = compCondition.sirenum__TicketType__r.Date_Received_by_Illingworth__c;
            Boolean isInactive = compCondition.Inactive__c;  // Default to current value to minimize unnecessary updates
            // Combine conditions for inactive = true
            if ((effectiveDate == null && lmsDate == today) || 
                (effectiveDate!=null && effectiveDate <= Today && lmsDate <= Today)||         
                (effectiveDate != null && effectiveDate > today &&      
                 (lmsDate == null || lmsDate > today))) {               
                isInactive = true;
            }
            // Combine conditions for inactive = false
            else if ((effectiveDate==null && lmsDate==null)||
                     effectiveDate != null && effectiveDate <= today  &&  
                     (lmsDate == null || lmsDate >= today)) {
                isInactive = false;
            }

            // Add to update list if there is a change
            if (compCondition.Inactive__c != isInactive) {
                compCondition.Inactive__c = isInactive;
                compConditionToUpdateList.add(compCondition);
            }
        }

        if (!compConditionToUpdateList.isEmpty()) {
            try {
                Database.update(compConditionToUpdateList, false);
            } catch (Exception e) {
                System.debug('Exception caught -- ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}