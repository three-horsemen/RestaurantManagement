<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PurchaseOrder.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Purchase Order</h2>
    <h3>Item Details</h3>
    <asp:DropDownList ID="items" DataSourceID="itemsSource" DataTextField="name" DataValueField="item_id" runat="server" AutoPostBack="true"></asp:DropDownList>
    <asp:SqlDataSource ID="itemsSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>" SelectCommand="select name, item_id from Items" />
    <!--Selectcommand="select name, id from Items"-->
    <asp:DetailsView runat="server" Height="50px" Width="125px" DataSourceID="itemDetailsSource"></asp:DetailsView>
    <asp:SqlDataSource ID="itemDetailsSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>" SelectCommand="select * from Items where item_id=@item_code">
        <SelectParameters>
            <asp:ControlParameter Name="item_code" ControlID="items" PropertyName="SelectedValue" />
        </SelectParameters>
    </asp:SqlDataSource>
    <!--Selectcommand="select * from Items where item_code=@itemCode"-->

    <asp:Button ID="addToCart" runat="server" Text="Add To Cart" />
    <h3>Purchase Order</h3>
    <asp:GridView ID="purchaseOrder" runat="server"></asp:GridView>
    <asp:Button ID="confirmOrder" runat="server" Text="ConfirmOrder" />

</asp:Content>

