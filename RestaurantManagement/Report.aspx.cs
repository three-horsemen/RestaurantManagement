using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

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