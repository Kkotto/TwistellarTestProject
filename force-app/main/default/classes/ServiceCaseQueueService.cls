public inherited sharing class ServiceCaseQueueService {
  @AuraEnabled(cacheable=true)
  public static List<Case> getUserCases(String userId) {
    try {
      return [
        SELECT Id, CaseNumber, OwnerId, Priority, CreatedDate
        FROM Case
        WHERE OwnerId = :userId
        ORDER BY OwnerId, Priority DESC, CreatedDate DESC
        LIMIT 25
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}