<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="ajax_project.aspx.cs" Inherits="ajax_project" Theme="LuigiTheme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="Form" runat="Server">
    <link rel="stylesheet" href="ajax_style.css" />
    <div id="body">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div id="header"></div>
        <div id="main">

            <div id="content-1">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <h2>Stocks</h2>
                        <h3>Average Daily Consumption</h3>
                        <asp:GridView ID="consumption" DataSourceID="consumptionSource" runat="server"></asp:GridView>
                        <h3>Additional ingredients required</h3>
                        <asp:GridView ID="ingredientsRequired" DataSourceID="ingredientsRequiredSource" runat="server" OnDataBound="ingredientsRequired_DataBound"></asp:GridView>
                        Total replenish cost =
                        <asp:Label ID="totalReplenishCost" runat="server"></asp:Label>
                        <br />
                        Current cash =
                        <asp:Label ID="currentCash" runat="server"></asp:Label>
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
	Ingredients.ingredient_name"></asp:SqlDataSource>

                        <asp:SqlDataSource ID="ingredientsRequiredSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
                            SelectCommand="select Ingredients.ingredient_name as 'Ingredient Name', ceiling(sum(orders.quantity * recipe.ingredient_quantity)/1.5 - Ingredients.ingredient_quantity) as 'Future Requirement', ceiling(sum(orders.quantity * recipe.ingredient_quantity)/1.5 - Ingredients.ingredient_quantity) * Ingredients.ingredient_price as 'Replenish Cost' from orders, items, recipe, Ingredients where orders.item_id = items.item_id and items.item_id = recipe.item_id and recipe.ingredient_id =  Ingredients.ingredient_id and Orders.timestamp Between DATEADD(d, -3, GETDATE()) and GETDATE() group by Ingredients.ingredient_name, Ingredients.ingredient_quantity, Ingredients.ingredient_price having ceiling(sum(orders.quantity * recipe.ingredient_quantity)/1.5 - Ingredients.ingredient_quantity) > 0" />

                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="confirmOrder" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>

            <div id="content-2">

                <div id="content-2-1">
                    <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <h2>Purchase Order</h2>
                            <h3>Item Details</h3>
                            <asp:DropDownList ID="items" DataSourceID="itemsSource" DataTextField="name" DataValueField="item_id" runat="server" AutoPostBack="true"></asp:DropDownList>
                            <asp:SqlDataSource ID="itemsSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>" SelectCommand="select name, item_id from Items"></asp:SqlDataSource>

                            <!--TODO Disable updates to other item fields-->
                            <asp:DetailsView ID="itemDetails" runat="server" Height="50px" Width="125px" DataSourceID="itemDetailsSource" AutoGenerateRows="false" AutoGenerateEditButton="true">
                                <Fields>
                                    <asp:BoundField DataField="item_id" HeaderText="Item ID" ReadOnly="true" />
                                    <asp:BoundField DataField="name" HeaderText="Name" ReadOnly="true" />
                                    <asp:BoundField DataField="price" HeaderText="PriceHidden" />
                                    <asp:TemplateField HeaderText="Price">
                                        <EditItemTemplate>
                                            <asp:TextBox ID="itemPriceTB" runat="server" Text='<%# Bind("price") %>' />
                                        </EditItemTemplate>
                                        <ItemTemplate>
                                            <asp:Label ID="itemPriceTB" runat="server" Text='<%# Bind("price") %>' />
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
                            <asp:GridView ID="recipe" runat="server" DataSourceID="ingredientSource" AutoGenerateColumns="false" AutoGenerateEditButton="true">
                                <Columns>
                                    <asp:TemplateField HeaderText="Ingredient ID">
                                        <EditItemTemplate>
                                            <asp:Label ID="ingredient_id" Text='<%# Bind("ingredient_id") %>' runat="server" />
                                        </EditItemTemplate>
                                        <ItemTemplate>
                                            <asp:Label ID="ingredient_id" Text='<%# Eval("ingredient_id") %>' runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="Ingredient" HeaderText="Ingredient" ReadOnly="true" />
                                    <asp:BoundField DataField="Price" HeaderText="Price" ReadOnly="true" />
                                    <asp:BoundField DataField="Quantity" HeaderText="Quantity" />
                                    <asp:BoundField DataField="Cost" HeaderText="Cost" ReadOnly="true" />
                                </Columns>
                            </asp:GridView>
                            <asp:SqlDataSource ID="ingredientSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
                                SelectCommand="select Recipe.ingredient_id as ingredient_id, ingredient_name as Ingredient, ingredient_price as Price, Recipe.ingredient_quantity as Quantity, ingredient_price*Recipe.ingredient_quantity as Cost from Ingredients, Recipe where Ingredients.ingredient_id=Recipe.ingredient_id and Recipe.item_id=@item_id"
                                UpdateCommand="update Recipe set ingredient_quantity=@Quantity where item_id=@item_code and ingredient_id=@ingredient_id">
                                <SelectParameters>
                                    <asp:ControlParameter Name="item_id" ControlID="items" PropertyName="SelectedValue" />
                                </SelectParameters>
                                <UpdateParameters>
                                    <asp:ControlParameter Name="item_code" ControlID="items" PropertyName="SelectedValue" />
                                </UpdateParameters>
                            </asp:SqlDataSource>

                            <asp:Label ID="cartStatus" runat="server" Text=""></asp:Label>
                            <br />

                            Quantity:
   
                            <asp:TextBox ID="addToCartQuantity" runat="server"></asp:TextBox>
                            <asp:RangeValidator ID="rvclass" runat="server" ControlToValidate="addToCartQuantity" ErrorMessage="Please enter a number from 1 to 100" MaximumValue="100" MinimumValue="1" Type="Integer"></asp:RangeValidator>
                            <br />
                            <asp:Button ID="addToCart" runat="server" Text="Add To Cart" OnClick="addToCart_Click" />
                            <h3>Cart
       
                                <asp:Button ID="clearCartB" runat="server" Text="Clear" OnClick="clearCartB_Click" />
                            </h3>
                            <asp:GridView ID="cart" runat="server"></asp:GridView>
                            <h3>Purchase Order</h3>
                            <asp:GridView ID="purchaseOrder" runat="server"></asp:GridView>
                            <br />
                            <b>Sum Total:</b>
                            <asp:Label ID="sumTotal" runat="server" Text=""></asp:Label>
                            <br />
                            <asp:DetailsView ID="cashInHand" DataSourceID="cashInHandSource" runat="server" />
                            <asp:SqlDataSource ID="cashInHandSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>" SelectCommand="select cash as 'Cash In Hand' from Store"></asp:SqlDataSource>
                            <br />
                            <asp:Label ID="orderStatus" runat="server" Text=""></asp:Label>
                            <br />
                            <asp:Button ID="confirmOrder" runat="server" Text="ConfirmOrder" OnClick="confirmOrder_Click" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="purchaseIngredients" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="clearCartB" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="items" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>

                <div id="content-2-2">
                    <asp:UpdatePanel ID="UpdatePanel3" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <h2>Monthly Sales & Expenses</h2>
                            <div class="inline">
                                <h4>Duration</h4>
                                <asp:RadioButtonList ID="Duration" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Duration_SelectedIndexChanged">
                                    <asp:ListItem>Monthly</asp:ListItem>
                                    <asp:ListItem>Weekly</asp:ListItem>
                                </asp:RadioButtonList>
                            </div>
                            <div class="inline" style="color: black">
                                <h4>Aspects</h4>
                                <asp:CheckBoxList ID="ReportCheckBoxList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Duration_SelectedIndexChanged">
                                    <asp:ListItem Selected="True">Sales</asp:ListItem>
                                    <asp:ListItem Selected="True">Expenses</asp:ListItem>
                                </asp:CheckBoxList>
                            </div>

                            <asp:SqlDataSource runat="server" ID="monthSalesSource" ConnectionString="<%$ConnectionStrings:luigis %>"
                                SelectCommand="Select * From Orders where Orders.timestamp Between DATEADD(m, -1, GETDATE()) and GETDATE()" />
                            <asp:SqlDataSource runat="server" ID="weekSalesSource" ConnectionString="<%$ConnectionStrings:luigis %>"
                                SelectCommand="Select * From Orders where Orders.timestamp Between DATEADD(d, -7, GETDATE()) and GETDATE()" />
                            <asp:SqlDataSource runat="server" ID="monthExpenseSource" ConnectionString="<%$ConnectionStrings:luigis %>"
                                SelectCommand="Select Ingredients.ingredient_name, Provides.timestamp, Provides.ingredient_quantity, Provides.ingredient_quantity * Ingredients.ingredient_price as TotalCost from Ingredients, Provides where Provides.timestamp Between DATEADD(m, -1, GETDATE()) and GETDATE() and Ingredients.ingredient_id = Provides.ingredient_id" />
                            <asp:SqlDataSource runat="server" ID="weekExpenseSource" ConnectionString="<%$ConnectionStrings:luigis %>"
                                SelectCommand="Select Ingredients.ingredient_name, Provides.timestamp, Provides.ingredient_quantity, Provides.ingredient_quantity * Ingredients.ingredient_price as TotalCost from Ingredients, Provides where Provides.timestamp Between DATEADD(d, -7, GETDATE()) and GETDATE() and Ingredients.ingredient_id = Provides.ingredient_id" />

                            <div style="color: black">
                                <h3>Sales</h3>
                                <asp:GridView runat="server" ID="salesGridView" />
                                <h3>Expenses</h3>
                                <asp:GridView runat="server" ID="expenseGridView" />
                            </div>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="confirmOrder" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="ReportCheckBoxList" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>

            </div>

        </div>
    </div>
</asp:Content>

