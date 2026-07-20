<%@page import="javazoom.upload.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
try
{
    if (MultipartFormDataRequest.isMultipartFormData(request))  
    {
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        String user        = new String(mrequest.getParameter("user").getBytes("iso-8859-1"),"UTF-8").toString().trim();  
        //Connect database 
        if( user.equals("pp") )
        {
            session.setAttribute("LoginStatus_admin","Pass_Login");
            response.sendRedirect("main.jsp");
        }
        else
        {
            session.invalidate();
            response.sendRedirect("index.jsp");
        }
    }
}
catch (Exception e) { out.print(e); }
%>