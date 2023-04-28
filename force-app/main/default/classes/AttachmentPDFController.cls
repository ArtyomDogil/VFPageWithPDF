public with sharing class AttachmentPDFController {
    public String MstrId{get;set;}
    public Account accObj{get;set;}
    String FinalTitle = 'Generate PDF #';

    public PageReference Cancel(){
        PageReference pdf = new PageReference('/' + MstrID);
        pdf.setredirect(True);
        return pdf;
    }

    public AttachmentPDFController(ApexPages.StandardController Controller){
        MstrId = ApexPages.currentPage().getParameters().get('id');
        accObj = [SELECT Id,
                         Name,
                         Phone,
                         Description,
                         Rating
                  FROM Account
                  WHERE Id =: MstrId];
    }

    public PageReference pdfAction(){
        PageReference savepage = Page.AccountPDFGenerate;
        savepage.getParameters().put('id', MstrID);
        Blob pdfBlob = savepage.getContent();

        List<ContentDocumentLink> notesAttch = [SELECT id,
                                                       ContentDocument.Title,
                                                       LinkedEntityId
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId =: MstrID
                                                ORDER BY ContentDocument.Title
                                                ASC];

        if(notesAttch.size() > 0){
            String title =  notesAttch[0].ContentDocument.Title;
            List<String> titleSplit = title.split('Generate PDF #');
            FinalTitle = FinalTitle + (notesAttch.size() + 1);
        } else {
            FinalTitle = FinalTitle + 1;
        }
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = FinalTitle + '.pdf';
        conVer.Title = FinalTitle;
        conVer.VersionData = pdfBlob;
        insert conVer;

        Id conDoc = [SELECT ContentDocumentId
                     FROM ContentVersion
                     WHERE Id =:conVer.Id].ContentDocumentId;

        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = MstrID;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
        update accObj;

        PageReference pdf = new PageReference('/' + MstrID);
        pdf.setredirect(True);
        return pdf;
    }
}