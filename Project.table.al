table 50102 Project
{
    Caption = 'Project';
    DataClassification = ToBeClassified;
    DataCaptionFields = "No.", Name;
    LookupPageId = "Project List";
    DrillDownPageId = "Project List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(5; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(6; Description; Text[264])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer."No.";
            Editable = false;
        }
        field(11; "Customer"; Text[100])
        {
            Caption = 'Customer';
            DataClassification = ToBeClassified;
            trigger OnLookup()
            var
                Customer: Record Customer;
            begin
                if Page.RunModal(Page::"Customer List", Customer) = Action::LookupOK then begin
                    Rec.Validate(Customer, Customer.Name);
                    Rec.Validate("Customer No.", Customer."No.");
                    Rec.Validate(CustomerId, Customer.SystemId);
                end;
            end;
        }
        field(12; CustomerId; Guid)
        {
            Caption = 'Customer Id';
            DataClassification = ToBeClassified;
            TableRelation = Customer.SystemId;
            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.GetBySystemId(Rec.CustomerId) then begin
                    Rec.Validate(Customer, Customer.Name);
                    Rec.Validate("Customer No.", Customer."No.");
                end;
            end;
        }
        field(20; "Supervisor No."; Integer)
        {
            Caption = 'Supervisor No.';
            DataClassification = ToBeClassified;
            TableRelation = SUM_SP_Employee."No.";
            Editable = false;
        }
        field(21; "Supervisor"; Text[100])
        {
            Caption = 'Supervisor';
            DataClassification = ToBeClassified;
            trigger OnLookup()
            var
                Employee: Record SUM_SP_Employee;
            begin
                if Page.RunModal(Page::SUM_SP_EmployeeList, Employee) = Action::LookupOK then begin
                    Rec.Validate(Supervisor, Employee.FullName());
                    Rec.Validate("Supervisor No.", Employee."No.");
                    Rec.Validate(SupervisorId, Employee.SystemId);
                end;
            end;
        }
        field(22; SupervisorId; Guid)
        {
            Caption = 'Supervisor Id';
            DataClassification = ToBeClassified;
            TableRelation = SUM_SP_Employee.SystemId;
            trigger OnValidate()
            var
                Employee: Record SUM_SP_Employee;
            begin
                if Employee.GetBySystemId(Rec.SupervisorId) then begin
                    Rec.Validate(Supervisor, Employee.FullName());
                    Rec.Validate("Supervisor No.", Employee."No.");
                end;
            end;
        }
        field(50; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = ToBeClassified;
        }
        field(51; "Expected Completion Date"; Date)
        {
            Caption = 'Expected Completion Date';
            DataClassification = ToBeClassified;
        }
        field(52; "Actual Completion Date"; Date)
        {
            Caption = 'Actual Completion Date';
            DataClassification = ToBeClassified;
        }
        field(100; Status; Enum "Project Status")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
        }
        field(110; "Expected Revenue"; Decimal)
        {
            Caption = 'Expected Revenue';
            DataClassification = ToBeClassified;
        }
        field(111; "Actual Revenue"; Decimal)
        {
            Caption = 'Actual Revenue excl.';
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry".Amount where("Shortcut Dimension 3 Code" = field("No."), "Gen. Posting Type" = const(Sale)));

        }
        field(115; "Expected Expenses"; Decimal)
        {
            Caption = 'Expected Expenses';
        }
        field(116; "Actual Expenses"; Decimal)
        {
            Caption = 'Actual Expenses';
            FieldClass = FlowField;
            CalcFormula = sum("G/L Entry".Amount where("Shortcut Dimension 3 Code" = field("No."), "Gen. Posting Type" = const(Purchase)));
        }
        field(120; "Expected Hour Consumption"; Decimal)
        {
            Caption = 'Expected Hour Consumption';
            DataClassification = ToBeClassified;
        }
        field(121; "Actual Total Hour Consump."; Decimal)
        {
            Caption = 'Actual Total Hour Consumption';
            FieldClass = FlowField;
            CalcFormula = sum(SUM_SP_IssuedSlipLine.Amount where("Dimension 3 Code" = field("No.")));
        }

        field(125; "Total Job Hours"; Decimal)
        {
            Caption = 'Total Job Hours';
            FieldClass = FlowField;
            CalcFormula = sum("General Job Hours".Quantity where("Shortcut Dimension 3 Code" = field("No.")));
        }
        field(130; "Expected Cost of Goods"; Decimal)
        {
            Caption = 'Expected Cost of Goods';
            DataClassification = ToBeClassified;
        }
        field(131; "Actual Total Cost of Goods"; Decimal)
        {
            Caption = 'Actual Total Cost of Goods';
            FieldClass = FlowField;
            CalcFormula = sum("General Job Hours"."Payroll Cost" where("Project No." = field("No.")));
        }
        field(200; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(250; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            trigger OnValidate()
            var
                DimensionValue: Record "Dimension Value";
            begin
                DimensionValue.SetRange("Global Dimension No.", 1);
                DimensionValue.SetRange(Code, Rec."Global Dimension 1 Code");
                if DimensionValue.FindFirst() then
                    Rec."Global Dimension 1 Code Id" := DimensionValue.SystemId;
            end;
        }
        field(251; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            trigger OnValidate()
            var
                DimensionValue: Record "Dimension Value";
            begin
                DimensionValue.SetRange("Global Dimension No.", 2);
                DimensionValue.SetRange(Code, Rec."Global Dimension 2 Code");
                if DimensionValue.FindFirst() then
                    Rec."Global Dimension 2 Code Id" := DimensionValue.SystemId;
            end;
        }
        field(260; "Global Dimension 1 Code Id"; Guid)
        {
            TableRelation = "Dimension Value".SystemId WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            Caption = 'Global Dimension 1 Code Id';
        }
        field(261; "Global Dimension 2 Code Id"; Guid)
        {
            TableRelation = "Dimension Value".SystemId WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            Caption = 'Global Dimension 2 Code Id';
        }
        field(262; "Shortcut Dimension 3 Code Id"; Guid)
        {
            TableRelation = "Dimension Value".SystemId WHERE("Global Dimension No." = CONST(3),
                                                          Blocked = CONST(false));
            Caption = 'Shortcut Dimension 3 Code Id';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        DimensionValue: Record "Dimension Value";
    begin
        if "No." = '' then begin
            JobSetup.Get();
            JobSetup.TestField("Project Nos.");
            NoSeriesMgt.InitSeries(JobSetup."Project Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;

        if JobSetup.Get() then
            if JobSetup."Project Dimension" then begin
                JobSetup.TestField("Project Dimension Code");
                if not DimensionValue.Get(JobSetup."Project Dimension Code", Rec."No.") then begin
                    DimensionValue.Init();
                    DimensionValue.Validate("Dimension Code", JobSetup."Project Dimension Code");
                    DimensionValue.Validate(Code, Rec."No.");
                    DimensionValue.Validate(Name, Rec.Name);
                    DimensionValue.Validate("Global Dimension No.", 3);
                    DimensionValue.Insert();
                end;
            end;
        // if not ProjectJob.Get(Rec."No.") then begin
        //     ProjectJob.Init();
        //     ProjectJob.Validate("No.", Rec."No.");
        //     ProjectJob.Validate("Project No.", Rec."No.");
        //     ProjectJob.Validate(Name, Rec.Name);
        //     ProjectJob.Indentation := 0;
        //     ProjectJob.Insert();
        // end;
    end;

    local procedure CreateProjectChangeLog(TypeofChange: Enum "Change Log Entry Type"; FieldNo: Integer;
                                                             OldValue: Text;
                                                             NewValue: Text)
    var
        ChangeLogEntry: Record "Project Change Log Entry";
    begin
        ChangeLogEntry.Init();
        ChangeLogEntry.Validate("Date and Time", CurrentDateTime);
        ChangeLogEntry.Validate("User ID", UserId);
        ChangeLogEntry.Validate("User GUID", UserSecurityId());
        ChangeLogEntry.Validate("Type of Change", TypeofChange);
        ChangeLogEntry.Validate("Field No.", FieldNo);
        ChangeLogEntry.Validate("Project No.", Rec."No.");
        ChangeLogEntry.Validate("Old Value", OldValue);
        ChangeLogEntry.Validate("New Value", NewValue);
        ChangeLogEntry.Insert(true);
    end;

    trigger OnRename()
    var
        DimensionValue: Record "Dimension Value";
    begin
        if JobSetup.Get() then
            if JobSetup."Project Dimension" then begin
                JobSetup.TestField("Project Dimension Code");
                if DimensionValue.Get(JobSetup."Project Dimension Code", xRec."No.") then
                    DimensionValue.Rename(JobSetup."Project Dimension Code", Rec."No.");
            end;
    end;

    trigger OnModify()
    var
        DimensionValue: Record "Dimension Value";
    begin
        if Supervisor = '' then begin
            Rec.Validate("Supervisor No.", 0);
            Rec.SupervisorId := '{00000000-0000-0000-0000-000000000000}';
        end;
        if Customer = '' then begin
            Rec.Validate("Customer No.", '');
            Rec.CustomerId := '{00000000-0000-0000-0000-000000000000}';
        end;

        if (Rec."Expected Cost of Goods" <> xRec."Expected Cost of Goods") and (xRec."Expected Cost of Goods" = 0) then
            CreateProjectChangeLog(Enum::"Change Log Entry Type"::Insertion, 130, '', Format(Rec."Expected Cost of Goods"))
        else
            if (Rec."Expected Cost of Goods" <> xRec."Expected Cost of Goods") then
                CreateProjectChangeLog(Enum::"Change Log Entry Type"::Modification, 130, Format(xRec."Expected Cost of Goods"), Format(Rec."Expected Cost of Goods"));
        if (Rec."Expected Expenses" <> xRec."Expected Expenses") and (xRec."Expected Expenses" = 0) then
            CreateProjectChangeLog(Enum::"Change Log Entry Type"::Insertion, 115, '', Format(Rec."Expected Expenses"))
        else
            if (Rec."Expected Expenses" <> xRec."Expected Expenses") then
                CreateProjectChangeLog(Enum::"Change Log Entry Type"::Modification, 115, Format(xRec."Expected Expenses"), Format(Rec."Expected Expenses"));
        if (Rec."Expected Hour Consumption" <> xRec."Expected Hour Consumption") and (xRec."Expected Hour Consumption" = 0) then
            CreateProjectChangeLog(Enum::"Change Log Entry Type"::Insertion, 120, '', Format(Rec."Expected Hour Consumption"))
        else
            if (Rec."Expected Hour Consumption" <> xRec."Expected Hour Consumption") then
                CreateProjectChangeLog(Enum::"Change Log Entry Type"::Modification, 120, Format(xRec."Expected Hour Consumption"), Format(Rec."Expected Hour Consumption"));
        if (Rec."Expected Revenue" <> xRec."Expected Revenue") and (xRec."Expected Revenue" = 0) then
            CreateProjectChangeLog(Enum::"Change Log Entry Type"::Insertion, 110, '', Format(Rec."Expected Revenue"))
        else
            if (Rec."Expected Revenue" <> xRec."Expected Revenue") then
                CreateProjectChangeLog(Enum::"Change Log Entry Type"::Modification, 110, Format(xRec."Expected Revenue"), Format(Rec."Expected Revenue"));

        if (Rec.Name <> xRec.Name) then
            if JobSetup.Get() then
                if JobSetup."Project Dimension" then begin
                    JobSetup.TestField("Project Dimension Code");
                    if DimensionValue.Get(JobSetup."Project Dimension Code", Rec."No.") then begin
                        DimensionValue.Validate(Name, Rec.Name);
                        DimensionValue.Modify();
                    end;
                end;
    end;

    trigger OnDelete()
    var
        GeneralJobHours: Record "General Job Hours";
        CannotDeleteProjectLbl: Label 'Project %1 cannot be deleted as it is related to Job Hours';
    begin
        GeneralJobHours.SetRange("Shortcut Dimension 3 Code", Rec."No.");
        if not GeneralJobHours.IsEmpty then
            Error(StrSubstNo(CannotDeleteProjectLbl, Rec."No."));
    end;

    var
        JobSetup: Record "Jobs Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}
