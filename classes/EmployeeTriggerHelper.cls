public with sharing class EmployeeTriggerHelper {
    
    public static void OnAfterInsertUpdateCheckUniqueEmployee(List<Employee__c> employees){
        List<String> firstNames = new List<String>();
         List<String> lastNames = new List<String>();
         List<Date> birthdays = new List<Date>();
         
         for (Employee__c insertItem : employees) {
             firstNames.add(insertItem.First_Name__c);
             lastNames.add(insertItem.Last_Name__c);
             birthdays.add(insertItem.Birthday__c);
         }
         
         List<Employee__c>  resDublicat = [
                      SELECT First_Name__c, Last_Name__c, Birthday__c
                      FROM Employee__c 
                      WHERE First_Name__c IN :firstNames AND
                      		Last_Name__c IN :lastNames AND 
                      		Birthday__c IN :birthdays  
         			];
         
         for (Employee__c insertItem : employees) {
             for(Employee__c errorItem : resDublicat){
                 if(
                     insertItem.First_Name__c == errorItem.First_Name__c && 
                     insertItem.Last_Name__c == errorItem.Last_Name__c && 
                     insertItem.Birthday__c == errorItem.Birthday__c &&
                     insertItem.Id != errorItem.Id
                 ){
                     insertItem.addError('adding a record is not possible. An employee with such data already exists');
                     break;
                 }
             }
         }
    }
    
    //task_4 count dev's, qa's
    public static void OnAfterUpdateActiveDepartmentFields(List<Employee__c> employeesNew, List<Employee__c> employeesOld){
        //check if isset projects
        AggregateResult isProjectExist = [SELECT COUNT(Id) countProject  FROM Project__c];
        
        if((Integer)isProjectExist.get('countProject')>0){
            //create item helper class for inicialization infoMap(key - id project and info - count dev's and qa's)
            DevQaFieldsService.Info itemSeviceClass = new DevQaFieldsService.Info();
            
            //consider changes
            for(Integer i = 0, size = employeesNew.size(); i<size; i++){
             
                //check whether the field  employee  has changed Active/Department - filter employee
                DevQaFieldsService.Info resFilterEmpl = EmployeeTriggerService.filterEmployee(employeesOld[i], employeesNew[i]);

                //if change - fill map changes
                if( resFilterEmpl.changeQa != 0 || resFilterEmpl.changeDev != 0){
                    //pull out the projects of the employee
                    List<AggregateResult> lsProjectsOfEmpl = [
                        SELECT  Project__c FROM EmployeeSkills__c WHERE  Employee__c  =: employeesOld[i].Id GROUP BY Project__c
                    ]; 
                    
                    for(AggregateResult prt : lsProjectsOfEmpl){
                       Id idProject = (Id) prt.get('Project__c');
                        //add to map
                       itemSeviceClass.addRecordToMap(idProject, resFilterEmpl);
                    } 
                }       
            }

            //create list of projects for update
            List<Project__c> updProjectList = DevQaFieldsService.getListProjectsToUbdate(itemSeviceClass.infoMap, true);
            //update all the affected projects
            update updProjectList;
        }
    }  
}