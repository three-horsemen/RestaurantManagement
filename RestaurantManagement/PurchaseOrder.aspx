﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PurchaseOrder.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Purchase Order</h2>
    <h3>Item Details</h3>
    <asp:DropDownList ID="items" DataSourceID="itemsSource" DataTextField="name" DataValueField="item_id" runat="server" AutoPostBack="true"></asp:DropDownList>
    <asp:SqlDataSource ID="itemsSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>" SelectCommand="select name, item_id from Items"></asp:SqlDataSource>

    <!--TODO Disable updates to other item fields-->
    <asp:DetailsView ID="itemDetails" runat="server" Height="50px" Width="125px" DataSourceID="itemDetailsSource" AutoGenerateRows="false" AutoGenerateEditButton="true">
        <Fields>
            <asp:BoundField DataField="item_id" HeaderText="Item ID" ReadOnly="true" />
            <asp:BoundField DataField="name" HeaderText="Name" ReadOnly="true" />
            <asp:TemplateField HeaderText="Price">
                <EditItemTemplate>
                    <asp:TextBox ID="itemPriceTB" runat="server" Text='<%# Bind("price") %>' />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="itemPriceTB" runat="server" Text='<%# Eval("price") %>' />
                </ItemTemplate>
            </asp:TemplateField>
        </Fields>
    </asp:DetailsView>
    <asp:SqlDataSource ID="itemDetailsSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
        SelectCommand="select * from Items where item_id=@item_code"
        UpdateCommand="update Items set price=@price where item_id=@item_code">
        <SelectParameters>
            <asp:ControlParameter Name="item_code" ControlID="items" PropertyName="SelectedValue" />
        </SelectParameters>
        <UpdateParameters>
            <asp:ControlParameter Name="item_code" ControlID="items" PropertyName="SelectedValue" />
        </UpdateParameters>
    </asp:SqlDataSource>

    <h3>Ingredients</h3>
    <asp:GridView ID="recipe" runat="server" DataSourceID="ingredientSource" AutoGenerateColumns="true" AutoGenerateEditButton="true" />
    <asp:SqlDataSource ID="ingredientSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
        SelectCommand="select ingredient_name as Ingredient, ingredient_price as Price, ingredient_quantity as Quantity, ingredient_price*ingredient_quantity as Cost from Ingredients, Recipe where Ingredients.ingredient_id=Recipe.ingredient_id and Recipe.item_id=@item_id"
        UpdateCommand="update Items set price=@price where item_id=@item_code">
        <SelectParameters>
            <asp:ControlParameter Name="item_id" ControlID="items" PropertyName="SelectedValue" />
        </SelectParameters>
        <UpdateParameters>
            <asp:ControlParameter Name="item_code" ControlID="items" PropertyName="SelectedValue" />
        </UpdateParameters>
    </asp:SqlDataSource>

    <asp:Button ID="addToCart" runat="server" Text="Add To Cart" />
    <h3>Purchase Order</h3>
    <asp:GridView ID="purchaseOrder" runat="server"></asp:GridView>
    <asp:Button ID="confirmOrder" runat="server" Text="ConfirmOrder" />

</asp:Content>