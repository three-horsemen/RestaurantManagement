using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Configuration;
using System.Data;
using System.Data.SqlClient;

public partial class ajax_project : System.Web.UI.Page
{
    public int totalValue = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["cartItems"] == null)
        {
            Session["cartItems"] = newEmptyCart();
        }
        DataTable cartItems = (DataTable)Session["cartItems"];
        displayCart(cartItems);
        if (!IsPostBack)
        {
            totalValue = 0;
            totalReplenishCost.Text = "";

            string selectSql = "select cash from Store";
            string connStr = WebConfigurationManager.ConnectionStrings["luigis"].ConnectionString;
            SqlConnection con = new SqlConnection(connStr);
            SqlCommand cmd = new SqlCommand(selectSql, con);
            SqlDataReader r;
            try
            {
                con.Open();
                r = cmd.ExecuteReader();
                while (r.Read())
                {
                    currentCash.Text = r["cash"].ToString();
                }
                r.Close();
            }
            catch
            {
                currentCash.Text = "NA";
            }
            finally
            {
                con.Close();
            }
            purchaseIngredients.Enabled = false;
        }
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

        DataTable cartRecipeIngredients = new DataTable();
        if (itemIds.Count > 0)
        {
            SqlConnection con = new SqlConnection(WebConfigurationManager.ConnectionStrings["luigis"].ConnectionString);
            using (con)
            {
                SqlCommand cmd = new SqlCommand(
                    "select Recipe.item_id, Ingredients.ingredient_id as ingredient_id, Ingredients.ingredient_name as name, ingredient_price as price, Ingredients.ingredient_quantity as current_stock, Recipe.ingredient_quantity as ingredient_quantity from Recipe, Ingredients"
                    + " where Ingredients.ingredient_id=Recipe.ingredient_id and Recipe.item_id in (" + String.Join(", ", itemIds) +
                    ")", con);
                SqlDataAdapter adap = new SqlDataAdapter(cmd);
                adap.Fill(cartRecipeIngredients);
            }
            cartRecipeIngredients.Columns.Add("item_quantity", typeof(int));
            cartRecipeIngredients.Columns.Add("total_quantity", typeof(int));

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
        if (addToCartQuantity.Text == "")
        {
            cartStatus.Text = "Must provide a valid quantity";
            return;
        }
        cartStatus.Text = "";
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
                    SqlCommand cmd = new SqlCommand("update Store set cash=cash+@sum_total where cash >= @sum_total", con);
                    cmd.Parameters.AddWithValue("sum_total", sumTotalDecimal);
                    cmd.Transaction = transaction;
                    int balanceUpdateResult = cmd.ExecuteNonQuery();

                    int orderUpdateResult = 0;
                    DataTable cartItems = (DataTable)Session["cartItems"];
                    if (cartItems != null)
                    {
                        cmd.CommandText = "select count(*)+1 as order_id from Orders";
                        cmd.Parameters.Clear();
                        SqlDataReader reader = cmd.ExecuteReader();
                        if (reader.Read())
                        {
                            int newOrderId = (int)reader["order_id"];
                            reader.Close();
                            foreach (DataRow cartItem in cartItems.Rows)
                            {
                                cmd.CommandText = "INSERT INTO Orders(order_id, item_id, quantity, total_price, timestamp) VALUES (@order_id, @item_id, @quantity, @total_price, @timestamp)";
                                cmd.Parameters.Clear();
                                cmd.Parameters.AddWithValue("order_id", newOrderId);
                                cmd.Parameters.AddWithValue("item_id", cartItem["item_id"]);
                                cmd.Parameters.AddWithValue("quantity", cartItem["quantity"]);
                                cmd.Parameters.AddWithValue("total_price", (decimal)cartItem["price"] * (int)cartItem["quantity"]);
                                cmd.Parameters.AddWithValue("timestamp", DateTime.Now);
                                orderUpdateResult += cmd.ExecuteNonQuery();
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
                                        cashInHand.DataBind();
                                        orderStatus.Text = "Order completed successfully";
                                        Session["cartItems"] = newEmptyCart();
                                        displayCart((DataTable)Session["cartItems"]);
                                        salesGridView.DataBind();
                                        expenseGridView.DataBind();
                                        return;
                                    }
                                    else
                                        orderStatus.Text = "Failed to update ingredients";
                                else
                                    orderStatus.Text = "Failed to insert orders";
                            else
                                orderStatus.Text = "Failed to update balance";
                        }
                        else
                        {
                            reader.Close();
                            orderStatus.Text = "Unable to insert order (Cannot read current orders)";
                        }
                    }
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
    protected void purchaseIngredients_Click(object sender, EventArgs e)
    {
        string updateSql = "update Store set cash = cash - " + totalReplenishCost.Text;
        string connStr = WebConfigurationManager.ConnectionStrings["luigis"].ConnectionString;
        SqlConnection con = new SqlConnection(connStr);
        SqlCommand cmd = new SqlCommand(updateSql, con);
        try
        {
            con.Open();
            int affected = cmd.ExecuteNonQuery();
            cmd.Dispose();
            confirmPurchase.Text = "Purchase complete!";
            try
            {
                int int_currentCash = 0;
                int_currentCash = (Convert.ToInt32(currentCash.Text) - Convert.ToInt32(totalReplenishCost.Text));
                currentCash.Text = (Convert.ToInt32(currentCash.Text) - Convert.ToInt32(totalReplenishCost.Text)).ToString();
                if (int_currentCash < Convert.ToInt32(totalReplenishCost.Text))
                {
                    purchaseIngredients.Enabled = false;
                }
            }
            catch
            {
                currentCash.Text = "Encountered an error!";
            }
        }
        catch
        {
            confirmPurchase.Text = "Purchase failed!";
        }
        finally
        {
            confirmPurchase.Text += " Time: " + DateTime.Now.ToString();
            con.Close();
        }


        string updateSql2 = "update  Ingredients set Ingredients.ingredient_quantity = Ingredients.ingredient_quantity + t1.future_requirement from(select Ingredients.ingredient_id, ceiling(sum(orders.quantity * recipe.ingredient_quantity) / 1.5 - Ingredients.ingredient_quantity) as future_requirement, ceiling(sum(orders.quantity * recipe.ingredient_quantity) / 1.5 - Ingredients.ingredient_quantity) * Ingredients.ingredient_price as replenish_cost from orders, items, recipe, Ingredients where orders.item_id = items.item_id and items.item_id = recipe.item_id and recipe.ingredient_id = Ingredients.ingredient_id and Orders.timestamp Between DATEADD(d, -3, GETDATE()) and GETDATE() group by Ingredients.ingredient_quantity, Ingredients.ingredient_price, Ingredients.ingredient_id having ceiling(sum(orders.quantity * recipe.ingredient_quantity) / 1.5 - Ingredients.ingredient_quantity) > 0) as t1 where t1.ingredient_id = Ingredients.ingredient_id";
        SqlCommand cmd2 = new SqlCommand(updateSql2, con);
        try
        {
            con.Open();
            int affected = cmd2.ExecuteNonQuery();
            cmd2.Dispose();
        }
        catch { }
        finally
        {
            con.Close();
        }
        consumption.DataBind();
        ingredientsRequired.DataBind();
    }

    protected void ingredientsRequired_DataBound(object sender, EventArgs e)
    {
        foreach (GridViewRow Row in ingredientsRequired.Rows)
        {
            if (Row.RowType == DataControlRowType.DataRow)
            {
                totalValue += Convert.ToInt32(Row.Cells[2].Text);
            }
        }
        totalReplenishCost.Text = totalValue.ToString();
        try
        {
            if (totalValue <= Convert.ToInt32(currentCash.Text) && totalValue > 0)
            {
                purchaseIngredients.Enabled = true;
            }
        }
        catch { }
    }
    protected void Duration_SelectedIndexChanged(object sender, EventArgs e)
    {
        expenseGridView.Visible = false;
        salesGridView.Visible = false;
        if (Duration.SelectedItem != null)
        {
            if (Duration.SelectedItem.Text == "Monthly")
            {
                foreach (ListItem li in ReportCheckBoxList.Items)
                {
                    if (li.Selected)
                    {
                        if (li.Text == "Expenses")
                        {
                            expenseGridView.Visible = true;
                            expenseGridView.DataSourceID = "monthExpenseSource";
                        }
                        else if (li.Text == "Sales")
                        {
                            salesGridView.Visible = true;
                            salesGridView.DataSourceID = "monthSalesSource";
                        }
                    }
                }
            }
            else if (Duration.SelectedItem.Text == "Weekly")
            {
                foreach (ListItem li in ReportCheckBoxList.Items)
                {
                    if (li.Selected)
                    {
                        if (li.Text == "Expenses")
                        {
                            expenseGridView.Visible = true;
                            expenseGridView.DataSourceID = "weekExpenseSource";
                        }
                        else if (li.Text == "Sales")
                        {
                            salesGridView.Visible = true;
                            salesGridView.DataSourceID = "weekSalesSource";
                        }
                    }
                }
            }
        }
        salesGridView.DataBind();
        expenseGridView.DataBind();
    }
}