import { LightningElement, wire } from "lwc";
import Id from "@salesforce/user/Id";
import getUserCases from "@salesforce/apex/ServiceCaseQueueService.getUserCases";

const columns = [
  {
    label: "Id",
    fieldName: "Id",
    type: "text"
  },
  {
    label: "Case Number",
    fieldName: "CaseNumber",
    type: "text"
  },
  {
    label: "Asignee",
    fieldName: "OwnerId",
    type: "text"
  },
  {
    label: "Case Status",
    fieldName: "Status",
    type: "text"
  },
  {
    label: "Priority",
    fieldName: "Priority",
    type: "text"
  },
  {
    label: "Origin",
    fieldName: "Origin",
    type: "text"
  }
];

export default class ServiceCaseQueueFiltered extends LightningElement {
  // Get id of current user
  userId = Id;
  columns = columns;

  // Get all cases owned by current user
  @wire(getUserCases, { userId: "$userId" })
  caseList = [];
}
