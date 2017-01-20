using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Web.Security;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;

public partial class _Default : System.Web.UI.Page 
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string username = Request.LogonUserIdentity.Name.ToLower().Substring(Request.LogonUserIdentity.Name.ToLower().IndexOf('\\')+1, Request.LogonUserIdentity.Name.Length - Request.LogonUserIdentity.Name.ToLower().IndexOf('\\')-1);
            txtbox_username.Text = username;
            if (IsAdmin(username) == true)
	            {
                    div_newDrive.Visible = true;   
	            };
        }
    }

    protected void btn_search_Click(object sender, EventArgs e)
    {
        //SqlDataSource s = (SqlDataSource)MasterPageForm.FindControl("sds_FolderOwners");

        GridView gv = (GridView)MasterPageForm.FindControl("gv_folder");

        gv.DataBind();
    }


    protected void btn_SubmitNewPath_Click(object sender, EventArgs e)
    {
        SqlDataSource s = (SqlDataSource)MasterPageForm.FindControl("sds_FolderOwners");
        s.InsertParameters[0].DefaultValue = txtbox_NewPath.Text;
        s.Insert();

        GridView gv = (GridView)MasterPageForm.FindControl("gv_folder");

        gv.DataBind();
    }

    [System.Web.Script.Services.ScriptMethod()]
    [System.Web.Services.WebMethod]
    public static List<string> SearchCustomers(string prefixText, int count)
    {
        using (SqlConnection conn = new SqlConnection())
        {

            conn.ConnectionString = ConfigurationManager
                    .ConnectionStrings["ServerConnection"].ConnectionString;
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandText = "SELECT Name FROM [slc].[users] where " +
                "Name like @SearchText + '%'";
                cmd.Parameters.AddWithValue("@SearchText", prefixText);
                cmd.Connection = conn;
                conn.Open();
                List<string> customers = new List<string>();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                        customers.Add(sdr["Name"].ToString());
                    }
                }
                conn.Close();
                return customers;
            }
        }
    }


    public static string GetImage(bool value)
    {
//        int x = Int32.Parse(value);

        if (value == false)
        {
            return "../App_data/yes10.png";
        }
        else
        {
            return "../App_data/no10.png";
        }
    }

    public bool IsAdmin(string username)
    {
        bool return_val ;
        using (SqlConnection conn = new SqlConnection())
        {
            conn.ConnectionString = ConfigurationManager.ConnectionStrings["ServerConnection"].ConnectionString;
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandText = "DECLARE	@return_value int;EXEC	@return_value = [slc].[VerifyIfAdmin] @user = @user; SELECT	'Return Value' = @return_value";
                cmd.Parameters.AddWithValue("@user", username);
                cmd.Connection = conn;
                conn.Open();

                return_val = Convert.ToBoolean(cmd.ExecuteScalar());

                conn.Close();
            }
        }

        return return_val;
    }

    protected void sds_FolderOwners_Selecting(object sender, SqlDataSourceSelectingEventArgs e)
    {

    }
}


