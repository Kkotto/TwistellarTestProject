import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Id from "@salesforce/user/Id";
import getUserCases from "@salesforce/apex/ServiceCaseQueueService.getUserCases";

export default class ServiceCaseQueueFiltered extends NavigationMixin(
  LightningElement
) {
  // Get id of current user
  userId = Id;

  // Get all cases owned by current user
  @wire(getUserCases, { userId: "$userId" })
  caseList = [];

  openCaseRecord(event) {
    const caseId = event.currentTarget.dataset.id;
    console.log(caseId);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: caseId,
        actionName: "view"
      }
    });
  }
}
