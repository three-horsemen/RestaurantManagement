<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Report.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Monthly Sales & Expenses</h2>
    <div class="inline">
        <h4>Duration</h4>
        <asp:RadioButtonList ID="Duration" runat="server" AutoPostBack="true">
            <asp:ListItem>Monthly</asp:ListItem>
            <asp:ListItem>Weekly</asp:ListItem>
        </asp:RadioButtonList>
    </div>
    <div class="inline">
        <h3>Aspects</h3>
        <asp:CheckBoxList runat="server" AutoPostBack="true">
            <asp:ListItem>Sales</asp:ListItem>
            <asp:ListItem>Expenses</asp:ListItem>
        </asp:CheckBoxList>
    </div>

    <asp:SqlDataSource runat="server" ID="salesSource" ConnectionString="<%$ConnectionStrings:luigis %>" />
    <asp:SqlDataSource runat="server" ID="expensesSource" ConnectionString="<%$ConnectionStrings:luigis %>" />

    <h3>Sales</h3>
    <asp:GridView runat="server" ID="GridView1" DataSourceID="salesSource" />
    <h3>Expenses</h3>
    <asp:GridView runat="server" ID="GridView2" DataSourceID="expensesSource" />
</asp:Content>

