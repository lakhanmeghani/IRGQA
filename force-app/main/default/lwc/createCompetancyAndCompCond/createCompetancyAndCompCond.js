import { LightningElement ,track,api} from 'lwc';
import getRelatedSites from '@salesforce/apex/ProjectLookupController.getRelatedSites';
import createCompetency from '@salesforce/apex/ProjectLookupController.createCompetency';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';



export default class CreateCompetancyAndCompCond extends LightningElement {
    @api isProcessing = false;
    @track selectedCategoryValue = '';
    @track selectedCountry=[];
    //@track selectedSite=[];
    @api projectSelectedRecord;
    @api countryList=[];
    @api relatedSiteValues;
    uniqueCountrySet;
    @api isProjectSelected=false;
    @api isCountrySelected=false;
    @api siteListForSelection=[];
    @api isChecked=false;
    @api selectedSiteList=[];
    @api inputName='';
    @api inputSearchableName=''; 
		@api courseTitle='';
    @api message=''; 
		 @api selectedSeverityValue='';
    uniqueSiteArray=[];   
    picklistOptions = [
        { label: 'Project Training', value: 'ProjectTraining' },
        { label: 'Project-Site Training', value: 'ProjectSiteTraining' }
       
    ];
		picklistSeverityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' },
        { label: 'Fatal', value: 'Fatal' }
       
    ];

    connectedCallback(){
        try {
        console.log('connectedCallback');
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 3;
        toastContainer.toastPosition = 'top-center';
        
        }
        catch (error) {
            console.error(error);
        }
    }
		
    handlePicklistChange(event) {
        this.selectedCategoryValue = event.target.value;
        //console.log(this.selectedCategoryValue);
        if(this.selectedCategoryValue==='ProjectTraining'){
            this.isProjectSelected=false;
            this.isCountrySelected=false;
            
        }
        
    }
		handleSeverityPicklistChange(event) {
        this.selectedSeverityValue = event.target.value;
   
    }
    handleNameChange(event){
				console.log('inside handle NAme')
        if(event.target.name=='CompName'){
        this.inputName=event.target.value;
        }
        else if (event.target.name=='SearchableName'){
						console.log('inseide name');
        this.inputSearchableName=event.target.value;
        }
				else if(event.target.name=='CourseTitle'){
						console.log('inseide course');
						console.log('this.courseTitle>>>'+event.target.value);
            this.courseTitle=event.target.value;
        }
        //console.log('inputName>>>'+this.inputName);
    }
    handleValueSelectedOnAccount(event) {
        this.projectSelectedRecord = event.detail;
        console.log(JSON.stringify(this.projectSelectedRecord))
        if(this.selectedCategoryValue==='ProjectSiteTraining' && this.projectSelectedRecord!=null){
            this.getRelatedSites();
            }
    }
    
    getRelatedSites(){
        
        getRelatedSites({selectedProject: this.projectSelectedRecord})
        .then(result => {
            console.log(result);
            this.relatedSiteValues=result;
            //console.log("-------------"+this.relatedSiteValues);
            this.relatedSiteValues.forEach(item => {
                this.countryList.push(item.IllingworthCountry__c);
                
            });
            console.log('countryList>>>'+this.countryList)
            this.uniqueCountrySet = new Set(this.countryList);
            if(this.countryList.length>0){
            this.isProjectSelected=true;
            }
            else{
                alert('No Sites');
            }
        })
        .catch(error => {
            //show error message
            console.log('error.body.message=' + error.body);
            
        });
        }
        get picklistOptionsForCountry() {
            let uniqueCountryArray=[];
            console.log('inside picklistOptionsForCountry');
            
            uniqueCountryArray = [...this.uniqueCountrySet].map(item => ({ label: item, value: item }));
            
        
            return uniqueCountryArray;
        }
        handleCountryPicklistChange(event) {
            console.log('inside handleCountryPicklistChange');
            this.selectedCountry = event.detail.value;
            
            if(this.selectedCountry.length>0){
                this.isCountrySelected=true;
            }
            else{
                this.isCountrySelected=false;
            }
        }
        get picklistOptionsForSite(){
            //const uniqueSiteArray=[];
            console.log('inside picklistOptionsForSite');
            if (typeof this.selectedCountry !== 'string') {
                this.selectedCountry = this.selectedCountry.toString();
            }
            
            const selectedCountriesConst = this.selectedCountry.split(",");
            console.log('selectedCountriesConst>>>>'+selectedCountriesConst);
            const filteredSites = this.relatedSiteValues.filter(site => selectedCountriesConst.includes(site.IllingworthCountry__c));
            console.log('filteredSites>>>>'+JSON.stringify(filteredSites));
            this.uniqueSiteArray = [...filteredSites].map(item => ({ label: item.Name, value: item.Id}));
           console.log('uniqueSiteArray>>>>'+JSON.stringify(this.uniqueSiteArray));
            
            return this.uniqueSiteArray ;
        }
        handleSitePicklistChange(event) {
            console.log('inside handleSitePicklistChange');
            let selectedSite=[];
            selectedSite=event.detail.value;
            console.log('event in site>>'+JSON.stringify(event.detail));
            //console.log('eventLabel in site>>'+JSON.stringify(event.detail.label));
            console.log('event site>>'+JSON.stringify(event.target));
            this.selectedSiteList= selectedSite;
            
        }
        handleCheckboxChange(event) {
            console.log('inside handleCheckboxChange');
            const createCompCondCheckbox=event.target.checked;
            this.isChecked = createCompCondCheckbox
           
        }
        handleButtonClick(event) {
            const buttonClicked=event.target.name;
            console.log("buttonClicked>>>"+buttonClicked);
            this.isProcessing=true;
            
            const siteMap = new Map();
            
            if(buttonClicked!='cancel' && this.inputSearchableName!='' && this.projectSelectedRecord!='' && this.inputName!='' && this.selectedSeverityValue){
              
            if(this.selectedSiteList.length>0){ 
                          
            this.selectedSiteList.forEach(selectedValue => {
                // Find the matching site in uniqueSiteArray
                const matchingSite = this.uniqueSiteArray.find(site => site.value === selectedValue);
               
                // If a site is found, set the key-value pair in the Map
                if (matchingSite) {
                    siteMap[selectedValue] = matchingSite.label;
                  }
                
            });
        }
            createCompetency({selectedProject: this.projectSelectedRecord,isChecked: this.isChecked,siteMap: siteMap,selectedCategoryValue: this.selectedCategoryValue,compName:this.inputName,searchableName:this.inputSearchableName,courseTitle:this.courseTitle,severity:this.selectedSeverityValue})
                .then(result => {
                    console.log(result);
                    this.isProcessing=false;
                    
                    if(result.message=='Success' && result.messageCompCond==undefined)
                    {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!',
                                message: 'Competency Record(s) created successfully.',
                                variant: 'success'
                            }),
                        );
                        this.resetValues();
												const objChild = this.template.querySelector('c-project-lookup');
                        objChild.handleCommit(); 
                        console.log('buttonClicked>>>>'+buttonClicked);
                        if(buttonClicked==='save'){ 
                            window.location.assign(result.compLink);  
                        } 
                        
                    }
                    else if(result.message=='Success' && result.messageCompCond=='Success')
                    {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!',
                                message: 'Competency And Competency Condition Record(s) created successfully.',
                                variant: 'success'
                            }),
                        );
                        this.resetValues();
												const objChild = this.template.querySelector('c-project-lookup');
                        objChild.handleCommit(); 
                            
                        if(buttonClicked==='save'){ 
                            window.location.assign(result.compLink);  
                        }
                        
                    }
                    else if(result.message.includes('Failed')){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'An error occurred while creating the record(s): '+result.message ,
                                variant: 'error'
                            }),
                        );
                    }
                    //this.projectSelectedRecord='';
                    
                    
                    
                   
                    
                })
                .catch(error => {
                    //show error message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while creating the record(s): ',
                            variant: 'error'
                        }),
                    );
                    console.log('error.body.message=' + JSON.stringify(error));
                    
                });
            }
						else if(buttonClicked==='cancel'){ 
                console.log('Inside cancel');
                history.back();
                //window.location.assign(result.cancelLink);  
            } 
            else {
               
                this.isProcessing=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Fill Required Field ',
                        variant: 'error'
                    }),
                );
    
            } 
            
        }
        resetValues() {
            this.selectedCategoryValue = '';
            this.selectedSeverityValue='';
            this.inputName='' ;
            this.inputSearchableName='' ;
            this.isProjectSelected=false;
            this.isCountrySelected=false;
            this.isChecked='';
            
            
            // Reset to empty value
        }
        
}