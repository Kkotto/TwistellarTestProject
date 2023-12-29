public inherited sharing class ServiceCaseQueueService {
  @AuraEnabled(cacheable=true)
  public static List<Case> getUserCases(String userId) {
    try {
      // List for all both cases and queues
      List<Case> allCases = new List<Case>();
      // List for cases
      List<Case> userCases = getAllUserCases(userId);
      // List for case queues
      //List<Case> userQueues = getAllUserQueueCases(userId);
      List<Case> userQueues = [
        SELECT Id, CaseNumber, OwnerId, Status, Priority, Origin, CreatedDate
        FROM Case
        WHERE Owner.Type = 'Queue'
      ];
      // Merge results
      allCases.addAll(userCases);
      allCases.addAll(userQueues);
      return allCases;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static List<Case> getAllUserCases(String userId) {
    return [
      SELECT Id, CaseNumber, OwnerId, Status, Priority, Origin, CreatedDate
      FROM Case
      WHERE OwnerId = :userId
      ORDER BY OwnerId, Priority DESC, CreatedDate DESC
    ];
  }

  private static List<Case> getAllUserQueueCases(String userId) {
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
      WHERE Type = 'Queue' AND Id IN :groupIdOfCurrentUser
    ]) {
      groupIdOfQueue.add(gr.Id);
    }
    // Restrict queues to find only case type
    Set<Id> queueIdOfCase = new Set<Id>();
    for (QueueSObject qso : [
      SELECT QueueId
      FROM QueueSObject
      WHERE SObjectType = 'Case' AND QueueId IN :groupIdOfQueue
    ]) {
      queueIdOfCase.add(qso.QueueId);
    }
    // Restrict cases to find only queues with user assosiation
    return [
      SELECT Id, CaseNumber, OwnerId, Status, Priority, Origin, CreatedDate
      FROM Case
      WHERE Owner.Type = 'Queue' AND OwnerId IN :queueIdOfCase
    ];
  }
}
