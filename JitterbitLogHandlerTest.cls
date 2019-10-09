/**
 * Created by amohammad
 */
@isTest
private with sharing class JitterbitLogHandlerTest {

    @isTest
    private static void testSuccessEmail(){

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email
        email.subject = 'Test Email Subject';
        email.plainTextBody = '{Operation Name => Account Upsert}\n{Agent Name => JB agent}\n{Environment => development}\n{Project Name => JB project name}\n{Start Time => 2019-09-16 07:00:13}\n{End Time => 2019-09-16 07:00:13}\n{Warning Count => 10}\n{Source Count => 200}\n{Target Count => 190}\n{Error Message => Error Message}\n';
        env.fromAddress = 'self@noreply.com';

        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('This is just a dummy text file for unit testing');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';

        email.binaryAttachments =
                new Messaging.inboundEmail.BinaryAttachment[]{
                        attachment
                };

        // call the email service class and test it with the data in the testMethod
        JitterbitLogHandler emailProcess = new JitterbitLogHandler();
        emailProcess.handleInboundEmail(email, env);

        Jitterbit_Log__c[] logs = [Select Id, Name from Jitterbit_Log__c];
        system.assert(logs.size()>0);


    }

}