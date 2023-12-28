import { LightningElement, wire } from "lwc";
import Id from "@salesforce/user/Id";
import getUserCases from "@salesforce/apex/ServiceCaseQueueService.getUserCases";

export default class ServiceCaseQueueFiltered extends LightningElement {
  // Get id of current user
  userId = Id;

  // Get all cases owned by current user
  @wire(getUserCases, { userId: "$userId" })
  caseList = [];
}
