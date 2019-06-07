<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset= UTF-8" charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<div class="uploadDiv">
	<input type="file" name="uploadFile" multiple/>
	</div>
	<button id="uploadBtn">Upload</button>
	<script
  src="https://code.jquery.com/jquery-3.4.1.js" integrity="sha256-WpOohJOqMqqyKL9FccASB9O0KwACQJpFTUBLTYOVvVU=" crossorigin="anonymous">
	</script>
		
<script>
$(document).ready(function(){
	var regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
	var maxSize = 5242880; //5MB
	
	function checkExtension(fileName, fileSize){
		if (fileSize >= maxSize) {
			alert("파일사이즈 초과");
			return false;
		}
		
		if (regex.test(fileName)) {
			alert("해당 종류의 파일은 업로드할 수 없습니다.");
			return false;
		}
		return true;
	}
	
	$('#uploadBtn').click(function(e){
		var formData = new FormData();
		var inputFile =$("input[name='uploadFile']");
		var files = inputFile[0].files;
		console.log(files);
		
		for (var i = 0; i < files.length; i++) {
			
			if (!checkExtension(files[i].name, files[i].size)) {
				return false;
			}
			
			formData.append("uploadFile",files[i]);
		}
		
		$.ajax({
			url:'/uploadAjaxAction',
			processData:false,
			contentType:false,
			data:formData,
			type:'POST',
			success:function(result){
				alert("Uploaded");
			}
		});
		
	});
});
</script>
</body>
</html>