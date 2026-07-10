<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if(session.getAttribute("xloggedx") == null || !"true".equals(session.getAttribute("xloggedx"))) {
        response.sendRedirect(request.getContextPath());
        return;
    }
    response.sendRedirect("greport.jsp");
%>
