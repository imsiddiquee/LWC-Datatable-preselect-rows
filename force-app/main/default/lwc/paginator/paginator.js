import { LightningElement, api } from "lwc";

export default class Paginator extends LightningElement {
  @api page = 1; //this will initialize 1st page
  @api totalPage = 0; //total number of page is needed to display all records
  previousHandler() {
    this.dispatchEvent(new CustomEvent("previous"));
  }

  get showPrevious() {
    return this.page === 1 ? false : true;
  }

  nextHandler() {
    this.dispatchEvent(new CustomEvent("next"));
  }

  get showNext() {
    return this.page === this.totalPage || this.totalPage === 0 ? false : true;
  }
}
