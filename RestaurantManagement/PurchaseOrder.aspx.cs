using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["cartItems"] == null)
        {
            Session["cartItems"] = newEmptyCart();
        }
        DataTable cartItems = (DataTable)Session["cartItems"];
        displayCart(cartItems);
    }

    DataTable newEmptyCart()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("item_id", typeof(int));
        dt.Columns.Add("name", typeof(string));
        dt.Columns.Add("price", typeof(decimal));
        dt.Columns.Add("quantity", typeof(int));
        return dt;
    }

    DataTable newEmptyRecipeIngredients()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("item_quantity", typeof(int));
        dt.Columns.Add("total_quantity", typeof(int));
        return dt;
    }

    void displayCart(DataTable cartItems)
    {
        cart.DataSource = cartItems;
        cart.DataBind();

        List<int> itemIds = new List<int>();
        decimal sumTotalDecimal = 0;
        foreach (DataRow rowI in cartItems.Rows)
        {
            itemIds.Add((int)rowI["item_id"]);
            sumTotalDecimal += (int)rowI["quantity"] * (decimal)rowI["price"];
        }
        sumTotal.Text = sumTotalDecimal.ToString();

        DataTable cartRecipeIngredients = newEmptyRecipeIngredients();
        if (itemIds.Count > 0)
        {
            SqlConnection con = new SqlConnection(WebConfigurationManager.ConnectionStrings["luigis"].ConnectionString);
            using (con)
            {
                SqlCommand cmd = new SqlCommand("select Recipe.item_id, Ingredients.ingredient_id as ingredient_id, Recipe.ingredient_quantity as ingredient_quantity, Ingredients.ingredient_quantity as current_stock, Ingredients.ingredient_name as name, ingredient_price as price from Recipe, Ingredients where Ingredients.ingredient_id=Recipe.ingredient_id and Recipe.item_id in (" + String.Join(", ", itemIds) +
                    ")", con);
                SqlDataAdapter adap = new SqlDataAdapter(cmd);
                adap.Fill(cartRecipeIngredients);
            }

            foreach (DataRow recipeIngredient in cartRecipeIngredients.Rows)
            {
                foreach (DataRow cartItem in cartItems.Rows)
                {
                    if ((int)recipeIngredient["item_id"] == (int)cartItem["item_id"])
                    {
                        recipeIngredient["item_quantity"] = cartItem["quantity"];
                    }
                }
                recipeIngredient["total_quantity"] = (int)recipeIngredient["item_quantity"] * (int)recipeIngredient["ingredient_quantity"];
            }
        }
        Session["cartRecipeIngredients"] = cartRecipeIngredients;
        purchaseOrder.DataSource = cartRecipeIngredients;
        purchaseOrder.DataBind();
    }

    protected void addToCart_Click(object sender, EventArgs e)
    {
        try
        {
            string item_id = items.SelectedValue;
            int itemId = int.Parse(item_id);
            if (itemDetails.Rows.Count > 0)
            {
                DataTable cartItems = (DataTable)Session["cartItems"];

                decimal sumTotalDecimal = 0;
                DataRow row = null;
                foreach (DataRow rowI in cartItems.Rows)
                {
                    sumTotalDecimal += (int)rowI["quantity"] * (decimal)rowI["price"];
                    if (((int)rowI["item_id"]) == int.Parse(itemDetails.Rows[0].Cells[1].Text))
                    {
                        row = rowI;
                        row["quantity"] = ((int)row["quantity"]) + int.Parse(addToCartQuantity.Text);
                        break;
                    }
                }
                sumTotal.Text = sumTotalDecimal.ToString();

                if (row == null)
                {
                    row = cartItems.NewRow();
                    cartItems.Rows.Add(row);
                    row["quantity"] = int.Parse(addToCartQuantity.Text);
                }

                row["item_id"] = int.Parse(itemDetails.Rows[0].Cells[1].Text);
                row["name"] = itemDetails.Rows[1].Cells[1].Text;
                row["price"] = decimal.Parse(itemDetails.Rows[2].Cells[1].Text);

                Session["cartItems"] = cartItems;

                displayCart(cartItems);
            }
            else
            {
                cartStatus.Text = "Please select an item to be added to the cart";
            }
        }
        catch { }
    }

    protected void confirmOrder_Click(object sender, EventArgs e)
    {
        SqlConnection con = new SqlConnection(WebConfigurationManager.ConnectionStrings["luigis"].ConnectionString);
        decimal sumTotalDecimal = 0;
        if (decimal.TryParse(sumTotal.Text, out sumTotalDecimal))
        {
            using (con)
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction("OrderTransaction");

                try
                {
                    SqlCommand cmd = new SqlCommand("update Store set cash=cash-@sum_total where cash >= @sum_total", con);
                    cmd.Parameters.AddWithValue("sum_total", sumTotalDecimal);
                    cmd.Transaction = transaction;
                    int balanceUpdateResult = cmd.ExecuteNonQuery();

                    int orderUpdateResult = 0;
                    DataTable cartItems = (DataTable)Session["cartItems"];
                    if (cartItems != null)
                    {
                        foreach (DataRow cartItem in cartItems.Rows)
                        {
                            cmd.CommandText = "INSERT INTO Orders(order_id, item_id, quantity, total_price, timestamp) VALUES ((select count(*)+1 from Orders), @item_id, @quantity, @total_price, @timestamp)";
                            cmd.Parameters.Clear();
                            cmd.Parameters.AddWithValue("item_id", cartItem["item_id"]);
                            cmd.Parameters.AddWithValue("quantity", cartItem["quantity"]);
                            cmd.Parameters.AddWithValue("total_price", (decimal)cartItem["price"] * (int)cartItem["quantity"]);
                            cmd.Parameters.AddWithValue("timestamp", DateTime.Now);
                            orderUpdateResult += cmd.ExecuteNonQuery();
                        }
                    }

                    int ingredientUpdateResult = 0;
                    DataTable cartRecipeIngredients = (DataTable)Session["cartRecipeIngredients"];
                    if (cartRecipeIngredients != null)
                    {
                        foreach (DataRow recipeIngredient in cartRecipeIngredients.Rows)
                        {
                            cmd.CommandText = "UPDATE Ingredients set ingredient_quantity=ingredient_quantity-@quantity where ingredient_id=@ingredient_id and ingredient_quantity>@quantity";
                            cmd.Parameters.Clear();
                            cmd.Parameters.AddWithValue("ingredient_id", (int)recipeIngredient["ingredient_id"]);
                            cmd.Parameters.AddWithValue("quantity", (int)recipeIngredient["total_quantity"]);
                            ingredientUpdateResult += cmd.ExecuteNonQuery();
                        }
                    }

                    if (balanceUpdateResult == 1)
                        if (cartItems.Rows.Count == orderUpdateResult)
                            if (cartRecipeIngredients.Rows.Count == ingredientUpdateResult)
                            {
                                transaction.Commit();
                                orderStatus.Text = "Order completed successfully";
                                Session["cartItems"] = newEmptyCart();
                                return;
                            }
                            else
                                orderStatus.Text = "Failed to update ingredients";
                        else
                            orderStatus.Text = "Failed to insert orders";
                    else
                        orderStatus.Text = "Failed to update balance";
                    transaction.Rollback();

                }
                catch (Exception ex)
                {
                    orderStatus.Text = "Order failed: " + ex.Message;
                    transaction.Rollback();
                }

            }
        }
        else
        {
            orderStatus.Text = "Please add items into the cart";
        }
    }

    protected void clearCartB_Click(object sender, EventArgs e)
    {
        Session["cartItems"] = newEmptyCart();
        displayCart((DataTable)Session["cartItems"]);
    }
}