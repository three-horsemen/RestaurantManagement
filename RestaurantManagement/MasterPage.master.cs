using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MasterPage : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            clearCookieButton.Visible = false;
            bool setFlag = false;
            if (Request.Cookies["Luigis"] != null)
            {
                if (Request.Cookies["Luigis"]["lastAccess"] != null)
                {
                    lastAccessLabel.Text = "Last accessed at: " + Request.Cookies["Luigis"]["lastAccess"].ToString();
                    clearCookieButton.Visible = true;
                    setFlag = true;
                }
            }
            if(!setFlag)
            {
                lastAccessLabel.Text = "New user detected!";
            }
            Response.Cookies["Luigis"]["lastAccess"] = DateTime.Now.ToString();
            Response.Cookies["Luigis"].Expires = DateTime.Now.AddDays(1d);
        }
        
    }

    protected void clearCookieButton_Click(object sender, EventArgs e)
    {
        Response.Cookies["Luigis"].Expires = DateTime.Now.AddDays(-1d);
        lastAccessLabel.Text = "Erased user presence!";
        clearCookieButton.Visible = false;
        //Server.TransferRequest(Request.Url.AbsolutePath, false);
    }
}
