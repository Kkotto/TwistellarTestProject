import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import {
  getObjectInfo,
  getPicklistValues,
  notifyRecordUpdateAvailable
} from "lightning/uiObjectInfoApi";
import Id from "@salesforce/user/Id";
import CASE_OBJECT from "@salesforce/schema/Case";
import CASE_STATUS_FIELD from "@salesforce/schema/Case.Status";
import getUserCases from "@salesforce/apex/ServiceCaseQueueService.getUserCases";
import updateRecord from "@salesforce/apex/ServiceCaseQueueService.updateRecord";

export default class ServiceCaseQueueFiltered extends NavigationMixin(
  LightningElement
) {
  // Get id of current user
  userId = Id;
  // For spinner
  isLoading = false;

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
    if (this.wiredCaseStatusOptions.data) {
      return this.wiredCaseStatusOptions.data.values.map((option) => ({
        label: option.label,
        value: option.value
      }));
    }
    return [];
  }

  openCaseRecord(event) {
    const caseId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: caseId,
        actionName: "view"
      }
    });
  }

  async refreshData(event) {
    this.isLoading = true;
    if (event.currentTarget.dataset.id) {
      //
      await updateRecord(
        array.find((record) => record.id === event.currentTarget.dataset.id)
      );
      await notifyRecordUpdateAvailable([
        { recordId: event.currentTarget.dataset.id }
      ]);
    }
    this.isLoading = false;
  }
}
