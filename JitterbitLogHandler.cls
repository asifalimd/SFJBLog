/**
 * Created by amohammad
 */

global with sharing class JitterbitLogHandler implements Messaging.InboundEmailHandler {

    public static Map<String, String> fields = new Map<String, String>{
            'Environment' => 'Environment__c', 'Agent Name' => 'Agent_Name__c', 'Project Name' => 'Project__c', 'Operation Name' => 'Operation_Name__c',
            'Start Time' => 'Start_Time__c', 'End Time' => 'End_Time__c', 'Source Count' => 'Source_Count__c',
            'Target Count' => 'Target_Count__c', 'Warning Count' => 'Warning_Count__c', 'Error Message' => 'Error_Message__c'
    };

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmail.BinaryAttachment[] csvFiles = email.binaryAttachments;
        // you could implement different logic for success and error notification by checking the subject.
        // For demo purpose i am going to use only one method processLogs;
        String subject = email.subject;
        processLogs(email);

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        return result;
    }

    /**
     * This method captures the log information using the fields map and expects specific format
     * for sample format check the unit test class
     * @param emailObj
     */
    public static void processLogs(Messaging.inboundEmail emailObj) {
        String emailContent = emailObj.plainTextBody;
        Jitterbit_Log__c log = new Jitterbit_Log__c();

        for (String key : fields.keySet()) {
            // system.debug('Key=='+key);
            if (emailContent.containsIgnoreCase('{' + key + ' =>')) {
                Object val = emailContent.substringBetween('{' + key + ' =>', '}').trim();
                // you might need to tweak this depending on your field names and add extra lines of code for type casting
                val = key.containsIgnoreCase('time') ? Datetime.valueOf((String) val) : (key.containsIgnoreCase('count') ? Decimal.valueOf((String) val) : val);
                log.put(fields.get(key), val);
            }
        }

        try {
            insert log;
            // process the attachments
            if (emailObj.binaryAttachments != null) attachFiles(log, emailObj.binaryAttachments);
        } catch (Exception e) {
            // log exception
        }
    }

    private static void attachFiles(Jitterbit_Log__c log, Messaging.InboundEmail.BinaryAttachment[] files) {
        Attachment[] attachments = new List<Attachment>();
        for (Messaging.InboundEmail.BinaryAttachment file : files) {
            Attachment a1 = new Attachment();
            a1.ParentId = log.Id;
            a1.Body = file.body;
            a1.Name = file.fileName;
            attachments.add(a1);
        }
        if (attachments.size() > 0) insert attachments;
        system.debug('Files' + attachments);
    }

}