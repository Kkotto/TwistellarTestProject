public inherited sharing class ServiceCaseQueueService {
  private static final Integer LIMIT_VALUE = 25;
  private static final String QUEUE_TYPE_VALUE = 'Queue';
  private static final String UPDATED_RECORD_SUCCESS_RESPONSE = 'Record updated successfully';
  private static final String UPDATED_RECORD_FAILURE_RESPONSE = 'The following exception has occurred: ';

  @AuraEnabled(cacheable=true)
  public static List<Case> getUserCases(Id userId) {
    try {
      Set<Id> userIdSet = findQueueOwnerId(userId);
      userIdSet.add(userId);
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
    List<GroupMember> groupMembers = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :userId];
    Set<Id> groupIds = new Set<Id>();
    for (GroupMember member : groupMembers) {
        groupIds.add(member.GroupId);
    }
    List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = :QUEUE_TYPE_VALUE AND Id IN :groupIds];
    Set<Id> queueIds = new Set<Id>();
    for (Group queue : queues) {
        queueIds.add(queue.Id);
    }
    return queueIds;
  }

  @AuraEnabled
  public static String updateCase(String caseId, String updatedStatus) {
    try {
      Case oldCase = [SELECT Id, Status FROM CASE WHERE Id = :caseId LIMIT 1];
      oldCase.status = updatedStatus;
      update oldCase;
      return UPDATED_RECORD_SUCCESS_RESPONSE;
    } catch (Exception e) {
      return UPDATED_RECORD_FAILURE_RESPONSE + e.getMessage();
    }
  }
}