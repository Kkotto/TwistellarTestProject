import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import Id from "@salesforce/user/Id";
import CASE_OBJECT from "@salesforce/schema/Case";
import CASE_STATUS_FIELD from "@salesforce/schema/Case.Status";
import getUserCases from "@salesforce/apex/ServiceCaseQueueService.getUserCases";

export default class ServiceCaseQueueFiltered extends NavigationMixin(
  LightningElement
) {
  // Get id of current user
  userId = Id;

  // Get all cases owned by current user
  @wire(getUserCases, { userId: "$userId" })
  caseList = [];

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  wiredCaseObjectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$wiredCaseObjectInfo.data.defaultRecordTypeId",
    fieldApiName: CASE_STATUS_FIELD
  })
  wiredCaseStatusOptions;

  get caseStatusOptions() {
    console.log(this.wiredCaseStatusOptions.data.values)
    return this.wiredCaseStatusOptions.data.values.map(option => ({
      label: option.label,
      value: option.value
    }));
  }

  openCaseRecord(event) {
    const caseId = event.currentTarget.dataset.id;
    console.log(caseId);
    console.log(this.wiredCaseStatusOptions.data.values);
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: caseId,
        actionName: "view"
      }
    });
  }
}
