public with sharing class EmployeeTriggerService {
   
	public static void OnAfterInsertUpdate(List<Employee__c> employees){
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
    public static void OnAfterUpdateActiveDepartmentFieldsServ(List<Employee__c> employeesNew, List<Employee__c> employeesOld){
      
        List<AggregateResult> projects = [SELECT Project__c FROM EmployeeSkills__c  GROUP BY Project__c];
      //System.debug(projects)  ;
        
         if(projects.size()>0){
             Map<Id, Info> mapInfo = new Map<Id, Info>();
             
             for(Employee__c empl : employeesOld){
                 //вытаскиваем проекты рабочего
                 List<AggregateResult> lsProjectsOfEmpl = [
                     SELECT  Project__c FROM EmployeeSkills__c WHERE  Employee__c  =: empl.Id GROUP BY Project__c
                 ];
				//System.debug(lsProjectsOfEmpl)  ;	                 
                 
                 Integer Qa = 0;
                 Integer Dev = 0;
                 //Boolean  flag;
                 for(Integer i = 0, size = employeesNew.size(); i<size; i++){
                     if(employeesOld[i].isActive__c == False && employeesNew[i].isActive__c == True){
                         if(employeesNew[i].IT_Department__c == 'QA'){
                             Qa++; 
                         }else if(employeesNew[i].IT_Department__c == 'DEV'){
                             Dev++; 
                         }
                     }
                     if(employeesOld[i].isActive__c == True && employeesNew[i].isActive__c == False){
                          if(employeesOld[i].IT_Department__c == 'QA'){
                             Qa--; 
                         }else if(employeesOld[i].IT_Department__c == 'DEV'){
                             Dev--; 
                         }
                     }
                     if(employeesOld[i].isActive__c == True && employeesNew[i].isActive__c == True){
                         
                         if(employeesNew[i].IT_Department__c ==  'QA' && employeesOld[i].IT_Department__c !=  'QA'){
                             Qa++; 
                         }
                         if(employeesNew[i].IT_Department__c ==  'DEV' && employeesOld[i].IT_Department__c !=  'DEV'){
                             Dev++; 
                         }
                         if(employeesOld[i].IT_Department__c ==  'QA' && employeesNew[i].IT_Department__c !=  'QA' ){
                             Qa--;
                         }
                         if(employeesOld[i].IT_Department__c ==  'DEV' && employeesNew[i].IT_Department__c !=  'DEV' ){
                             Dev--; 
                         }
                     }
                 }
                 //System.debug('QA='+Qa) ;	
                 //System.debug('Dev='+Dev) ;	
                 
                 
                 if(Qa != 0 || Dev !=0){
                     for(AggregateResult prt : lsProjectsOfEmpl){
                         Id idProject = (Id) prt.get('Project__c');
                         Info inf = mapInfo.get(idProject);
                         if(inf != null){
                             inf.changeQa += Qa;
                             inf.changeDev += Dev;
                         }else{
                             mapInfo.put(idProject, new Info(Qa,Dev));
                         }
                     }
                     
                 }
				//System.debug(mapInfo);                
             }
             
             List<Project__c> updProjectList = new 	List<Project__c>();
             Set<Id> idList= mapInfo.keySet();
             for(Id i: idList){
                 Info infoProject = mapInfo.get(i);
                 Project__c p = [SELECT QA_s__c, Developers__c FROM Project__c WHERE Id =: i];
                 p.QA_s__c += infoProject.changeQa;
                 p.Developers__c += infoProject.changeDev;
                 updProjectList.add(p);
             }
             
             update updProjectList;
         }  

    }
    
    public class Info{
        Integer changeQa{
            get{
                return changeQa == null? 0 : changeQa;
            }
            set;
        }
        Integer changeDev{
            get{
                return changeDev == null? 0 : changeDev;
            }
            set;
        }
        
        public Info(Integer q, Integer d){
            changeQa = q;
            changeDev = d;
        }
        
    }
}