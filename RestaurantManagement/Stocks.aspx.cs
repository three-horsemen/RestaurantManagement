using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Web.Configuration;

public partial class _Default : System.Web.UI.Page
{
    public int totalValue = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
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
            if (totalValue <= Convert.ToInt32(currentCash.Text))
            {
                purchaseIngredients.Enabled = true;
            }
        }
        catch {}
    }
}