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
            DataTable dt = new DataTable();
            dt.Columns.Add("item_id", typeof(int));
            dt.Columns.Add("name", typeof(string));
            dt.Columns.Add("price", typeof(string));
            dt.Columns.Add("quantity", typeof(int));
            Session["cartItems"] = dt;
        }
        DataTable cartItems = (DataTable)Session["cartItems"];
        displayCart(cartItems);
    }

    void displayCart(DataTable cartItems)
    {
        cart.DataSource = cartItems;
        cart.DataBind();

        List<int> itemIds = new List<int>();

        foreach (DataRow rowI in cartItems.Rows)
            itemIds.Add((int)rowI["item_id"]);

        if (itemIds.Count > 0)
        {
            SqlConnection con = new SqlConnection(WebConfigurationManager.ConnectionStrings["luigis"].ConnectionString);
            SqlCommand cmd = new SqlCommand("select Recipe.item_id, Ingredients.ingredient_id as ingredient_id, Recipe.ingredient_quantity as ingredient_quantity, Ingredients.ingredient_name as name, ingredient_price as price from Recipe, Ingredients where Ingredients.ingredient_id=Recipe.ingredient_id and Recipe.item_id in (" + String.Join(", ", itemIds) +
                ")", con);
            SqlDataAdapter adap = new SqlDataAdapter(cmd);
            DataTable cartRecipeIngredients = new DataTable();
            adap.Fill(cartRecipeIngredients);
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

            purchaseOrder.DataSource = cartRecipeIngredients;
            purchaseOrder.DataBind();
        }
    }

    protected void addToCart_Click(object sender, EventArgs e)
    {
        string item_id = items.SelectedValue;
        int itemId = int.Parse(item_id);
        if (itemDetails.Rows.Count > 0)
        {
            DataTable cartItems = (DataTable)Session["cartItems"];

            DataRow row = null;
            foreach (DataRow rowI in cartItems.Rows)
            {
                if (((int)rowI["item_id"]) == int.Parse(itemDetails.Rows[0].Cells[1].Text))
                {
                    row = rowI;
                    row["quantity"] = ((int)row["quantity"]) + int.Parse(addToCartQuantity.SelectedValue);
                    break;
                }
            }

            if (row == null)
            {
                row = cartItems.NewRow();
                cartItems.Rows.Add(row);
                row["quantity"] = int.Parse(addToCartQuantity.SelectedValue);
            }

            row["item_id"] = int.Parse(itemDetails.Rows[0].Cells[1].Text);
            row["name"] = itemDetails.Rows[1].Cells[1].Text;
            row["price"] = itemDetails.Rows[2].Cells[1].Text;

            Session["cartItems"] = cartItems;

            displayCart(cartItems);
        }
        else
        {
            cartStatus.Text = "Please select an item to be added to the cart";
        }
    }
}