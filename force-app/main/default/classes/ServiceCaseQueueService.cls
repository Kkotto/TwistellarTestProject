public inherited sharing class ServiceCaseQueueService {
  private static final Integer LIMIT_VALUE = 25;
  private static final String QUEUE_TYPE_VALUE = 'Queue';
  private static final String CASE_TYPE_VALUE = 'Case';

  @AuraEnabled(cacheable=true)
  public static List<Case> getUserCases(String userId) {
    try {
      // Find all owner ids of assosiated queues
      Set<Id> userIdSet = findQueueOwnerId(userId);
      // Don't forget to add user id itself
      userIdSet.add(userId);
      // Queues and cases were combined into one query due to task's limitations
      return findAllCasesAndQueues(userIdSet);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static List<Case> findAllCasesAndQueues(Set<Id> userIdList) {
    return [
      SELECT Id, CaseNumber, Owner.Name, Status, Priority, Origin, CreatedDate
      FROM Case
      WHERE OwnerId IN :userIdList
      ORDER BY Owner_Priority__c ASC, Priority_Order__c DESC, CreatedDate DESC
      LIMIT :LIMIT_VALUE
    ];
  }

  private static Set<Id> findQueueOwnerId(String userId) {
    // Find a group of current user (from group member by user's id)
    Set<Id> groupIdOfCurrentUser = new Set<Id>();
    for (GroupMember gm : [
      SELECT GroupId
      FROM GroupMember
      WHERE UserOrGroupId = :userId
    ]) {
      groupIdOfCurrentUser.add(gm.GroupId);
    }
    // Restrict a group to be a queue only
    Set<Id> groupIdOfQueue = new Set<Id>();
    for (Group gr : [
      SELECT Id
      FROM Group
      WHERE Type = :QUEUE_TYPE_VALUE AND Id IN :groupIdOfCurrentUser
    ]) {
      groupIdOfQueue.add(gr.Id);
    }
    // Restrict queues to find only case type
    Set<Id> queueIdOfCase = new Set<Id>();
    for (QueueSObject qso : [
      SELECT QueueId
      FROM QueueSObject
      WHERE SObjectType = :CASE_TYPE_VALUE AND QueueId IN :groupIdOfQueue
    ]) {
      queueIdOfCase.add(qso.QueueId);
    }
    return queueIdOfCase;
  }

  @AuraEnabled(cacheable=true)
  public static void updateRecord(Case updatedCase) {
    Database.update(updatedCase);
  }
}