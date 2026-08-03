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
                    <li class="nav-item"><a class="nav-link" href="Features_Flowchart.jsp">Flowchart</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_ERdiagram.jsp">ER Diagram</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Pseudocode.jsp">Pseudocode</a></li>
                    <li class="nav-item"><a class="nav-link" href="CreateAnswerkeys.jsp">Create Answer Keys</a></li>
                <% } else if(menu.equals("2")){ %>
                    <li class="nav-item"><a class="nav-link" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link active" href="main.jsp">MAIN</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Flowchart.jsp">Flowchart</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_ERdiagram.jsp">ER Diagram</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Pseudocode.jsp">Pseudocode</a></li>
                    <li class="nav-item"><a class="nav-link" href="CreateAnswerkeys.jsp">Create Answer Keys</a></li>
                <% } else if(menu.equals("3")){ %>
                    <li class="nav-item"><a class="nav-link" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link" href="main.jsp">MAIN</a></li>
                    <li class="nav-item"><a class="nav-link active" href="Features_Flowchart.jsp">Flowchart</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_ERdiagram.jsp">ER Diagram</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Pseudocode.jsp">Pseudocode</a></li>
                    <li class="nav-item"><a class="nav-link" href="CreateAnswerkeys.jsp">Create Answer Keys</a></li>
                <% } else if(menu.equals("4")){ %>
                    <li class="nav-item"><a class="nav-link" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link" href="main.jsp">MAIN</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Flowchart.jsp">Flowchart</a></li>
                    <li class="nav-item"><a class="nav-link active" href="Features_ERdiagram.jsp">ER Diagram</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Pseudocode.jsp">Pseudocode</a></li>
                    <li class="nav-item"><a class="nav-link" href="CreateAnswerkeys.jsp">Create Answer Keys</a></li>
                <% } else if(menu.equals("5")){ %>
                    <li class="nav-item"><a class="nav-link" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link" href="main.jsp">MAIN</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Flowchart.jsp">Flowchart</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_ERdiagram.jsp">ER Diagram</a></li>
                    <li class="nav-item"><a class="nav-link active" href="Features_Pseudocode.jsp">Pseudocode</a></li>
                    <li class="nav-item"><a class="nav-link" href="CreateAnswerkeys.jsp">Create Answer Keys</a></li>
                <% } else{ %>
                    <li class="nav-item"><a class="nav-link" href="index.jsp">INDEX</a></li>
                    <li class="nav-item"><a class="nav-link" href="main.jsp">MAIN</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Flowchart.jsp">Flowchart</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_ERdiagram.jsp">ER Diagram</a></li>
                    <li class="nav-item"><a class="nav-link" href="Features_Pseudocode.jsp">Pseudocode</a></li>
                    <li class="nav-item"><a class="nav-link active" href="CreateAnswerkeys.jsp">Create Answer Keys</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="./js/bootstrap.bundle.min.js"></script>