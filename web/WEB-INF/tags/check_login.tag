<%@tag pageEncoding="UTF-8"%>
<%
try
{
    // เช็กว่ามี session "User" ที่เซ็ตมาจาก check_login.jsp หรือไม่
    String user = (String) session.getAttribute("User");
    
    if( user == null || user.trim().isEmpty() )
    {
        response.sendRedirect( "index.jsp" );
    }
}
catch (Exception e)
{
    response.sendRedirect( "index.jsp" );
}
%>