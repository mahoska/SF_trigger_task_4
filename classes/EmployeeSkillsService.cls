public with sharing class EmployeeSkillsService {

    public static void OnAfterInsertUpdate(List<EmployeeSkills__c> skills){
        
        for(EmployeeSkills__c item: skills){
            List<AggregateResult> res = [
                SELECT Employee__r.Id emId, SUM(Assigned_Time__c) assignedTime  
                FROM EmployeeSkills__c 
                WHERE Employee__r.Id =: item.Employee__c AND Id !=: item.Id
                GROUP BY Employee__r.Id
                LIMIT 1
            ];
            
            List<Employee__c> em = [SELECT Availability__c FROM Employee__c  WHERE Id =: item.Employee__c];
            
            if(
                (!res.isEmpty() && em[0].Availability__c < (Double)res[0].get('assignedTime') + item.Assigned_Time__c) ||
                (res.isEmpty() &&   em[0].Availability__c < item.Assigned_Time__c)
            ){
                item.addError('The number of hours(Assigned Times) exceeds hours(availability) of employee.');
            }
            
        }
    }
    
    //task_4 count dev's, qa's
     public static void OnAfterInsertDeleteChangeCountEmployees(List<EmployeeSkills__c> skills, Boolean isInsert){
         Map<Id, Info> mapInfo = new Map<Id, Info>();
         
         for(EmployeeSkills__c item: skills){
             Employee__c empl = [SELECT IT_Department__c, isActive__c FROM Employee__c  WHERE Id =: item.Employee__c LIMIT 1];
             
             Integer Qa = empl.IT_Department__c == 'QA' ? 1 :0 ;
             Integer Dev = empl.IT_Department__c == 'DEV' ? 1 : 0; 
             
             if(empl.isActive__c == True){
                 //if record this project exists
                 Info inf = mapInfo.get(item.Project__c);
                 if(inf != null){
                         inf.changeQa += Qa;
                         inf.changeDev += Dev;
                 }else{
                     mapInfo.put(item.Project__c, new Info(Qa,Dev));
                 } 
             }
         }
         
         List<Project__c> updProjectList = new 	List<Project__c>();
         Set<Id> idList= mapInfo.keySet();
         for(Id i: idList){
             Info infoProject = mapInfo.get(i);
             Project__c p = [SELECT QA_s__c, Developers__c FROM Project__c WHERE Id =: i];
             if(isInsert){
                 p.QA_s__c += infoProject.changeQa;
                 p.Developers__c += infoProject.changeDev;
             }else{
                 p.QA_s__c -= infoProject.changeQa;
                 p.Developers__c -= infoProject.changeDev;
             }
             updProjectList.add(p);
         }
         
         update updProjectList;
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