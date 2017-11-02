<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PurchaseOrder.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Purchase Order</h2>
    <h3>Item Details</h3>
    <asp:dropdownlist id="items" datasourceid="itemsSource" datatextfield="name" datavaluefield="id" runat="server"></asp:dropdownlist>
    <asp:sqldatasource id="itemsSource" runat="server" connectionstring="<%$connectionStrings:luigis %>" />
    <!--Selectcommand="select name, id from Items"-->
    <asp:detailsview runat="server" height="50px" width="125px" DataSourceID="itemDetailsSource"></asp:detailsview>
    <asp:sqldatasource id="itemDetailsSource" runat="server" connectionstring="<%$connectionStrings:luigis %>" />
    <!--Selectcommand="select * from Items where item_code=@itemCode"-->

    <asp:button id="addToCart" runat="server" text="Add To Cart" />
    <h3>Purchase Order</h3>
    <asp:gridview id="purchaseOrder" runat="server"></asp:gridview>
    <asp:button id="confirmOrder" runat="server" text="ConfirmOrder" />

</asp:Content>

