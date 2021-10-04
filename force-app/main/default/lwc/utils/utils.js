export function IsValidObjectData(dataSource) {
  if (!dataSource || !Object.keys(dataSource).length) {
    return false;
  }
  return true;
}

export function exportCSVFile(headers, totalData, fileTitle) {
  return processCSVFile(headers, totalData, fileTitle);
}

export function exportCSVFileWithDynamicHeader(totalData, fileTitle) {
  if (!totalData || !totalData.length) {
    return "Can not process with empty data source";
  }
  //prepare header
  const actualHeaderKey = Object.keys(totalData[0]);
  const headers = {};
  for (const key of actualHeaderKey) {
    headers[key] = key;
  }

  return processCSVFile(headers, totalData, fileTitle);
}

function processCSVFile(headers, totalData, fileTitle) {
  if (!totalData || !totalData.length) {
    return "Can not process with empty data source";
  }
  const jsonObject = JSON.stringify(totalData);
  const result = convertToCSV(jsonObject, headers);
  if (result === null) return "Invalid source data";

  const blob = new Blob([result]);
  const exportedFilename = fileTitle ? fileTitle + ".csv" : "export.csv";
  if (navigator.msSaveBlob) {
    navigator.msSaveBlob(blob, exportedFilename);
  } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
    const link = window.document.createElement("a");
    link.href = "data:text/csv;charset=utf-8," + encodeURI(result);
    link.target = "_blank";
    link.download = exportedFilename;
    link.click();
  } else {
    const link = document.createElement("a");
    if (link.download !== undefined) {
      const url = URL.createObjectURL(blob);
      link.setAttribute("href", url);
      link.setAttribute("download", exportedFilename);
      link.style.visibility = "hidden";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  }
  return "success";
}
function convertToCSV(objArray, headers) {
  console.log("headers", headers);
  const columnDelimiter = ",";
  const lineDelimiter = "\r\n";
  const actualHeaderKey = Object.keys(headers);
  const headerToShow = Object.values(headers);
  let str = "";
  str += headerToShow.join(columnDelimiter);
  str += lineDelimiter;
  const data = typeof objArray !== "object" ? JSON.parse(objArray) : objArray;

  data.forEach((obj) => {
    let line = "";
    actualHeaderKey.forEach((key) => {
      if (line !== "") {
        line += columnDelimiter;
      }
      let strItem = obj[key] + "";
      line += strItem ? strItem.replace(/,/g, "") : strItem;
    });
    str += line + lineDelimiter;
  });
  // console.log("str", str);
  return str;
}

export function csvToArray(str, delimiter = ",") {
  // slice from start of text to the first \n index
  // use split to create an array from string by delimiter

  let headers = str.slice(0, str.indexOf("\n")).split(delimiter);
  headers = headers.map((item) => item.trim());

  // slice from \n index + 1 to the end of the text
  // use split to create an array of each csv value row
  const rows = str.slice(str.indexOf("\n") + 1).split("\n");

  // Map the rows
  // split values from each row into an array
  // use headers.reduce to create an object
  // object properties derived from headers:values
  // the object passed as an element of the array
  let validData = [];
  let wrongData = [];
  const arr = rows.map(function (row) {
    let values = row.split(delimiter);
    values = values.map((item) => item.trim());
    const el = headers.reduce(function (object, header, index) {
      object[header] = values[index];
      return object;
    }, {});

    if (values.length !== headers.length) {
      wrongData.push(el);
    } else {
      validData.push(el);
    }

    return el;
  });

  // return the array
  return {
    columns: headers,
    alldata: arr,
    data: validData,
    wrongData: wrongData
  };
}
