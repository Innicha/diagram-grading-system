<%@page import="java.util.*,java.io.*,javazoom.upload.*,java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>
<mytag:ReadFile />
<%
try
{
    String DB   = request.getAttribute("Loadfile1").toString();
    String User = request.getAttribute("Loadfile2").toString();
    String Pass = request.getAttribute("Loadfile3").toString();
    Class.forName("com.mysql.jdbc.Driver");  
    Connection con =  DriverManager.getConnection(DB,User,Pass);
    if (MultipartFormDataRequest.isMultipartFormData(request))  
    {
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        for(int i=0 ; i < 1000 ; i++)
        {
            try
            {
                String name         = new String(mrequest.getParameter("name_"+i).getBytes("iso-8859-1"),"UTF-8").toString().trim();   
                String description  = new String(mrequest.getParameter("detail_"+i).getBytes("iso-8859-1"),"UTF-8").toString().trim();   
                String id           = new String(mrequest.getParameter("id_"+i).getBytes("iso-8859-1"),"UTF-8").toString().trim();  

                PreparedStatement psmt = con.prepareStatement("update exmaple set name=?,detail=? where id=?");
                psmt.setString(1,name);
                psmt.setString(2,description);
                psmt.setString(3,id);
                psmt.executeUpdate(); 
            }
            catch (Exception ex){}
        }
    }
    con.close(); 
    response.sendRedirect("main.jsp");
}
catch (Exception e) {}
%>