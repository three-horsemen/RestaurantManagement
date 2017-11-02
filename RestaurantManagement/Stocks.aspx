<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Stocks.aspx.cs" Inherits="_Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Stocks</h2>
    <h3>Average Daily Consumption</h3>
    <asp:GridView ID="consumption" DataSourceID="consumptionSource" runat="server"></asp:GridView>
    <h3>Additional incredients required</h3>
    <asp:GridView ID="ingredientsRequired" DataSourceID="incredientsRequiredSource" runat="server"></asp:GridView>
    <asp:Button ID="purchaseIngredients" runat="server" Text="Purchase" OnClick="purchaseIngredients_Click" />
    <asp:SqlDataSource ID="consumptionSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"></asp:SqlDataSource>
    <asp:SqlDataSource ID="incredientsRequiredSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"></asp:SqlDataSource>
    
</asp:Content>
