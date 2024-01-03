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
    public static void getUserCasesNewUserWithCasesTest(){
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
}