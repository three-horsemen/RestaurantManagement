<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Stocks.aspx.cs" Inherits="_Default" Theme="LuigiTheme"%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <h2>Stocks</h2>
    <h3>Average Daily Consumption</h3>
    <asp:GridView ID="consumption" DataSourceID="consumptionSource" runat="server"></asp:GridView>
    <h3>Additional ingredients required</h3>
    <asp:GridView ID="ingredientsRequired" DataSourceID="ingredientsRequiredSource" runat="server" OnDataBound="ingredientsRequired_DataBound"></asp:GridView>
    Total replenish cost = <asp:Label ID="totalReplenishCost" runat="server"></asp:Label>
    <br />
    Current cash = <asp:Label ID="currentCash" runat="server"></asp:Label>
    <br />
    <asp:Button ID="purchaseIngredients" runat="server" Text="Purchase" OnClick="purchaseIngredients_Click" />
    <asp:Label ID="confirmPurchase" runat="server"></asp:Label>

    <asp:SqlDataSource ID="consumptionSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
        SelectCommand="
select
	Ingredients.ingredient_name as 'Ingredient Name', ceiling(sum(orders.quantity * recipe.ingredient_quantity)/3.0) as '3 Average Ingredients'
from 
	orders, items, recipe, Ingredients
where 
	orders.item_id = items.item_id and items.item_id = recipe.item_id and recipe.ingredient_id = Ingredients.ingredient_id and Orders.timestamp Between DATEADD(d, -3, GETDATE()) and GETDATE()
group by
	Ingredients.ingredient_name">

    </asp:SqlDataSource>
    <asp:SqlDataSource ID="ingredientsRequiredSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
        SelectCommand="
select 
	Ingredients.ingredient_name as 'Ingredient Name', ceiling(sum(orders.quantity * recipe.ingredient_quantity)/1.5 - Ingredients.ingredient_quantity) as 'Future Requirement', ceiling(sum(orders.quantity * recipe.ingredient_quantity)/1.5 - Ingredients.ingredient_quantity) * Ingredients.ingredient_price as 'Replenish Cost'
from 
	orders, items, recipe, Ingredients
where 
	orders.item_id = items.item_id and items.item_id = recipe.item_id and recipe.ingredient_id = Ingredients.ingredient_id and Orders.timestamp Between DATEADD(d, -3, GETDATE()) and GETDATE()
group by
	Ingredients.ingredient_name, Ingredients.ingredient_quantity, Ingredients.ingredient_price
having
	ceiling(sum(orders.quantity * recipe.ingredient_quantity)/1.5 - Ingredients.ingredient_quantity) > 0
"></asp:SqlDataSource>
</asp:Content>
