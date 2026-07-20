<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="mytag" %>

<!--อ่านข้อมูลจาก config-->
<mytag:ReadFile />

<!--header หรือ rooter ให้ใช้ mytag-->
<mytag:header menu="1" />

<!-- save value and load value cross page -->
<%
    session.setAttribute("User","ไอ้ตอด");
%>

<!--Login-->
<div class="card-body">
    <form action="check_login.jsp" method="post" enctype="multipart/form-data">
        <div class="mb-3">
            <label for="title" class="form-label">User</label>
            <input type="text" class="form-control" id="user" name="user" placeholder="user">
        </div>
        <button type="submit" class="btn btn-success">Login</button>
    </form>
</div>