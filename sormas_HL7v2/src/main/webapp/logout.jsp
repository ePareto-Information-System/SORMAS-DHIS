<%
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/fhir_frontend/lockpage.jsp");
%>