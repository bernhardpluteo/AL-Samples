codeunit 50102 "Payslip Management"
{
    Permissions = tabledata "Dimension Set Entry" = RIMD;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::SUM_SP_CalculateSlip, 'OnAfterCreatePayrollSlip', '', false, false)]
    local procedure OnAfterCreatePayrollSlip(var PayrollSlip: Record SUM_SP_Slip)
    var
        JobHours: Record "General Job Hours";
        HourSetup: Record "Job Hour Type Setup";
        Employee: Record SUM_SP_Employee;
        GeneralLedgerSetup: Record "General Ledger Setup";
        JobSetup: Record "Jobs Setup";
        GlobalDimensionValue1: Record "Dimension Value";
        GlobalDimensionValue2: Record "Dimension Value";
        ShortcutDimensionValue3: Record "Dimension Value";

        TypeHelper: Codeunit "Type Helper";

        Quantity: Decimal;
        CustomOvertimeRange: Boolean;

        StartTime: DateTime;
    begin
        StartTime := TypeHelper.GetCurrUTCDateTime();
        ProgessWindow.Open('Adding Job Hours to Payslip #1######\#2########################\#3########################\#4########################\#5########################\#6########################');

        ProgessWindow.Update(1, PayrollSlip."No.");
        GeneralLedgerSetup.Get();
        JobSetup.Get();

        ProgessWindow.Update(2, PayrollSlip."Employee Name");
        CustomOvertimeRange := CheckOvertimeCustomRange();
        Employee.Get(PayrollSlip."Employee No.");
        HourSetup.SetRange("Payslip Line", true);

        GlobalDimensionValue1.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        GlobalDimensionValue2.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 2 Code");
        ShortcutDimensionValue3.SetRange("Dimension Code", JobSetup."Project Dimension Code");

        JobHours.SetRange("Employee No.", PayrollSlip."Employee No.");
        JobHours.SetRange(Issued, false);
        JobHours.SetRange("Slip No.", 0);
        JobHours.SetRange("Slip Journal No.", 0);

        if Employee."Wage Cost Against Emp. Dim." then begin
            if HourSetup.FindSet() then
                repeat
                    JobHours.SetRange("Hour Type", HourSetup."Hour Type");
                    if HourSetup.Overtime and CustomOvertimeRange then
                        JobHours.SetRange("Start Date", GetOvertimePeriodStartDate(PayrollSlip), GetOvertimePeriodEndDate(PayrollSlip))
                    else
                        JobHours.SetRange("Start Date", PayrollSlip."Period From Date", PayrollSlip."Period To Date");
                    if not GlobalDimensionValue2.IsEmpty and GlobalDimensionValue2.FindSet() then
                        repeat
                            ProgessWindow.Update(3, StrSubstNo('%1|%2', GlobalDimensionValue2.Code, GlobalDimensionValue2.Code));
                            JobHours.SetRange("Global Dimension 2 Code", GlobalDimensionValue2.Code);
                            if not ShortcutDimensionValue3.IsEmpty and ShortcutDimensionValue3.FindSet() then
                                repeat
                                    ProgessWindow.Update(3, StrSubstNo('%1|%2|%3', GlobalDimensionValue1.Code, GlobalDimensionValue2.Code, ShortcutDimensionValue3.Code));
                                    ProgessWindow.Update(6, CalcSeconds(StartTime));
                                    Quantity := 0;
                                    JobHours.SetRange("Shortcut Dimension 3 Code", ShortcutDimensionValue3.Code);
                                    if not JobHours.IsEmpty and JobHours.FindSet() then
                                        repeat
                                            if ((HourSetup.Basic) and not (Employee.SalaryType = Employee.SalaryType::"Hourly rate")) then
                                                JobHours.Next()
                                            else
                                                if ((HourSetup.Overtime) and not (Employee."Allow Overtime")) then
                                                    JobHours.Next()
                                                else
                                                    Quantity += JobHours.Quantity;
                                            ProgessWindow.Update(4, StrSubstNo('%1 Hours', Quantity));
                                        until JobHours.Next() < 1;
                                    if Quantity > 0 then begin
                                        CreatePayslipLine(HourSetup, Employee."Global Dimension 1 Code", GlobalDimensionValue2.Code, ShortcutDimensionValue3.Code, Quantity, PayrollSlip, JobHours);
                                        ProgessWindow.Update(4, '0 Hours');
                                    end;
                                until ShortcutDimensionValue3.Next() < 1;
                        until GlobalDimensionValue2.Next() < 1;
                until HourSetup.Next() < 1;
        end else
            if HourSetup.FindSet() then
                repeat
                    JobHours.SetRange("Hour Type", HourSetup."Hour Type");
                    if HourSetup.Overtime and CustomOvertimeRange then
                        JobHours.SetRange("Start Date", GetOvertimePeriodStartDate(PayrollSlip), GetOvertimePeriodEndDate(PayrollSlip))
                    else
                        JobHours.SetRange("Start Date", PayrollSlip."Period From Date", PayrollSlip."Period To Date");
                    if not GlobalDimensionValue1.IsEmpty and GlobalDimensionValue1.FindSet() then
                        repeat
                            ProgessWindow.Update(3, StrSubstNo('%1', GlobalDimensionValue1.Code));
                            JobHours.SetRange("Global Dimension 1 Code", GlobalDimensionValue1.Code);
                            if not GlobalDimensionValue2.IsEmpty and GlobalDimensionValue2.FindSet() then
                                repeat
                                    ProgessWindow.Update(3, StrSubstNo('%1|%2', GlobalDimensionValue1.Code, GlobalDimensionValue2.Code));
                                    JobHours.SetRange("Global Dimension 2 Code", GlobalDimensionValue2.Code);
                                    if not ShortcutDimensionValue3.IsEmpty and ShortcutDimensionValue3.FindSet() then
                                        repeat
                                            ProgessWindow.Update(3, StrSubstNo('%1|%2|%3', GlobalDimensionValue1.Code, GlobalDimensionValue2.Code, ShortcutDimensionValue3.Code));
                                            ProgessWindow.Update(6, CalcSeconds(StartTime));
                                            JobHours.SetRange("Shortcut Dimension 3 Code", ShortcutDimensionValue3.Code);
                                            Quantity := 0;
                                            if not JobHours.IsEmpty and JobHours.FindSet() then
                                                repeat
                                                    if ((HourSetup.Basic) and not (Employee.SalaryType = Employee.SalaryType::"Hourly rate")) then
                                                        JobHours.Next()
                                                    else
                                                        if ((HourSetup.Overtime) and not (Employee."Allow Overtime")) then
                                                            JobHours.Next()
                                                        else
                                                            Quantity += JobHours.Quantity;
                                                    ProgessWindow.Update(4, StrSubstNo('%1 Hours', Quantity));
                                                until JobHours.Next() < 1;
                                            if Quantity > 0 then begin
                                                CreatePayslipLine(HourSetup, GlobalDimensionValue1.Code, GlobalDimensionValue2.Code, ShortcutDimensionValue3.Code, Quantity, PayrollSlip, JobHours);
                                                ProgessWindow.Update(4, '0 Hours');
                                            end;
                                        until ShortcutDimensionValue3.Next() < 1;
                                until GlobalDimensionValue2.Next() < 1;
                        until GlobalDimensionValue1.Next() < 1;
                until HourSetup.Next() < 1;
    end;

    procedure AddJobHoursToPayslip(var JobHours: Record "General Job Hours"; SlipNo: Integer)
    var
        PayrollSlip: Record SUM_SP_Slip;
        SlipLine: Record SUM_SP_SlipLine;
        HourSetup: Record "Job Hour Type Setup";
    begin
        PayrollSlip.Get(SlipNo);
        ProgessWindow.Open('Adding Job Hours to Payslip #1######\#2########################\#3########################\#4########################\#5########################\#6########################');
        ProgessWindow.Update(1, PayrollSlip."No.");
        ProgessWindow.Update(2, PayrollSlip."Employee Name");
        if not JobHours.IsEmpty and JobHours.FindSet() then
            repeat
                HourSetup.Get(JobHours."Hour Type");
                ProgessWindow.Update(3, StrSubstNo('%1|%2|%3', JobHours."Global Dimension 1 Code", JobHours."Global Dimension 2 Code", JobHours."Shortcut Dimension 3 Code"));
                ProgessWindow.Update(4, JobHours.Quantity);
                SlipLine.SetRange("Slip No.", PayrollSlip."No.");
                SlipLine.SetRange("Journal No.", PayrollSlip."Journal No.");
                SlipLine.SetRange("Employee No.", PayrollSlip."Employee No.");
                SlipLine.SetRange(LinePayrollCode, HourSetup.PayrollCode);
                SlipLine.SetRange("Shortcut Dimension 1 Code", JobHours."Global Dimension 1 Code");
                SlipLine.SetRange("Shortcut Dimension 2 Code", JobHours."Global Dimension 2 Code");
                SlipLine.SetRange("Dimension 3 Code", JobHours."Shortcut Dimension 3 Code");
                if not SlipLine.IsEmpty and SlipLine.FindFirst() then begin
                    SlipLine.Validate(Quantity, SlipLine.Quantity + JobHours.Quantity);
                    if SlipLine.Modify() then begin
                        JobHours.Validate("Slip No.", PayrollSlip."No.");
                        JobHours.Validate("Slip Line No.", SlipLine."Line No");
                        JobHours.Validate("Slip Journal No.", SlipLine."Journal No.");
                        JobHours.Modify(true);
                    end;
                end else
                    CreatePayslipLine(HourSetup, JobHours."Global Dimension 1 Code", JobHours."Global Dimension 2 Code", JobHours."Shortcut Dimension 3 Code", JobHours.Quantity, PayrollSlip, JobHours);
            until JobHours.Next() < 1;
        ProgessWindow.Close();
    end;

    local procedure CheckOvertimeCustomRange(): Boolean
    var
        PayrollSetting: Record SUM_SP_Settings;
    begin
        PayrollSetting.Get();
        if PayrollSetting."Custom Overtime Range" then
            exit(true)
        else
            exit(false);

    end;

    local procedure GetOvertimePeriodStartDate(PayrollSlip: Record SUM_SP_Slip): Date
    var
        PayrollSettings: Record SUM_SP_Settings;
        StartDate: Date;
    begin
        PayrollSettings.Get();
        StartDate := DMY2Date(PayrollSettings."Overtime Start Date Day", Date2DMY(CalcDate('<-1M>', PayrollSlip."Period From Date"), 2), Date2DMY(CalcDate('<-1M>', PayrollSlip."Period From Date"), 3));
        exit(StartDate);
    end;

    local procedure GetOvertimePeriodEndDate(PayrollSlip: Record SUM_SP_Slip): Date
    var
        PayrollSettings: Record SUM_SP_Settings;
        EndDate: Date;
    begin
        PayrollSettings.Get();
        EndDate := DMY2Date(PayrollSettings."Overtime End Date Day", Date2DMY(PayrollSlip."Period From Date", 2), Date2DMY(PayrollSlip."Period From Date", 3));
        exit(EndDate);
    end;

    local procedure CreatePayslipLine(HourSetup: Record "Job Hour Type Setup"; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20]; ShortcutDimension3Code: Code[20]; Quantity: Decimal; PayrollSlip: Record SUM_SP_Slip; var JobHours: Record "General Job Hours")
    var
        SlipLine: Record SUM_SP_SlipLine;
        Employee: Record SUM_SP_Employee;
        PayrollCode: Record SUM_SP_PayrollCode;
    begin
        SlipLine.Init();
        SlipLine.Validate("Slip No.", PayrollSlip."No.");
        SlipLine.Validate("Line No", GetLineNo(PayrollSlip));
        SlipLine.Validate("Journal No.", PayrollSlip."Journal No.");
        if SlipLine.Insert(true) then begin
            Employee.Get(PayrollSlip."Employee No.");
            SlipLine.Validate("Employee No.", PayrollSlip."Employee No.");
            SlipLine.Validate(LinePayrollCode, HourSetup.PayrollCode);
            SlipLine.Validate(Quantity, Quantity);
            SlipLine.Validate("Shortcut Dimension 1 Code", GlobalDimension1Code);
            SlipLine.Validate("Shortcut Dimension 2 Code", GlobalDimension2Code);
            SlipLine.Validate("Dimension 3 Code", ShortcutDimension3Code);
            PayrollCode.Get(Date2DMY(Today, 3), HourSetup.PayrollCode);
            if HourSetup."Payroll Rate" = Enum::"Payroll Rate"::Multiplier then
                SlipLine.Validate(Rate, Employee."Hourly Rate" * PayrollCode.Rate)
            else
                if HourSetup."Payroll Rate" = Enum::"Payroll Rate"::"Add-on" then
                    SlipLine.Validate(Rate, PayrollCode.Rate);
            SlipLine.Validate(Amount, SlipLine.Quantity * SlipLine.Rate);
            if SlipLine.Modify(true) then
                if not JobHours.IsEmpty and JobHours.FindSet() then
                    repeat
                        JobHours.Validate("Slip No.", PayrollSlip."No.");
                        JobHours.Validate("Slip Line No.", SlipLine."Line No");
                        JobHours.Validate("Slip Journal No.", SlipLine."Journal No.");
                        JobHours.Modify(true);
                    until JobHours.Next() < 1;
            ProgessWindow.Update(5, StrSubstNo('Created Slip Line %1 Dimension Combination: %2|%3|%4 Quantity: %5', SlipLine."Line No", GlobalDimension1Code, GlobalDimension2Code, ShortcutDimension3Code, Quantity));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SUM_SP_IssueSlip, 'OnBeforeIssue', '', true, true)]
    local procedure OnBeforeIssue(JournalNo: Integer; SlipNo: Integer)
    var
        JobHours: Record "General Job Hours";
    begin
        JobHours.SetRange("Slip Journal No.", JournalNo);
        JobHours.SetRange("Slip No.", SlipNo);
        if not JobHours.IsEmpty and JobHours.FindSet() then
            JobHours.ModifyAll(Issued, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SUM_SP_IssueSlip, 'OnAfterIssue', '', true, true)]
    local procedure OnAfterIssue(IssuedPayrollSlip: Record SUM_SP_IssuedSlip)
    var
        JobHours: Record "General Job Hours";
        TypeHelper: Codeunit "Type Helper";
    begin
        JobHours.SetRange("Slip Journal No.", IssuedPayrollSlip."Journal No.");
        JobHours.SetRange("Slip No.", IssuedPayrollSlip."Slip No.");
        if not JobHours.IsEmpty and JobHours.FindSet() then begin
            JobHours.ModifyAll("Payout Date", IssuedPayrollSlip."Payment Date");
            JobHours.ModifyAll("Issued At", TypeHelper.GetCurrentDateTimeInUserTimeZone());
            JobHours.ModifyAll("Issued Slip No.", IssuedPayrollSlip."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SUM_SP_IssueSlip, 'OnAfterReOpen', '', true, true)]
    local procedure OnAfterReOpen(var IssuedSlip: Record SUM_SP_IssuedSlip; Slip: Record SUM_SP_Slip)
    var
        JobHours: Record "General Job Hours";
    begin
        JobHours.SetRange("Slip Journal No.", IssuedSlip."Journal No.");
        JobHours.SetRange("Issued Slip No.", IssuedSlip."No.");
        if not JobHours.IsEmpty and JobHours.FindSet() then begin
            JobHours.ModifyAll(Issued, false);
            JobHours.ModifyAll("Issued At", 0DT);
            JobHours.ModifyAll("Payout Date", 0D);
            JobHours.ModifyAll("Slip No.", Slip."No.");
            JobHours.ModifyAll("Issued Slip No.", 0);
        end;
        Slip."Slip No." := Slip."No.";
        Slip.Modify();
    end;

    local procedure GetLineNo(PayrollSlip: Record SUM_SP_Slip): Decimal
    var
        SlipLine: Record SUM_SP_SlipLine;
    begin
        SlipLine.SetRange("Slip No.", PayrollSlip."No.");
        if not SlipLine.IsEmpty and SlipLine.FindLast() then
            exit(SlipLine."Line No" + 10000)
        else
            exit(10000);
    end;

    [EventSubscriber(ObjectType::Table, Database::SUM_SP_Slip, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSlipEvent(var Rec: Record SUM_SP_Slip)
    var
        JobHours: Record "General Job Hours";
    begin
        JobHours.SetRange("Slip Journal No.", Rec."Journal No.");
        JobHours.SetRange("Slip No.", Rec."Slip No.");
        JobHours.SetRange(Issued, false);
        if not JobHours.IsEmpty and JobHours.FindSet() then
            repeat
                JobHours."Slip Journal No." := 0;
                JobHours."Slip No." := 0;
                JobHours."Slip Line No." := 0;
                JobHours.Modify();
            until JobHours.Next() < 1;
    end;

    local procedure CalcSeconds(StartTime: DateTime): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Format((TypeHelper.GetCurrUTCDateTime() - StartTime)));
    end;

    var
        ProgessWindow: Dialog;
}
