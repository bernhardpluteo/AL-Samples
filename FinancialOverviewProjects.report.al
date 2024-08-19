report 50101 "Financial Overview Projects"
{
    Caption = 'Financial Overview Projects';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './src/custom reports/report layouts/FinancialOverviewProjects.rdl';

    dataset
    {
        dataitem(HPJProject; Project)
        {
            RequestFilterFields = "No.";

            column(HPJ_Project_No; "No.")
            {
                IncludeCaption = true;
            }
            column(HPJ_Name; Name)
            {
                IncludeCaption = true;
            }
            column(CompanyPicture; GblCompanyInfo.Picture)
            {
            }
            column(Currency; ReportCurrencyCode)
            {
            }
            column(ReportDateRange; RQPDateRange)
            {
            }
            dataitem("Project Order"; Job)
            {
                DataItemLinkReference = HPJProject;
                DataItemLink = "Project No." = field("No.");
                DataItemTableView = sorting("No.");

                column(PJO_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(PJODescription; Description)
                {
                    IncludeCaption = true;
                }
                column(PJO_Status; Status)
                {
                    IncludeCaption = true;
                }
                column(PJO_Total_Cost; PJOCost)
                {
                    AutoFormatExpression = ReportCurrencyCode;
                    AutoFormatType = 1;
                }
                column(PJO_Total_Income; PJOIncome)
                {
                    AutoFormatExpression = ReportCurrencyCode;
                    AutoFormatType = 1;
                }
                column(PJO_Payroll_Cost_Total; "Payroll Cost Total")
                {
                    IncludeCaption = true;
                    AutoFormatExpression = ReportCurrencyCode;
                    AutoFormatType = 1;
                }

                dataitem("PJO Hour Overview"; "Hour Overview")
                {
                    DataItemLinkReference = "Project Order";
                    DataItemLink = "Source No." = field("No.");
                    DataItemTableView = sorting("Hour Type");

                    column(PJO_HO_Hour_Type; "Hour Type")
                    {
                        IncludeCaption = true;
                    }
                    column(PJO_HO_Quantity; Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(PJO_HO_Payroll_Cost; "Payroll Cost")
                    {
                        IncludeCaption = true;
                        AutoFormatExpression = ReportCurrencyCode;
                        AutoFormatType = 1;
                    }
                    column(PJO_HO_Hidden; PJO_HO_Hidden)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        if RQPFilterHourQuantities = false then
                            PJO_HO_Hidden := 0 else
                            PJO_HO_Hidden := 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    PJOCost := 0;
                    PJOIncome := 0;

                    GetPJOCostOrIncome("No.", Enum::"Job Journal Line Entry Type"::Sale);
                    GetPJOCostOrIncome("No.", Enum::"Job Journal Line Entry Type"::Usage);

                    ProjectJobManagement.CalculatePayrollTotalJob("Project Order"."No.", Enum::"Job Source Type"::Job, RQPDateRange);

                    if RQPBlanksFilter = false then begin
                        GblGeneralJobHours.Reset();
                        GblGeneralJobHours.SetFilter("End Date", RQPDateRange);
                        GblGeneralJobHours.SetRange("Source No.", "No.");
                        GblGeneralJobHours.SetRange("Source Type", Enum::"Job Source Type"::Job);


                        GblJobLedgerEntry.Reset();
                        GblJobLedgerEntry.SetFilter("Posting Date", RQPDateRange);
                        GblJobLedgerEntry.SetRange("Job No.", "No.");

                        if (not ("Total Cost" <> 0) and not ("Total Income" <> 0) and not ("Payroll Cost Total" <> 0)) or (not (GblGeneralJobHours.FindFirst()) and not (GblJobLedgerEntry.FindFirst())) then
                            CurrReport.Skip();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if RQPPJOFilter = false then
                        CurrReport.Break();
                end;
            }
            dataitem("Sales Header"; "Sales Header")
            {
                DataItemLinkReference = HPJProject;
                DataItemLink = "Project No." = field("No.");
                DataItemTableView = sorting("No.");

                column(SO_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(SODescription; Description)
                {
                    IncludeCaption = true;
                }
                column(SO_Status; Status)
                {
                    IncludeCaption = true;
                }
                column(SO_Total_Cost; "Total Cost")
                {
                    IncludeCaption = true;
                    AutoFormatExpression = ReportCurrencyCode;
                    AutoFormatType = 1;
                }
                column(SO_Total_Income; "Total Income")
                {
                    IncludeCaption = true;
                    AutoFormatExpression = ReportCurrencyCode;
                    AutoFormatType = 1;
                }
                column(SO_Payroll_Cost_Total; "Payroll Cost Total")
                {
                    IncludeCaption = true;
                    AutoFormatExpression = ReportCurrencyCode;
                    AutoFormatType = 1;
                }
                dataitem("SO_Hour Overview"; "Hour Overview")
                {
                    DataItemLinkReference = "Sales Header";
                    DataItemLink = "Source No." = field("No.");
                    DataItemTableView = sorting("Hour Type");
                    column(SO_HO_Hour_Type; "Hour Type")
                    {
                        IncludeCaption = true;
                    }
                    column(SO_HO_Quantity; Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(SO_HO_Payroll_Cost; "Payroll Cost")
                    {
                        IncludeCaption = true;
                        AutoFormatExpression = ReportCurrencyCode;
                        AutoFormatType = 1;
                    }
                    column(SO_HO_Hidden; SO_HO_Hidden)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        if RQPFilterHourQuantities = false then
                            SO_HO_Hidden := 0 else
                            SO_HO_Hidden := 1;
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    ProjectJobManagement.CalculatePayrollTotalJob("Sales Header"."No.", Enum::"Job Source Type"::"Sales Order", RQPDateRange);

                    if RQPBlanksFilter = false then begin
                        GblGeneralJobHours.SetFilter("End Date", RQPDateRange);
                        GblGeneralJobHours.SetRange("Source No.", "No.");
                        if not ("Payroll Cost Total" <> 0) or not (GblGeneralJobHours.FindFirst()) then
                            CurrReport.Skip();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if RQPSOFilter = false then
                        CurrReport.Break();
                end;
            }
            column(HPJCostAssigned; HPJCostAssigned)
            {
                AutoFormatExpression = ReportCurrencyCode;
                AutoFormatType = 1;
            }
            column(HPJCostUnassigned; HPJCostUnassigned)
            {
                AutoFormatExpression = ReportCurrencyCode;
                AutoFormatType = 1;
            }
            column(HPJIncome; HPJIncome)
            {
                AutoFormatExpression = ReportCurrencyCode;
                AutoFormatType = 1;
            }
            column(HPJPayrollCost; HPJPayrollCost)
            {
                AutoFormatExpression = ReportCurrencyCode;
                AutoFormatType = 1;
            }
            column(HPJTotalHours; HPJTotalHours)
            {

            }

            trigger OnAfterGetRecord()
            begin
                PJOPayrollCost := 0;
                SOPayrollCost := 0;
                HPJPayrollCost := 0;
                PJOTotalHours := 0;
                SOTotalHours := 0;
                HPJTotalHours := 0;

                HPJCostAssigned := 0;
                HPJCostUnassigned := 0;
                HPJCost := 0;

                HPJIncomeAssigned := 0;
                HPJIncomeUnassigned := 0;
                HPJIncome := 0;

                if RQPPJOFilter = true then begin
                    GetHPJPayrollTotalPJO(HPJProject);
                    GetHPJCostAssigned(HPJProject);
                    GetHPJCostUnassigned(HPJProject);
                    GetHPJIncomeAssigned(HPJProject);
                    GetHPJIncomeUnassigned(HPJProject);
                end;
                if RQPSOFilter = true then
                    GetHPJPayrollTotalSO(HPJProject);

                HPJPayrollCost := PJOPayrollCost + SOPayrollCost;
                HPJTotalHours := PJOTotalHours + SOTotalHours;
                HPJCost := HPJCostAssigned + HPJCostUnassigned;
                HPJIncome := HPJIncomeAssigned + HPJIncomeUnassigned;

                if RQPBlanksFilter = false then
                    if not (HPJPayrollCost <> 0) and not (HPJCost <> 0) and not (HPJIncome <> 0) then
                        CurrReport.Skip();
            end;
        }
    }


    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(Date_From_Filter; RQPDateRange)
                    {
                        ApplicationArea = All;
                        Caption = 'Report Starting Date';
                    }
                    field(Hide_PJO; RQPPJOFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Project Orders';

                    }
                    field(Hide_SO; RQPSOFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Orders';
                    }
                    field(Hide_Hour_Quantities; RQPFilterHourQuantities)
                    {
                        ApplicationArea = All;
                        Caption = 'Hour Quantities';
                    }
                    field(Hide_Zeros; RQPBlanksFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Include Zeros';
                    }
                }
            }
        }
    }

    labels
    {
        Report_Title__Caption = 'Financial Overview';
        Report_Subtitle__Caption = 'Projects';
        Report_Period__Caption = 'Period';
        Report_Currency__Caption = 'Currency';

        HPJ__Financial_Overview_Caption = 'Project Financial Overview';
        HPJ_Total_Hours_Caption = 'Project Total Hours';
        HPJ_Total_Payroll_Cost_Caption = 'Project Total Payroll Cost';
        HPJ_Total_Cost_Assigned_Caption = 'Project Cost - Assigned';
        HPJ_Total_Cost_Unassigned_Caption = 'Project Cost - Unassigned';
        HPJ_Total_Income_Caption = 'Project Total Revenue';
        HPJ_NET_Caption = 'Project NET';

        PJO_Payroll_Cost_Total_Caption = 'Total Payroll Cost';
        PJO_Total_Cost_Caption = 'Total Cost';
        PJO_Total_Income_Caption = 'Total Income';
        PJO_NET_Caption = 'NET';

        PJO_Hour_Type_Caption = 'Hour Type';
        PJO_Hour_Quantity_Caption = 'Quantity';
        PJO_Hour_Type_Payroll_Cost = 'Payroll Cost';

        SO_No_Caption = 'No.';
        SO_Status_Caption = 'Status';
        SO_Payroll_Cost_Total_Caption = 'Total Payroll Cost';
        SO_Total_Cost_Caption = 'Total Cost';
        SO_Total_Income_Caption = 'Total Income';
        SO_NET_Caption = 'NET';

        SO_Hour_Type_Caption = 'Hour Type';
        SO_Hour_Quantity_Caption = 'Quantity';
        SO_Hour_Type_Payroll_Cost = 'Payroll Cost';
    }

    var
        ProjectJobManagement: Codeunit "Project & Job Management";

        GblCompanyInfo: Record "Company Information";
        GblGeneralLedgerSetup: Record "General Ledger Setup";
        GblJobLedgerEntry: Record "Job Ledger Entry";
        GblGeneralJobHours: Record "General Job Hours";
        GblPurchInvLine: Record "Purch. Inv. Line";

        HPJCost: Decimal;
        HPJCostAssigned: Decimal;
        HPJCostUnassigned: Decimal;
        HPJIncome: Decimal;
        HPJIncomeAssigned: Decimal;
        HPJIncomeUnassigned: Decimal;
        HPJPayrollCost: Decimal;
        HPJTotalHours: Decimal;

        PJOCost: Decimal;
        PJOIncome: Decimal;
        PJOPayrollCost: Decimal;
        PJOTotalHours: Decimal;
        SOPayrollCost: Decimal;
        SOTotalHours: Decimal;


        RQPDateRange: Text;
        RQPPJOFilter: Boolean;
        RQPSOFilter: Boolean;
        RQPFilterHourQuantities: Boolean;
        RQPBlanksFilter: Boolean;
        PJO_HO_Hidden: Integer;
        SO_HO_Hidden: Integer;

        ReportCurrencyCode: Code[10];

    trigger OnInitReport()
    begin
        RQPPJOFilter := true;
        RQPSOFilter := true;
        RQPFilterHourQuantities := true;
        RQPBlanksFilter := true;

        GblCompanyInfo.SetAutoCalcFields(Picture);
        GblCompanyInfo.Get();
    end;

    trigger OnPreReport()
    begin
        GblGeneralLedgerSetup.Get();
        ReportCurrencyCode := GblGeneralLedgerSetup."LCY Code";
    end;

    trigger OnPostReport()
    var
        GeneralJobHours: Record "General Job Hours";
        HourOverview: Record "Hour Overview";
    begin
        GeneralJobHours.Reset();
        HourOverview.DeleteAll();
    end;

    local procedure "GetPJOCostOrIncome"(var "Source No.": Code[20]; "Entry Type": Enum "Job Journal Line Entry Type")
    var
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        JobLedgerEntry.Reset();
        JobLedgerEntry.SetFilter("Posting Date", RQPDateRange);
        JobLedgerEntry.SetRange("Job No.", "Source No.");
        JobLedgerEntry.SetRange("Entry Type", "Entry Type");
        if JobLedgerEntry.FindSet() then
            repeat
                if "Entry Type" = Enum::"Job Journal Line Entry Type"::Usage then
                    PJOCost += JobLedgerEntry."Total Cost (LCY)"
                else if "Entry Type" = Enum::"Job Journal Line Entry Type"::Sale then
                    PJOIncome += JobLedgerEntry."Line Amount (LCY)";

            until JobLedgerEntry.Next() = 0;
    end;

    local procedure GetHPJCostAssigned(ProjectInput: Record Project)
    var
        ProjectOrders: Record Job;
        JobledgerEntry: Record "Job Ledger Entry";
    begin
        HPJCostAssigned := 0;

        ProjectOrders.SetRange("Project No.", ProjectInput."No.");
        if ProjectOrders.FindSet() then
            repeat
                JobLedgerEntry.Reset();
                JobledgerEntry.SetFilter("Posting Date", RQPDateRange);
                JobLedgerEntry.SetRange("Job No.", ProjectOrders."No.");
                JobLedgerEntry.SetRange("Entry Type", Enum::"Job Journal Line Entry Type"::Usage);
                if JobLedgerEntry.FindSet() then
                    repeat
                        HPJCostAssigned += JobLedgerEntry."Total Cost (LCY)";
                    until JobLedgerEntry.Next() = 0;
            until ProjectOrders.Next() = 0;
    end;


    local procedure GetHPJCostUnassigned(ProjectInput: Record Project)
    var
        GLEntry: Record "G/L Entry";
    begin
        HPJCostUnassigned := 0;

        GLEntry.Reset();
        GLEntry.SetFilter("Posting Date", RQPDateRange);
        GLEntry.SetRange("Shortcut Dimension 3 Code", ProjectInput."No.");
        GLEntry.SetRange("Gen. Posting Type", Enum::"General Posting Type"::Purchase);
        GLEntry.SetRange("Job No.", '');
        if GLEntry.FindSet() then
            repeat
                HPJCostUnassigned += GLEntry.Amount;
            until GLEntry.Next() = 0;
    end;

    local procedure GetHPJIncomeAssigned(ProjectInput: Record Project)
    var
        ProjectOrders: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        HPJIncomeAssigned := 0;

        ProjectOrders.SetRange("Project No.", ProjectInput."No.");
        if ProjectOrders.FindSet() then
            repeat
                JobLedgerEntry.Reset();
                JobLedgerEntry.SetFilter("Posting Date", RQPDateRange);
                JobLedgerEntry.SetRange("Job No.", ProjectOrders."No.");
                JobLedgerEntry.SetRange("Entry Type", Enum::"Job Journal Line Entry Type"::Sale);
                if JobLedgerEntry.FindSet() then
                    repeat
                        HPJIncomeAssigned += JobLedgerEntry."Line Amount (LCY)";
                    until JobLedgerEntry.Next() = 0;
            until ProjectOrders.Next() = 0;
    end;

    local procedure GetHPJIncomeUnassigned(ProjectInput: Record Project)
    var
        GLEntry: Record "G/L Entry";
    begin
        HPJIncomeUnassigned := 0;

        GLEntry.Reset();
        GLEntry.SetFilter("Posting Date", RQPDateRange);
        GLEntry.SetRange("Shortcut Dimension 3 Code", ProjectInput."No.");
        GLEntry.SetRange("Gen. Posting Type", Enum::"General Posting Type"::Sale);
        GLEntry.SetRange("Job No.", '');
        if GLEntry.FindSet() then
            repeat
                HPJIncomeUnassigned += GLEntry.Amount;
            until GLEntry.Next() = 0;
    end;

    local procedure GetHPJPayrollTotalPJO(ProjectInput: Record Project)
    var
        GeneralJobHours: Record "General Job Hours";
        ProjectOrders: Record Job;
    begin
        ProjectOrders.SetRange("Project No.", ProjectInput."No.");
        if ProjectOrders.FindSet() then
            repeat
                GeneralJobHours.SetFilter("End Date", RQPDateRange);
                GeneralJobHours.SetRange("Source No.", ProjectOrders."No.");
                GeneralJobHours.SetRange("Source Type", Enum::"Job Source Type"::Job);
                if GeneralJobHours.FindSet() then
                    repeat
                        PJOPayrollCost += GeneralJobHours."Payroll Cost";
                        PJOTotalHours += GeneralJobHours.Quantity;
                    until GeneralJobHours.Next() = 0;
            until ProjectOrders.Next() = 0;
    end;

    local procedure GetHPJPayrollTotalSO(ProjectInput: Record Project)
    var
        GeneralJobHours: Record "General Job Hours";
        SalesOrders: Record "Sales Header";
    begin
        SalesOrders.SetRange("Project No.", ProjectInput."No.");
        if SalesOrders.FindSet() then
            repeat
                GeneralJobHours.SetFilter("End Date", RQPDateRange);
                GeneralJobHours.SetRange("Source No.", SalesOrders."No.");
                GeneralJobHours.SetRange("Source Type", Enum::"Job Source Type"::"Sales Order");
                if GeneralJobHours.FindSet() then
                    repeat
                        SOPayrollCost += GeneralJobHours."Payroll Cost";
                        SOTotalHours += GeneralJobHours.Quantity;
                    until GeneralJobHours.Next() = 0;
            until SalesOrders.Next() = 0;
    end;
}