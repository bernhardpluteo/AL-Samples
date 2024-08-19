page 50145 "Employee Job Counts"
{
    ApplicationArea = All;
    Caption = 'Employee Job Counts';
    PageType = ListPart;
    SourceTable = SUM_SP_Employee;
    ShowFilter = true;
    Editable = false;

    layout
    {
        area(content)
        {
            field("Filter"; LblFilter)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Style = StrongAccent;
                StyleExpr = TRUE;
            }

            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Open Job Count"; Rec."Open Job Count")
                {
                    ToolTip = 'Specifies the value of the Open Job Count field.';
                    Visible = ShowOpen;
                    Caption = 'Count';
                }
                field("Ready to Invoice Job Count"; Rec."Ready to Invoice Job Count")
                {
                    ToolTip = 'Specifies the value of the Ready to Invoice Job Count field.';
                    Visible = ShowReadyToInvoice;
                    Caption = 'Count';
                }
                field("Invoiced Job Count"; Rec."Invoiced Job Count")
                {
                    ApplicationArea = All;
                    Visible = ShowInvoiced;
                    Caption = 'Count';
                }
                field("Overdue Job Count"; Rec."Overdue Job Count")
                {
                    ApplicationArea = All;
                    Visible = ShowOverdue;
                    Caption = 'Count';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Open Jobs")
            {
                ApplicationArea = All;
                Caption = 'Open Jobs';
                Image = Open;
                trigger OnAction()
                begin
                    ShowOpen := true;
                    ShowReadyToInvoice := false;
                    ShowInvoiced := false;
                    ShowOverdue := false;
                    LblFilter := 'Open Jobs';
                    CurrPage.Update();
                end;
            }
            action("Ready to Invoice Jobs")
            {
                ApplicationArea = All;
                Caption = 'Ready to Invoice Jobs';
                Image = Invoice;
                trigger OnAction()
                begin
                    ShowOpen := false;
                    ShowReadyToInvoice := true;
                    ShowInvoiced := false;
                    ShowOverdue := false;
                    LblFilter := 'Ready to Invoice Jobs';
                    CurrPage.Update();
                end;
            }
            action("Invoiced Jobs")
            {
                ApplicationArea = All;
                Caption = 'Invoiced Jobs';
                Image = Invoice;
                trigger OnAction()
                begin
                    ShowOpen := false;
                    ShowReadyToInvoice := false;
                    ShowInvoiced := true;
                    ShowOverdue := false;
                    LblFilter := 'Invoiced Jobs';
                    CurrPage.Update();
                end;
            }
            action("Overdue Jobs")
            {
                ApplicationArea = All;
                Caption = 'Overdue Jobs';
                Image = Invoice;
                trigger OnAction()
                begin
                    ShowOpen := false;
                    ShowReadyToInvoice := false;
                    ShowInvoiced := false;
                    ShowOverdue := true;
                    LblFilter := 'Overdue Jobs';
                    CurrPage.Update();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        LblFilter := 'Open Jobs';
        ShowOpen := true;
        ShowReadyToInvoice := false;
        ShowOverdue := false;
        ShowInvoiced := false;
    end;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        // Rec.CalcFields("Open Job Count", "Ready to Invoice Job Count", "Invoiced Job Count", "Overdue Job Count");
        // Rec.SetFilter("Overdue Job Count", '<> 0');
        // Rec.SetFilter("Invoiced Job Count", '<> 0');
        // Rec.SetFilter("Open Job Count", '<> 0');
        // Rec.SetFilter("Ready to Invoice Job Count", '<> 0');
    end;

    var
        ShowOpen: Boolean;
        ShowReadyToInvoice: Boolean;
        ShowInvoiced: Boolean;
        ShowOverdue: Boolean;
        LblFilter: Text;

}
