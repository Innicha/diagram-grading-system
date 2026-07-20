<%@tag pageEncoding="UTF-8"%>
<%@attribute name="menu" required="true"%> 
<link href="./css/bootstrap.min.css" rel="stylesheet">
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <div class="collapse navbar-collapse" id="navbarMenu">
            <ul class="navbar-nav ms-auto">
                <% if( menu.equals("1") ) { %>
                    <li class="nav-item"><a class="nav-link active" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link" href="main.jsp">MAIN</a></li>
                <% } else { %>
                    <li class="nav-item"><a class="nav-link" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link active" href="main.jsp">MAIN</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
<script src="./js/bootstrap.bundle.min.js"></script>