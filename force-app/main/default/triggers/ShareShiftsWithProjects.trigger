/* 
* Create manual shares for shifts based on the the Sirenum Contract (Project) on the Job Role
* Shifts are shared with the group that has the same name as the project
*/

trigger ShareShiftsWithProjects on sirenum__Shift__c (before insert, before update, after insert, after update,before delete) {
    
    if( Label.Visit_Trigger_Flag =='True'){
        if(Trigger.isAfter){ 
        } 
        List<Id> shiftIdsToShare = new List<Id>();
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                for (sirenum__Shift__c shft : trigger.new){
                    if (shft.sirenum__Contact__c  != null){
                        shft.Triggering_Record_Log__c = 'Yes';                        
                    }
                } 
                ResourceNotActiveOnProjectHandler.setDefaultValuesAndValidations(trigger.new);
                if( VisitHelper.checkValidSiteActivationTicketFlag){
                    VisitHelper.checkValidSiteActivationTicket(trigger.new);
                }
                if(ResourceNotActiveOnProjectHandler.recursiveCheck){
                    ResourceNotActiveOnProjectHandler.CheckActiveOnProject(trigger.new,trigger.newMap,Trigger.oldMap);
                }
            }
            if(Trigger.isAfter){
                if(TurnAroundTimeHandler.tatFlag){
                    TurnAroundTimeHandler.creatResourcingStatusTat(trigger.newMap, null);
                }
            }
        }
        else if(Trigger.isUpdate){
            if(Trigger.isBefore){
                for (sirenum__Shift__c shft : trigger.new){
                    if (shft.sirenum__Contact__c  != trigger.oldMap.get(shft.Id).sirenum__Contact__c ){
                        shft.Triggering_Record_Log__c = 'Yes';                        
                    }
                }
                if(Trigger.isUpdate){
                    if(VisitHelper.updateCountryStateLocationFlag){
                        VisitHelper.updateCountryStateLocation(trigger.new, trigger.oldMap);    
                    }
                    if(ResourceNotActiveOnProjectHandler.visitNumberMandatoryFlag){
                        ResourceNotActiveOnProjectHandler.visitNumberMandatory(trigger.new);
                    }
                    if(ResourceNotActiveOnProjectHandler.changeNotifyResourceRequestFlag){
                        ResourceNotActiveOnProjectHandler.changeNotifyResourceRequest(trigger.newMap,trigger.oldMap);
                    } 
                    if(ResourceNotActiveOnProjectHandler.ErrorOnParentVisitDeclinedFlag){
                        ResourceNotActiveOnProjectHandler.ErrorOnParentVisitDeclined(trigger.new, trigger.oldMap);
                    }
                    if(ResourceNotActiveOnProjectHandler.recursiveCheck){
                        ResourceNotActiveOnProjectHandler.CheckActiveOnProject(trigger.new,trigger.newMap,Trigger.oldMap);
                    } 
                    if(ResourceNotActiveOnProjectHandler.ErrorOnSiteChangeForChildFlag){
                        ResourceNotActiveOnProjectHandler.ErrorOnSiteChangeForChild(trigger.new, trigger.oldMap);
                    } 
                    if( VisitHelper.checkValidSiteActivationTicketFlag){
                        VisitHelper.checkValidSiteActivationTicket(trigger.new);
                    }
                    if(TurnAroundTimeHandler.tatFlag){
                        TurnAroundTimeHandler.creatResourcingStatusTat(trigger.newMap, trigger.oldMap);
                    }
                    ResourceNotActiveOnProjectHandler.checkResourceAcceptanceChanges(trigger.newMap, trigger.oldMap);
                }
            }
            if(Trigger.isAfter){
                if(VisitHelper.fillRateCalculationFlag){
                    VisitHelper.fillRateCalculation(trigger.new, trigger.oldMap);    
                }
                if(ResourceNotActiveOnProjectHandler.checkVisitChildRecordFlag){
                    ResourceNotActiveOnProjectHandler.checkVisitChildRecord(trigger.new,Trigger.oldMap);
                }
                if(ResourceNotActiveOnProjectHandler.createNewPlacementRecordFlag){
                    ResourceNotActiveOnProjectHandler.createNewPlacementRecord(trigger.new,Trigger.oldMap);
                }
                if(ResourceNotActiveOnProjectHandler.updatePolicyAppliedOnVisitFlag){
                    ResourceNotActiveOnProjectHandler.updatePolicyAppliedOnVisit(trigger.newMap,Trigger.oldMap);
                }
                if(ResourceNotActiveOnProjectHandler.updateStartDateForProjectPlacementFlag){
                    ResourceNotActiveOnProjectHandler.updateStartDateForProjectPlacement(trigger.newMap, trigger.oldMap);
                }
                if(ResourceNotActiveOnProjectHandler.updateStartDateForSitePlacementFlag){
                    ResourceNotActiveOnProjectHandler.updateStartDateForSitePlacement(trigger.newMap, trigger.oldMap);
                }
                if(ResourceNotActiveOnProjectHandler.createSiteActivationTicketFlag){
                    ResourceNotActiveOnProjectHandler.createSiteActivationTicket(trigger.newMap,Trigger.oldMap);
                }
            }
        }
        else if(Trigger.isDelete){
            if(Trigger.isBefore){
                if(VisitHelper.changeAssignedVisitOnParentFlag){
                    VisitHelper.changeAssignedVisitOnParent(Trigger.old);
                }
                if(ResourceNotActiveOnProjectHandler.deleteVisitRecordFlag){
                    ResourceNotActiveOnProjectHandler.deleteVisitRecord(Trigger.old);
                }
            }
            if(Trigger.isAfter){
            }
        }
    }
}