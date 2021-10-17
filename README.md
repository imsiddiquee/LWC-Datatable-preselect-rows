# LWC: Datatable - way to programmatically handle preselect rows

![Component-internal-structure](https://github.com/imsiddiquee/LWC-Datatable-preselect-rows/blob/main/postContent/Final%20output.png)

## Let's try to understand together

* Create new components.
* Used @wire and imperative process to Load data.
* Helps to understand how to use @api for a parent-child component to configure data-table columns, data sources.
* Child component with an LWC: Datatable.
* Configure Parent component HTML Attribute to show/hide child component data-table checkbox.
* Configure Parent component HTML Attribute to show/hide child component data-table column border.
* From parent component how to select child component event.
* On the parent component how to select child component by tag and id. 

## Overview

Recently I am working on LWC: Datatable. I need to show large data in tabular format. Large data will not load at a time, so need to use pagination. The table also has flexibility, a user can select records as per need. The selected records can process for the next step.

So, need to persist all selected rows. After configuring/selecting a page record. The user may view other pages also he may back to his configured page, the page should exist configured records.

## Use case

The client has a requirement, want to see the retrieved records from the database in tabular view with pagination. There should have the functionality to preserve selected records.

## Solution Approach

We know lightning data-table easily helps us to show large data in tabular format, with a flexible selection approach.

When pagination applies with the LWC: Datatable pre-selected-rows, it does not work straightforward way. Because apply pagination helps to display only selected page information and hide the rest of the records actually they are not populated yet.

So when you want to know about the selected rows from the data table, it gives you results in only the current page information not persist the previous or next page configured selected records.

To resolve the selection issue, we need to store the selected records page-wise. 

When the user selects any page, the storage helps to populate his previous selected options. If he has done any new selection update. The system will also update the storage with the newly selected option.

## Flow diagram


![Component-internal-structure](https://github.com/imsiddiquee/LWC-Datatable-preselect-rows/blob/main/postContent/Demonstrate%20user%20selection%20persist%20and%20repopulation%20process..png)

## Final Outcome

![Component-internal-structure](https://github.com/imsiddiquee/LWC-Datatable-preselect-rows/blob/main/postContent/Demonstrate%20user%20selection%20persist%20and%20repopulation%20process..gif)

Finally, we are done, and thanks for reading!This process is implemented on the component **accountSyncWithOpportunity**.
