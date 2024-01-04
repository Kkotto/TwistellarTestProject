@isTest
public class AccountCasesPdfCtrlTest {
    @isTest(SeeAllData=true)
    public static void getAccountCasesPrevWeekTest() {
        Test.startTest();
        List<Case> result = new AccountCasesPdfCtrl().getAccountCasesPrevWeek();
        Test.stopTest();
        
        Assert.isNotNull(result);
        Assert.isTrue(result.get(0).CreatedDate < Date.today());
        Assert.IsTrue(result.get(0).CreatedDate > Date.today() - 14);
    }
}