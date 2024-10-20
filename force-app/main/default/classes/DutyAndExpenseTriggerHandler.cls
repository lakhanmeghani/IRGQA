public without sharing class DutyAndExpenseTriggerHandler {
    
    public static void updateDutyOwner(List<Duty__c> newList,Map<Id,Duty__c> oldMap){
        Map<Id,sirenum__ProActiveContract__c> projectMap = new Map<Id,sirenum__ProActiveContract__c>();
        for(Duty__c duty : newList){
            if(Trigger.isInsert|| (Trigger.isUpdate && duty.Project__c != oldMap.get(duty.Id).Project__c)){
            if(duty.Project__c != null)
                projectMap.put(duty.Project__c,null);
            }
        }
        if(!projectMap.isEmpty()){
            projectMap = new Map<Id,sirenum__ProActiveContract__c>([Select Id,Project_Team__r.OwnerId  from sirenum__ProActiveContract__c where Id IN : projectMap.KeySet()]);
        }
        for(Duty__c duty : newList){
            if(duty.Project__c != null && projectMap.get(duty.Project__c) != null)
                duty.OwnerId = projectMap.get(duty.Project__c).Project_Team__r.OwnerId;
            
        }
    }
    
    public static void updateExpenseOwner(List<irg_Expense__c> newList,Map<Id,irg_Expense__c> oldMap){
        Map<Id,sirenum__ProActiveContract__c> projectMap = new Map<Id,sirenum__ProActiveContract__c>();
        Map<Id,sirenum__Shift__c> shiftMap = new Map<Id,sirenum__Shift__c>();
        for(irg_Expense__c exp : newList){
           
            if(exp.Project__c != null && (Trigger.isInsert || (Trigger.isUpdate && exp.Project__c != oldMap.get(exp.Id).Project__c)))
                projectMap.put(exp.Project__c,null);
            else if(exp.Visit__c != null && (Trigger.isInsert || (Trigger.isUpdate && exp.Visit__c != oldMap.get(exp.Id).Visit__c))){
                shiftMap.put(exp.Visit__c,null);
            }
                
            
        }
        if(!shiftMap.isEmpty()){
             shiftMap  = new Map<Id,sirenum__Shift__c>([Select Id,sirenum__Contract__r.Project_Team__r.OwnerId  from sirenum__Shift__c where Id IN : shiftMap.keySet()]);
        }
        if(!projectMap.isEmpty()){
            projectMap = new Map<Id,sirenum__ProActiveContract__c>([Select Id,Project_Team__r.OwnerId  from sirenum__ProActiveContract__c where Id IN : projectMap.KeySet()]);
            
            for(irg_Expense__c exp : newList){
                if(exp.Project__c != null && projectMap.get(exp.Project__c) != null)
                    exp.OwnerId = projectMap.get(exp.Project__c).Project_Team__r.OwnerId;
                else if(exp.Visit__c != null &&  shiftMap.get(exp.Visit__c) != null){
                     exp.OwnerId = shiftMap.get(exp.Visit__c).sirenum__Contract__r.Project_Team__r.OwnerId;
                }
                
            }
        }
    }
    
    public static void dutyDateValidation(List<Duty__c> newList,Map<Id,Duty__c> oldMap){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        for(Duty__c duty : newList){
            boolean isLastWeek = DutyAndExpenseTriggerHandler.isLastWeek(duty.Date_of_Duty__c);
            //system.debug('isLastWeek=='+isLastWeek);
            boolean dayOfWeek = DutyAndExpenseTriggerHandler.dayOfWeek();
            if (isLastWeek && dayOfWeek && duty.Actual_Duration__c != oldMap.get(duty.id).Actual_Duration__c) {
                if((duty.status__c == 'Submitted' || duty.status__c == 'Rejected') && (profileName != 'System Administrator' && profileName != 'Finance Super User')){
                    duty.adderror('You cannot edit Actual Duration on duty for the previous week from the Wednesday of the current week');
                }
            }
        }
    }
    
    public static Boolean isLastWeek(Date dutyDate) {
        DateTime startOfThisWeek = Date.today().toStartofWeek();
        //system.debug('startOfThisWeek==='+startOfThisWeek);
        DateTime startOfLastWeek = startOfThisWeek.addDays(-7);
        //system.debug('startOfLastWeek==='+startOfLastWeek);
        // Check if dutyDate is after start of last week and before start of this week
        return dutyDate >= startOfLastWeek && dutyDate < startOfThisWeek;
    }
    
    public static Boolean dayOfWeek() {
        datetime dt = system.today();
        String todayDayOfWeek = dt.format('E'); // Get the full name of the day of the week
        //system.debug('Day is=='+todayDayOfWeek);
        if (!todayDayOfWeek.equals('Mon') && !todayDayOfWeek.equals('Tue')) {
            return true;
        } else {
            return false; // Today is Monday or Tuesday, so it's not considered this week
        }
    }
    
    // To prevent deletion of duties when their Locked status is true
    public static void preventLockedDuties(List<Duty__c> oldList){

        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        for(Duty__c duty:oldList){
            if((duty.Locked__c == true) && (profileName != 'System Administrator' && profileName != 'Finance Super User')){
                duty.addError('You cannot delete locked duties');
            }
        }
    } 
    
    // To prevent deletion of expenses when their Locked status is true
    public static void preventLockedExpenses(List<irg_Expense__c> oldList){

        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        for(irg_Expense__c expense:oldList){
            if((expense.Locked__c == true) && (profileName != 'System Administrator' && profileName != 'Finance Super User')){
                expense.addError('You cannot delete locked expenses');
            }
        }
    }
    
    // PBI No. 22102 -> To populate Expense Sheet Title at the time of new expense record creation
   public static void populateExpenseSheetTitle(List<irg_Expense__c> expenseList) {
    // Collect the Expense Owner (Contact) Ids
    Set<Id> contactIds = new Set<Id>();
    for (irg_Expense__c expense : expenseList) {
        if (expense.Expense_Owner__c != null) {
            contactIds.add(expense.Expense_Owner__c);
        }
    }

    // Fetch related contacts with HRID
    Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Illingworth_HR_ID_Number__c FROM Contact WHERE Id IN :contactIds]);

    // Get the current system date as Datetime
    Date currentDate = System.today(); // Keeps the date part
    Datetime currentDateTime = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());

    // Populate the Expense_sheet_title__c field
    for (irg_Expense__c expense : expenseList) {
        if (expense.Expense_Owner__c != null && contactMap.containsKey(expense.Expense_Owner__c)) {
       
            
            // Get HRID and format date, only if HRID is not blank
            
            if (String.isNotBlank(contactMap.get(expense.Expense_Owner__c).Illingworth_HR_ID_Number__c)) {
                String month = currentDateTime.format('MMM').toUpperCase(); // Get the current month in MMM format
                String year = currentDateTime.format('YYYY'); // Get the current year
                
                // Set the field value as per the format
                expense.Expense_sheet_title__c = contactMap.get(expense.Expense_Owner__c).Illingworth_HR_ID_Number__c + '-EXP-' + month + year;
            } 
        }
    }

   }

}