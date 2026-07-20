<%@tag import="java.io.*" pageEncoding="UTF-8"%>
<%
    try
    {
        String Loadfile[] = new String[100]; 
        String temp = application.getRealPath("/") + "\\my.conf";
        File file = new File(temp);
        BufferedReader br = new BufferedReader(new FileReader(file));
        String line;
        int i = 0;
        while ((line = br.readLine()) != null) 
        {
            Loadfile[i] = line;
            request.setAttribute("Loadfile"+i,Loadfile[i]);
            i = i + 1;
        }
        br.close();             
    }
    catch(Exception ex){}
%>   