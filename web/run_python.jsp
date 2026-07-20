<%@page import="org.codehaus.plexus.util.cli.CommandLineUtils.*,org.codehaus.plexus.util.cli.*,java.io.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>
<mytag:ReadFile />
<%
    try
    {
        //Run Python file
        String run_bat_file   = request.getAttribute("Loadfile6").toString();
        String run_bat_py   = request.getAttribute("Loadfile7").toString();
        
        //create file
        FileWriter out2 = new FileWriter(run_bat_file);         
        BufferedWriter bw = new BufferedWriter(out2);        
        bw.write("@echo off");                                                                  
        bw.newLine();                                                                     
        bw.write( "python \"" + run_bat_py +"\"");    
        bw.newLine();   
        bw.close();        
        out2.close();    
        
        //run bat file
        Commandline commandLine = new Commandline();
        commandLine.setExecutable(run_bat_file);
        StringStreamConsumer outputConsumer = new StringStreamConsumer();
        StringStreamConsumer errorConsumer = new StringStreamConsumer();
        CommandLineUtils.executeCommandLine(commandLine, outputConsumer, errorConsumer);

        String print_put = outputConsumer.getOutput();
        String error_out = errorConsumer.getOutput();
        
        out.print(print_put + " " + error_out);
        
        File f = new File(run_bat_file);
        f.delete();
    }
    catch (Exception e)
    {
    }
%>
<div class="card-body">
    <form action="logout.jsp" method="post" enctype="multipart/form-data">
        <button type="submit" class="btn btn-danger">Logout</button>
    </form>
</div>
