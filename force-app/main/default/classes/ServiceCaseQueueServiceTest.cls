@isTest
public class ServiceCaseQueueServiceTest {
    @testSetup
    public static void prepareUser() {
        Blob b = Crypto.GenerateAESKey(128);
      	String h = EncodingUtil.ConvertTohex(b);
      	String uid = h.SubString(0,8);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      	User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='KSHTesting', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com');
        insert u;
    }
    
    @isTest
    public static void getUserCases_NewUserWithCasesTest(){
		User u = [SELECT Id FROM User WHERE LastName = 'KSHTesting'];        
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i < 5; i++) {
            Case nextCase = new Case();
            nextCase.Status = 'New';
            nextCase.Origin = 'Phone';
            nextCase.OwnerId = u.Id;
            caseList.add(nextCase);
        }
        
        insert caseList;
        
        Test.startTest();
        List<Case> resultList = ServiceCaseQueueService.getUserCases(u.Id);
        Test.stopTest();
        
        System.assertEquals(5, resultList.size());
    }
    
    @isTest
    public static void getUserCases_NewUserWithoutCasesTest(){
		User u = [SELECT Id FROM User WHERE LastName = 'KSHTesting'];        
        
        Test.startTest();
        List<Case> resultList = ServiceCaseQueueService.getUserCases(u.Id);
        Test.stopTest();
        
        System.assertEquals(0, resultList.size());
    }
    
    @isTest
    public static void updateCase_ExistingCaseNewStatusTest() {
        Case c = new Case(Status = 'New', Origin = 'Phone');
        insert c;
        
        final String UPDATED_RECORD_SUCCESS_RESPONSE = 'Record updated successfully';
        Test.startTest();
        String result = ServiceCaseQueueService.updateCase(c.Id, 'Closed');
        Test.stopTest();
        
        System.assertEquals(UPDATED_RECORD_SUCCESS_RESPONSE, result);
    }
    
    @isTest
    public static void updateCase_ExistingCaseSameStatusTest() {
        Case c = new Case(Status = 'New', Origin = 'Phone');
        insert c;
        
        final String UPDATED_RECORD_SUCCESS_RESPONSE = 'Record updated successfully';
        Test.startTest();
        String result = ServiceCaseQueueService.updateCase(c.Id, 'New');
        Test.stopTest();
        
        System.assertEquals(UPDATED_RECORD_SUCCESS_RESPONSE, result);
    }
    
    @isTest
    public static void updateCase_ExistingCaseRandomStatusTest() {
        Case c = new Case(Status = 'New', Origin = 'Phone');
        insert c;
        
        final String UPDATED_RECORD_SUCCESS_RESPONSE = 'Record updated successfully';
        Test.startTest();
        String result = ServiceCaseQueueService.updateCase(c.Id, 'Random');
        Test.stopTest();
        
        System.assertEquals(UPDATED_RECORD_SUCCESS_RESPONSE, result);
    }
    
    @isTest
    public static void updateCase_NotExistingCaseTest() {
        Case c = new Case(Status = 'New', Origin = 'Phone');
        insert c;
        Id oldId = c.Id;
        delete c;
        
        final String UPDATED_RECORD_FAILURE_RESPONSE = 'The following exception has occurred: ';
        Test.startTest();
        String result = ServiceCaseQueueService.updateCase(oldId, 'Closed');
        Test.stopTest();
        
        System.assertEquals(true, result.contains(UPDATED_RECORD_FAILURE_RESPONSE));
    }
}