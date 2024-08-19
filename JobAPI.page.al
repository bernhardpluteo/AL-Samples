page 50134 "Job API"
{
    PageType = API;

    APIVersion = 'v2.0';
    APIPublisher = 'bcAPI';
    APIGroup = 'powerPlatform';

    EntityName = 'bcjob';
    EntitySetName = 'bcjobs';
    EntityCaption = 'BCJob';
    EntitySetCaption = 'BCJobs';

    ODataKeyFields = SystemId;
    SourceTable = Job;

    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Editable = false;
                    Caption = 'Id', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(projectNo; Rec."Project No.")
                {
                    Caption = 'Project No.';
                }
                field(project; Rec.Project)
                {
                    Caption = 'Project';
                }
                field(projectId; Rec.ProjectId)
                {
                    Caption = 'Project Id';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(extendedDescription; Rec."Extended Description")
                {
                    Caption = 'Extended Description';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                }
                field(extendedJobStatus; Rec."Extended Job Status")
                {
                    Caption = 'Status';
                }
                field(complete; Rec.Complete)
                {
                    Caption = 'Complete';
                }
                field(creationDate; Rec."Creation Date")
                {
                    Caption = 'Creation Date';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(deliveryDate; Rec."Delivery Date")
                {
                    Caption = 'Delivery Date';
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date';
                }
                field(location; Rec.Location)
                {
                    Caption = 'Location';
                }
                field(sellToCustomerNo; Rec."Sell-to Customer No.")
                {
                    Caption = 'Sell-to Customer No.';
                }
                field(sellToCustomerId; Rec."Sell-to Customer Id")
                {
                    Caption = 'Sell-to Customer Id';
                }
                field(sellToCustomerName; Rec."Sell-to Customer Name")
                {
                    Caption = 'Sell-to Customer Name';
                }
                field(sellToCustomerName2; Rec."Sell-to Customer Name 2")
                {
                    Caption = 'Sell-to Customer Name 2';
                }
                field(sellToAddress; Rec."Sell-to Address")
                {
                    Caption = 'Sell-to Address';
                }
                field(sellToAddress2; Rec."Sell-to Address 2")
                {
                    Caption = 'Sell-to Address 2';
                }
                field(sellToCity; Rec."Sell-to City")
                {
                    Caption = 'Sell-to City';
                }
                field(sellToContact; Rec."Sell-to Contact")
                {
                    Caption = 'Sell-to Contact';
                }
                field(sellToContactNo; Rec."Sell-to Contact No.")
                {
                    Caption = 'Sell-to Contact No.';
                }
                field(sellToCountryRegionCode; Rec."Sell-to Country/Region Code")
                {
                    Caption = 'Sell-to Country/Region Code';
                }
                field(sellToCounty; Rec."Sell-to County")
                {
                    Caption = 'Sell-to County';
                }
                field(sellToEMail; Rec."Sell-to E-Mail")
                {
                    Caption = 'Email';
                }
                field(sellToPhoneNo; Rec."Sell-to Phone No.")
                {
                    Caption = 'Sell-to Phone No.';
                }
                field(sellToPostCode; Rec."Sell-to Post Code")
                {
                    Caption = 'Sell-to Post Code';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(supervisor; Rec.Supervisor)
                {
                    Caption = 'Supervisor Name';
                }
                field(supervisorNo; Rec."Supervisor No.")
                {
                    Caption = 'Supervisor No.';
                }
                field(supervisorId; Rec.SupervisorId)
                {
                    Caption = 'Supervisor Id';
                }
                field(totalHours; Rec."Total Hours")
                {
                    Caption = 'Total Hours';
                }
                field(yourReference; Rec."Your Reference")
                {
                    Caption = 'Your Reference';
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code';
                }
                field(globalDimension1CodeId; Rec."Global Dimension 1 Code Id")
                {
                    Caption = 'Global Dimension 1 Code Id';
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code';
                }
                field(globalDimension2CodeId; Rec."Global Dimension 2 Code Id")
                {
                    Caption = 'Global Dimension 2 Code Id';
                }
            }
            part(jobhours; "Job Hour API")
            {
                Caption = 'Job Hours';
                EntityName = 'bcjobHour';
                EntitySetName = 'bcjobHours';
                SubPageLink = SourceId = field(SystemId);
            }
            part(jobResourcePlanner; "Job Resource Planner API")
            {
                Caption = 'Job Resource Planner';
                EntityName = 'bcjobResourcePlanner';
                EntitySetName = 'bcjobResourcePlanners';
                SubPageLink = SourceId = field(SystemId);
            }
        }
    }
}
