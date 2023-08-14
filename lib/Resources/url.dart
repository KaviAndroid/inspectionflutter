//Local 140:8080
/*Uri login=Uri.parse('http://10.163.19.140:8080/rdweb/project/webservices_forms/login_service/login_services.php');
Uri master_service=Uri.parse('http://10.163.19.140:8080/rdweb/project/webservices_forms/master_services/master_services.php');
Uri main_service=Uri.parse('http://10.163.19.140:8080/rdweb/project/webservices_forms/work_inspection/inspection_services.php');
Uri open_service=Uri.parse('http://10.163.19.140:8080/rdweb/project/webservices_forms/open_services/open_services.php');*/

//Local URL 137:8090
String endPointURL = "http://10.163.19.137:8090/tnrd/project/webservices_forms";

// Live URL
// String endPointURL = "https://tnrd.tn.gov.in/project/webservices_forms";

Uri login = Uri.parse('$endPointURL/login_service/login_services.php');
Uri master_service =
    Uri.parse('$endPointURL/master_services/master_services_v_1_6.php');
Uri main_service =
    Uri.parse('$endPointURL/work_inspection/inspection_services_v_1_6.php');
Uri main_service_jwt =
    Uri.parse('$endPointURL/work_inspection/inspection_services_v_1_9_jwt.php');
Uri open_service = Uri.parse('$endPointURL/open_services/open_services.php');
