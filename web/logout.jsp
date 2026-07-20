<%@page contentType="text/html" pageEncoding="UTF-8" language="java" %>
<%
    try 
    {      
        session.invalidate();
        response.sendRedirect("index.jsp");
    }
    catch(Exception ex){}
%>      