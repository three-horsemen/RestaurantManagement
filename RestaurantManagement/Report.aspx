<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Report.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Monthly Sales & Expenses</h2>
    <div class="inline">
        <h4>Duration</h4>
        <asp:RadioButtonList ID="Duration" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Duration_SelectedIndexChanged">
            <asp:ListItem>Monthly</asp:ListItem>
            <asp:ListItem>Weekly</asp:ListItem>
        </asp:RadioButtonList>
    </div>
    <div class="inline">
        <h4>Aspects</h4>
        <asp:CheckBoxList ID="ReportCheckBoxList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Duration_SelectedIndexChanged">
            <asp:ListItem Selected="True">Sales</asp:ListItem>
            <asp:ListItem Selected="True">Expenses</asp:ListItem>
        </asp:CheckBoxList>
    </div>

    <asp:SqlDataSource runat="server" ID="monthSalesSource" ConnectionString="<%$ConnectionStrings:luigis %>" 
        SelectCommand="Select * From Orders where Orders.timestamp Between DATEADD(m, -1, GETDATE()) and GETDATE()"/>
    <asp:SqlDataSource runat="server" ID="weekSalesSource" ConnectionString="<%$ConnectionStrings:luigis %>" 
        SelectCommand="Select * From Orders where Orders.timestamp Between DATEADD(d, -7, GETDATE()) and GETDATE()"/>
    <asp:SqlDataSource runat="server" ID="monthExpenseSource" ConnectionString="<%$ConnectionStrings:luigis %>" 
        SelectCommand="Select Ingredients.ingredient_name, Provides.timestamp, Provides.ingredient_quantity, Provides.ingredient_quantity * Ingredients.ingredient_price as TotalCost from Ingredients, Provides where Provides.timestamp Between DATEADD(m, -1, GETDATE()) and GETDATE() and Ingredients.ingredient_id = Provides.ingredient_id"/>
    <asp:SqlDataSource runat="server" ID="weekExpenseSource" ConnectionString="<%$ConnectionStrings:luigis %>" 
        SelectCommand="Select Ingredients.ingredient_name, Provides.timestamp, Provides.ingredient_quantity, Provides.ingredient_quantity * Ingredients.ingredient_price as TotalCost from Ingredients, Provides where Provides.timestamp Between DATEADD(d, -7, GETDATE()) and GETDATE() and Ingredients.ingredient_id = Provides.ingredient_id"/>


    <h3>Sales</h3>
    <asp:GridView runat="server" ID="salesGridView" />
    <h3>Expenses</h3>
    <asp:GridView runat="server" ID="expenseGridView" />
</asp:Content>

