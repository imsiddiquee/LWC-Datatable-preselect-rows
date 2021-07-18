import { LightningElement } from "lwc";

import { NavigationMixin } from "lightning/navigation";

export default class PdfFilePreview extends NavigationMixin(LightningElement) {
  contentDocumentId = "0695g000000ZUX3AAO";

  /**
   * Try the following method, it will work lightning pages but it won't work in communities.
   *  For communities you need to use standard__recordPage as standard_namedPage won't work.
   *
   */
  filePreview(event) {
    // Naviagation Service to the show preview
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview",
        actionName: "view"
      },
      state: {
        // assigning ContentDocumentId to show the preview of file
        selectedRecordId: this.contentDocumentId
      }
    });
  }
}
