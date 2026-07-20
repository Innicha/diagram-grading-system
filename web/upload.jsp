<%@page import="java.util.*,java.io.*,javazoom.upload.*,java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>
<mytag:ReadFile />
<%
try
{
    String path   = request.getAttribute("Loadfile4").toString();  
    if (MultipartFormDataRequest.isMultipartFormData(request))  
    {
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);

        //Gen Data
        String name        = new String(mrequest.getParameter("name").getBytes("iso-8859-1"),"UTF-8").toString().trim();   
        String detail  = new String(mrequest.getParameter("detail").getBytes("iso-8859-1"),"UTF-8").toString().trim();   
        String send_value_from  = new String(mrequest.getParameter("send_value_from").getBytes("iso-8859-1"),"UTF-8").toString().trim();   

        //SAVE FILE
        Hashtable files = mrequest.getFiles();
        UploadFile img = (UploadFile) files.get("file");
        InputStream readImg = img.getInpuStream();
        File T = new File( path+img.getFileName() );
        FileOutputStream fout = new FileOutputStream(T);
        byte[] buffer = new byte[1024];
        for (int length ; (length = readImg.read(buffer)) > 0 ; )  
        {
            fout.write(buffer, 0, length);
        }
        readImg.close();
        fout.close();
        
        //Save DATA
        session.setAttribute("send_value_from",send_value_from);
        
        
        //Save Database
        String DB   = request.getAttribute("Loadfile1").toString();
        String User = request.getAttribute("Loadfile2").toString();
        String Pass = request.getAttribute("Loadfile3").toString();
        Class.forName("com.mysql.jdbc.Driver");        
        Connection con =  DriverManager.getConnection(DB,User,Pass);
        PreparedStatement psmt = con.prepareStatement("insert into exmaple(name,detail,pic) values(?,?,?)");
        psmt.setString(1,name);
        psmt.setString(2,detail);
        psmt.setString(3,img.getFileName());
        psmt.executeUpdate(); 
        con.close(); 
        
        response.sendRedirect("main.jsp");
    }
}
catch (Exception e) { out.print(e); }
%>