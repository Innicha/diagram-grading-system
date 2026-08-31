<%@tag pageEncoding="UTF-8"%>
<%@attribute name="menu" required="true"%> 

<link href="./css/bootstrap.min.css" rel="stylesheet">

<nav class="navbar navbar-expand-lg navbar-dark custom-navbar">
    <div class="container">
        <div class="collapse navbar-collapse" id="navbarMenu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link <%= "1".equals(menu) ? "active" : "" %>" href="index.jsp">INDEX</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= "2".equals(menu) ? "active" : "" %>" href="AddSubjects.jsp">Assign Assignment</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= "3".equals(menu) ? "active" : "" %>" href="AddSection.jsp">Add Section</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= "4".equals(menu) ? "active" : "" %>" href="DesignAnswerkeys.jsp">Design Answer Key</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= "5".equals(menu) ? "active" : "" %>" href="CreateAnswerkeys.jsp">Create Answer Keys</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<style>
  .custom-navbar {
      background-color: #044c93 !important;
  }
  .custom-navbar .nav-link {
      color: rgba(255, 255, 255, 0.7) !important;
      border-bottom: 2px solid transparent;
      transition: all 0.2s ease-in-out;
  }
  .custom-navbar .nav-link:hover {
      color: #ffffff !important;
  }
  .custom-navbar .nav-link.active {
      color: #ffffff !important;
      font-weight: bold;
  }
</style>

<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="./js/bootstrap.bundle.min.js"></script>