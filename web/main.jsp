<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>
<mytag:ReadFile />
<mytag:header menu="2" />

<!-- Check Login File -->
<!--if not login Go To first page-->
<mytag:check_login />  

<%
    String Link   = request.getAttribute("Loadfile5").toString();  
%>

<br>
<!--ต่อ database MYSQL-->
<form action="edit.jsp" method="post" enctype="multipart/form-data">
    <table class="table table-bordered table-hover align-middle">
        <thead class="table-secondary">
            <tr>
                <th>ชื่อไฟล์ จาก DATABASE</th>
                <th>รายละเอียด จาก DATABASE</th>
                <th>เลือกไฟล์ จาก DATABASE</th>
                <th>ข้อความซ่อนใน form</th>
                <th>Save ข้อความ จาก Page1</th>
                 <th>Delete</th>
            </tr>
        </thead>
        <tbody>
<%
        try
        {
            int num = 1;
            String DB   = request.getAttribute("Loadfile1").toString();
            String User = request.getAttribute("Loadfile2").toString();
            String Pass = request.getAttribute("Loadfile3").toString();
            Class.forName("com.mysql.jdbc.Driver");        
            Connection con =  DriverManager.getConnection(DB,User,Pass);
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM exmaple");          
            while( rs.next() )
            {
%>            
                <tr>
                    <td><input name="name_<%=num%>" class="form-control" value='<%=rs.getString("name")%>'></td>
                    <td><input name="detail_<%=num%>" class="form-control" value='<%=rs.getString("detail")%>'></td>
                    <td><img src="<%=Link%><%=rs.getString("pic")%>" class="img-thumbnail" width="100"></td>
                    <td><%=session.getAttribute("send_value_from")%></td>
                    <td><%=session.getAttribute("User")%></td>
                    <td><a href="delete.jsp?id=<%=rs.getString("id")%>" class="btn btn-danger btn-sm"  onclick="return confirm('ต้องการลบหรือไม่');"> X </a></td>
                    <input type="hidden" name="id_<%=num%>" value='<%=rs.getString("id")%>'/>
                </tr>
<%           
                num = num + 1;
            }     
            con.close(); 
        }
        catch (Exception e){ out.print(e); }
%>

         </tbody>
    </table>
    <button type="submit" class="btn btn-success">Edit</button>
</form>

<!-- form and file--> 
<div class="card-body">
    <form action="upload.jsp" method="post" enctype="multipart/form-data">
        <div class="mb-3">
            <label for="title" class="form-label">ชื่อไฟล์</label>
            <input type="text" class="form-control" name="name" placeholder="กรอกชื่อไฟล์">
        </div>
        <div class="mb-3">
            <label for="detail" class="form-label">รายละเอียด</label>
            <textarea class="form-control" name="detail" rows="4"></textarea>
        </div>
        <div class="mb-3">
            <label for="file" class="form-label">เลือกไฟล์</label>
            <input class="form-control" type="file" id="file" name="file">
        </div>
        <button type="submit" class="btn btn-primary">Upload</button>
        <input type="hidden" name="send_value_from" value="ส่งข้อมูลมาเก็บ แอบซ่อนเอาไว้ โดย Form" />
        
<%
    out.print("<input type='hidden' name='send_value_inside' value='ส่งข้อมูลมาเก็บ แอบซ่อนเอาไว้ ภายในโดย JSP' />");
%>        
        
    </form>
</div>        

<div class="card-body">
    <form action="logout.jsp" method="post" enctype="multipart/form-data">
        <button type="submit" class="btn btn-danger">Logout</button>
    </form>
</div>

<!--run python-->
<div class="card-body">
    <form action="run_python.jsp" method="post" enctype="multipart/form-data">
        <button type="submit" class="btn btn-secondary">RUN PYTHON</button>
    </form>
</div>


<!-- Graph ใช้ RGraph -->
<script src="libG2/RGraph.svg.common.core.js" ></script>
<script src="libG2/RGraph.svg.common.tooltips.js" ></script>
<script src="libG2/RGraph.svg.pie.js" ></script>

<div style="height: 400px; width: 800px" id="x0"></div><br>
<%
    String data = "labels: ['Alex111','Doug222','Charle333s','Nick444'],";
    String tooltips = " tooltips: ['ข้อความ <br> ประเทศไทย','two','three','four'],";
%>
<script>    
    new RGraph.SVG.Pie({
    id: 'x0',
    data: [10,20,30,40],
    options: 
    {
         exploded: 5,
         donut: true,
         shadow: false,
         title: 'ข้อความ',
         <%=data%>
         <%=tooltips%>
         colors: ['red','blue','green','yellow'],
         donutWidth: 50,         
         tooltipsEvent:'mousemove'
    }
 }).roundRobin();
</script> 