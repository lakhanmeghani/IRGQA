/**
 * Copyright (c) Sirenum by Bullhorn 2023
 * PS-929 Custom Scorer
 *
 * Initial State template:
 * {
 * "differentStateOrCountryDetriment": 10
 * }
 *
 */

@JsonAccess(Serializable='always' Deserializable='always')
global with sharing class CountryAndStateScorer implements sirenum.WorkerSearchScorer {

    // The amount of points to deduct if the conditions are not met. Expressed as a negative decimal.
    private Decimal differentStateOrCountryDetriment;

    global Set<String> getRequiredShiftFields() {
        return new Set<String>{
                'Effective_Required_Country__c',
                'Effective_Required_State__c'
        };
    }

    global Set<String> getRequiredWorkerFields() {
        return new Set<String>{
                'Work_Country__c',
                'Illing_Licenced_in_States_Province__c'
        };
    }

    global List<sirenum.WorkerSearchScore> scoreWorkers(sirenum.WorkerSearchScorerContext context) {
        List<sirenum.WorkerSearchScore> scores = new List<sirenum.WorkerSearchScore>();

        //Set a default detriment if it has not been defined, or check negativity if defined
        this.differentStateOrCountryDetriment = this.differentStateOrCountryDetriment == null ?
                -10 :
                this.differentStateOrCountryDetriment <= 0 ?
                    this.differentStateOrCountryDetriment :
                    -1* this.differentStateOrCountryDetriment;

        Set<String> effectiveCountries = new Set<String>();
        Set<String> effectiveStates = new Set<String>();

        //Since formula values are not retrieved OOTB, get them now for use in scoring
        List<sirenum__Shift__c> shifts = [
                SELECT Id, Effective_Required_Country__c, Effective_Required_State__c
                FROM sirenum__Shift__c
                WHERE Id IN :context.getOriginatingShiftIds()
        ];

        //Loop shifts, tracking the Countries and States to check workers against
        for (sirenum__Shift__c shift : shifts){
            if(shift.Effective_Required_Country__c != null)
            effectiveCountries.add(shift.Effective_Required_Country__c);
            if(shift.Effective_Required_State__c != null)
            effectiveStates.add(shift.Effective_Required_State__c);
        }

        for (Contact contact : context.getWorkersById().values()){
            Boolean contactBreachedRule = false; // If true, contact has broken 1 or more rules, stop processing contact

            //Check Country
            system.debug('effectiveCountries '+effectiveCountries);
            for (String country : effectiveCountries){
                system.debug('contact.Work_Country__c '+contact.Work_Country__c);
                system.debug('country '+country);
                if (!contact.Work_Country__c.contains(country)){
                    contactBreachedRule = true;
                    break;
                }
            }

            //If no error yet, check State
            if (contactBreachedRule == false){
                system.debug('effectiveStates '+effectiveStates);
                for (String state : effectiveStates){
                    system.debug('contact.Illing_Licenced_in_States_Province__c '+contact.Illing_Licenced_in_States_Province__c);
                    system.debug('state '+state);
                    if (!contact.Illing_Licenced_in_States_Province__c.contains(state)){
                        contactBreachedRule = true;
                        break;
                    }
                }
            }

            //If error after both checks considered, create WSS
            if (contactBreachedRule == true) {
                scores.add(new sirenum.WorkerSearchScore()
                        .withWorkerId(contact.Id)
                        .withScore(this.differentStateOrCountryDetriment)
                        .withDescription(Label.ContactDifferentStateOrCountryString)
                );
            }
        }

        return scores;
    }
}