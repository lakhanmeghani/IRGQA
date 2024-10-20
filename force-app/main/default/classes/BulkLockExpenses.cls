// 21919 -> 'Lock' functionality automation Expenses
public class BulkLockExpenses {
    @InvocableMethod(label='Bulk Lock Approved Expenses' description='Bulk Lock Approved Expenses by FSU' category='Expenses')
    public static List<String> BulkLockExpense(List<Date> dt)
    {
        Date LockDate=dt[0];
        List<irg_Expense__c> expenseToUpdate=new List<irg_Expense__c>();
        List<String> UpdatedExpensesCountList=new List<String>();
        List<irg_Expense__c> expenseList=[SELECT Id, Name,Status__c, Locked__c, Bulk_Lock_Expense_Date__c 
                                          FROM irg_Expense__c WHERE Locked__c= FALSE
                                          AND DAY_ONLY(CreatedDate) <= : LockDate]; 
        System.debug('ListToUpdateSize-->'+expenseList.size());
        if(expenseList.size()<10000){
            if(!expenseList.isEmpty()){
            for(irg_Expense__c expense:expenseList){
                expense.Locked__c=TRUE;
                expense.Bulk_Lock_Expense_Date__c=System.today();
                expenseToUpdate.add(expense);
            }
        }
        if(!expenseToUpdate.isEmpty()){
            try{
                update expenseToUpdate;
                System.debug('Update successful');
            }catch(DmlException e){
                System.debug('Exception occured while processing'+e.getMessage());
                String errorMsg=e.getMessage();
                UpdatedExpensesCountList.add(errorMsg);
                return UpdatedExpensesCountList;
            }
        }
        Integer UpdatedExpensesCount=expenseToUpdate.size();
        UpdatedExpensesCountList.add(UpdatedExpensesCount.toString());
        }
        if(expenseList.size()>10000){
            String LargeRecordsError='Error : More than 10000 records found!';
            UpdatedExpensesCountList.add(LargeRecordsError);
        }
        return UpdatedExpensesCountList;
    }
}