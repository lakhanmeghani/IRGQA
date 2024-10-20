trigger SetAtsJobConverionid on Illingworth_ATS_Job_Conversion__c (after insert) {
 SetAtsJobConverionidHandler.SetAtsJobConverion(trigger.new);
}