<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My access page</title>
</head>
<body>
    <form id="MasterPageForm" runat="server">
        <ajaxToolkit:ToolkitScriptManager ID="ScriptManager1" runat="server" />
        <div>
            <div id="master_header">
                <asp:Label runat="server" Text="My access"></asp:Label>
            </div>
            <br />
            <div id="master_content">
                <asp:SqlDataSource runat="server" OnSelecting="sds_FolderOwners_Selecting" ID="sds_FolderOwners" ConnectionString="<%$ConnectionStrings:ServerConnection %>" ProviderName="System.Data.SqlClient" 
                    SelectCommand="exec slc.selectApprovers @Updateby,@Scope" 
                    UpdateCommand="exec slc.UpdateApprovers @DriveName,@Approver1,@Approver2,@Updateby"
                    InsertCommand="exec slc.InsertApprovers @DriveName,@Updateby" 
                    DeleteCommand="Delete from [slc].[Approvers] where [DriveName]=@DriveName">
                    <SelectParameters>
                        <asp:ControlParameter name="Updateby" Type="String" ControlID="txtbox_username" />
                        <asp:ControlParameter Name="Scope" Type="String" ControlID="txtbox_search" DefaultValue=" " />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="Approver1"  Type="String" />
                        <asp:Parameter Name="Approver2"  Type="String" />
                        <asp:Parameter Name="DriveName" Type="String" />
                        <asp:ControlParameter name="Updateby" Type="String" ControlID="txtbox_username" />
                    </UpdateParameters>
                    <InsertParameters>
                        <asp:Parameter Name="DriveName" Type="String" />
                        <asp:ControlParameter name="Updateby" Type="String" ControlID="txtbox_username" />
                    </InsertParameters>
                    <DeleteParameters>
                        <asp:Parameter Name="DriveName" Type="String" />
                    </DeleteParameters>
                </asp:SqlDataSource>
                <table id="tbl_search">
                    <tr>
                        <td>
                            <asp:TextBox ID="txtbox_search" runat="server" ToolTip="Search for a folder name." Text=""></asp:TextBox>
                        </td>
                        <td>
                            <asp:Button ID="btn_search" runat="server" Text="Search" OnClick="btn_search_Click"/>
                        </td>
                    </tr>
                </table>
                <br />
                <asp:GridView runat="server" ID="gv_folder" DataSourceID="sds_FolderOwners" AutoGenerateColumns="false" DataKeyNames="DriveName" AllowPaging="true" AllowSorting="true" PageSize="50">
                    <Columns>
                        <asp:TemplateField HeaderText="DriveName" SortExpression="DriveName">
                            <ItemTemplate>
                                <asp:Label ID="lbl_DriveName" runat="server" Text='<%# Bind("DriveName") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:Label ID="lbl_DriveName" runat="server" Text='<%# Bind("DriveName") %>'></asp:Label>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Approver" SortExpression="Approver1">
                            <ItemTemplate>
                                <asp:Label ID="lbl_Approver" runat="server" Text='<%# Bind("Approver1") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtBox_Approver" runat="server" Text='<%# Bind("Approver1") %>'></asp:TextBox>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace_approver1"  TargetControlID="txtBox_Approver" 
                                    ServiceMethod="SearchCustomers" MinimumPrefixLength="2" CompletionInterval="100" CompletionSetCount="10" EnableCaching="false" FirstRowSelected="false"></ajaxToolkit:AutoCompleteExtender>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Alternate Approver" SortExpression="Approver2">
                            <ItemTemplate>
                                <asp:Label ID="lbl_Approver2" runat="server" Text='<%# Bind("Approver2") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtBox_Approver2" runat="server" Text='<%# Bind("Approver2") %>'></asp:TextBox>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace_approver2"  TargetControlID="txtBox_Approver2" 
                                    ServiceMethod="SearchCustomers" MinimumPrefixLength="2" CompletionInterval="100" CompletionSetCount="10" EnableCaching="false" FirstRowSelected="false"></ajaxToolkit:AutoCompleteExtender>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:CommandField ShowEditButton="true"/>
                        <asp:CommandField ShowDeleteButton="true" />
                        
                    </Columns>

                </asp:GridView>
                <br />
                <div id="div_newDrive" runat="server" visible="false">
                    <table id="tbl_NewDrive">
                        <tr>
                            <td>
                                <asp:Label ID="Label1" Text="Create new G-drive folder" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:TextBox ID="txtbox_NewPath" runat="server" Text="" MaxLength="255"></asp:TextBox>
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btn_SubmitNewPath" Text="Submit" OnClick="btn_SubmitNewPath_Click" OnClientClick="alert('Value submitted');"/>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="footer">
                <div>
                    <asp:TextBox runat="server" Visible="false" ReadOnly="true" ID="txtbox_username"></asp:TextBox>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
