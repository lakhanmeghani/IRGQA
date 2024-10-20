global  class CheckTicketValidUntilScheduler implements schedulable {
    global void execute(SchedulableContext SC) {
      CheckTicketValidUntil tickets = new CheckTicketValidUntil();
        database.executeBatch(tickets);
   }

}