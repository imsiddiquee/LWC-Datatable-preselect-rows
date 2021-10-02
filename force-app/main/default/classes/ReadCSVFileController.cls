public with sharing class ReadCSVFileController {
  @AuraEnabled
  public static List<String> readCSV(String base64) {
    String myFile = EncodingUtil.base64Decode(base64).toString();
    List<String> csvFileLines = myFile.split('\n');
    List<String> csvRecordDataList = new List<String>();

    for (Integer i = 0; i < csvFileLines.size(); i++) {
      string replaceNewLine = '';
      replaceNewLine = csvFileLines[i].replace('\r\n', '');
      replaceNewLine = replaceNewLine.replace('\n', '');
      replaceNewLine = replaceNewLine.replace('\r', '');
      String csvRecordData = replaceNewLine;

      csvRecordDataList.add(csvRecordData);
    }
    //insert listTask;
    return csvRecordDataList;
  }
}
