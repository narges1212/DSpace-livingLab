//println request.getQueryString()
import javax.servlet.http.*
response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
response.setHeader("Location", "http://ssoar.info/OAIHandler/request?" + request.getQueryString());
