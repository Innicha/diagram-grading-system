<%@page import="java.util.*,java.io.*,javazoom.upload.*,java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>
<mytag:ReadFile />
<%
try
{
    String path   = request.getAttribute("Loadfile4").toString();  
    String id     = request.getParameter("id").toString().trim();   
    
    String DB   = request.getAttribute("Loadfile1").toString();
    String User = request.getAttribute("Loadfile2").toString();
    String Pass = request.getAttribute("Loadfile3").toString();
    Class.forName("com.mysql.jdbc.Driver");  
    
    
    //Delte file
    Connection c1 =  DriverManager.getConnection(DB,User,Pass);
    Statement s1 = c1.createStatement();
    ResultSet r1 = s1.executeQuery("SELECT * FROM exmaple where id = " + id);          
    while( r1.next() )
    {
        File f = new File( path +  r1.getString("pic") );
        f.delete();
    }
    c1.close();
    
    //Delete Database    
    Connection con =  DriverManager.getConnection(DB,User,Pass);
    PreparedStatement psmt = con.prepareStatement("delete from exmaple where id=?");
    psmt.setString(1,id);
    psmt.executeUpdate(); 
    con.close(); 

    response.sendRedirect("main.jsp");
}
catch (Exception e) { out.print(e); }
%>