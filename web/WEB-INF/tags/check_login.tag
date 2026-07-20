<%@tag pageEncoding="UTF-8"%>
<%
try
{
    String s = session.getAttribute("LoginStatus_admin").toString();
    if( !s.equals("Pass_Login") )
    {
        response.sendRedirect( "index.jsp" );
    }
}
catch (Exception e)
{
    response.sendRedirect( "index.jsp" );
}
%>
