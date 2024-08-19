pageextension 50112 "Fixed Asset Card Ext" extends "Fixed Asset Card"
{
    layout
    {
        addafter("Serial No.")
        {
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
            }
            field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
            }
            field("Shortcut Dimension 4 Code"; Rec."Shortcut Dimension 4 Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Shortcut Dimension 4 Code field.';
            }
        }
        addfirst("Depreciation Book")
        {
            group(Overview)
            {
                field("AcquisitionCost"; DepreciationBook."Acquisition Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Total Acquisition Cost';
                }
                field(Depreciation; DepreciationBook.Depreciation)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Accumulated Depreciation';
                }
                field(LastDepreciationDate; DepreciationBook."Last Depreciation Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Last Depreciation Date';
                }
                field(TotalMaintenanceCost; DepreciationBook.Maintenance)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Total Maintenance Cost';
                }
                field(ComponentValue; ComponentValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Value of Components';
                }
            }
        }
    }
    var
        DepreciationBook: Record "FA Depreciation Book";
        ComponentValue: Decimal;

    trigger OnAfterGetRecord()
    begin
        DepreciationBook.SetRange("FA No.", Rec."No.");
        if DepreciationBook.Count = 1 then begin
            DepreciationBook.FindFirst();
            DepreciationBook.CalcFields("Acquisition Cost", Depreciation, Maintenance);
            if Rec."Main Asset/Component" = Enum::"FA Component Type"::"Main Asset" then
                CalculateAssetComponentsValue();
        end;
    end;

    local procedure CalculateAssetComponentsValue()
    var
        ComponentDepreciationBook: Record "FA Depreciation Book";
    begin
        ComponentDepreciationBook.SetCurrentKey("Depreciation Book Code", "Component of Main Asset");
        ComponentDepreciationBook.SetRange("Depreciation Book Code", DepreciationBook."Depreciation Book Code");
        ComponentDepreciationBook.SetRange("Component of Main Asset", Rec."Component of Main Asset");
        if ComponentDepreciationBook.FindSet() then
            repeat
                if ComponentDepreciationBook."Disposal Date" = 0D then
                    if ComponentDepreciationBook."Last Acquisition Cost Date" > 0D then begin
                        ComponentDepreciationBook.CalcFields("Book Value");
                        ComponentValue += ComponentDepreciationBook."Book Value";
                    end;
            until ComponentDepreciationBook.Next() < 1;
    end;
}
