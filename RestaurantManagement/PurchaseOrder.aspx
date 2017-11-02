<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="PurchaseOrder.aspx.cs" Inherits="_Default" Theme="LuigiTheme"%>

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
    <asp:GridView ID="recipe" runat="server" DataSourceID="ingredientSource" AutoGenerateColumns="true" AutoGenerateEditButton="true" />
    <asp:SqlDataSource ID="ingredientSource" runat="server" ConnectionString="<%$connectionStrings:luigis %>"
        SelectCommand="select ingredient_name as Ingredient, ingredient_price as Price, Recipe.ingredient_quantity as Quantity, ingredient_price*Recipe.ingredient_quantity as Cost from Ingredients, Recipe where Ingredients.ingredient_id=Recipe.ingredient_id and Recipe.item_id=@item_id"
        UpdateCommand="update Items set price=@price where item_id=@item_code">
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
    <h3>Cart <asp:Button ID="clearCartB" runat="server" Text="Clear" OnClick="clearCartB_Click" />
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
</asp:Content>
