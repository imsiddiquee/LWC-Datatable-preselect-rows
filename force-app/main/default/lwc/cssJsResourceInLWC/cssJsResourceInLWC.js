import { LightningElement } from "lwc";

import rexourceContainer from "@salesforce/resourceUrl/cssJsStaticResource";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";

export default class CssJsResourceInLWC extends LightningElement {
  isResouceLoadComplete = false;

  /* generate the URL for the JavaScript, CSS and image file */
  chartjs = rexourceContainer + "/js/chart.js";
  utilJs = rexourceContainer + "/js/utils.js";
  styleCss = rexourceContainer + "/css/style.css";
  einsteinURL = rexourceContainer + "/image/einstein.png";
  astroURL = rexourceContainer + "/image/astro.png";
  codeyURL = rexourceContainer + "/image/codey.png";
  trailheadLWCURL = rexourceContainer + "/image/trailhead.png";

  renderedCallback() {
    /*eslint-disable */

    if (this.isResouceLoadComplete) {
      return;
    }
    this.isResouceLoadComplete = true;
    Promise.all([
      loadScript(this, this.utilJs),
      loadScript(this, this.chartjs),
      loadStyle(this, this.styleCss)
    ])
      .then(() => {
        this.generateSteppedChart();
      })
      .catch((error) => {
        this.error = error;
        console.log(" Error Occured ", error);
      });
  }

  errorCallback(error, stack) {
    this.error = error;
    console.log(" this.error ", this.error);
  }
}
