<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-type" content="text/html; charset= UTF-8" charset="UTF-8">
<style>
	.uploadResult {
		width: 100%;
		background-color: gray;
	}
	.uploadResult ul{
		display: flex;
		flex-flow: row;
		justify-content: center;
		align-items: center;
	}
	.uploadResult ul li {
		list-style: none;
		padding: 10px;
	}
	.uploadResult ul li img{
		width: 20px;
	}
</style>
<title>Insert title here</title>
</head>
<body>
	<div class="uploadDiv">
	<input type="file" name="uploadFile" multiple/>
	</div>
	<button id="uploadBtn">Upload</button>
	<div class="uploadResult">
		<ul></ul>
	</div>
	<script
  src="https://code.jquery.com/jquery-3.4.1.js" integrity="sha256-WpOohJOqMqqyKL9FccASB9O0KwACQJpFTUBLTYOVvVU=" crossorigin="anonymous">
	</script>
		
<script>
$(document).ready(function(){
	var regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
	var maxSize = 5242880; //5MB
	var cloneObj = $(".uploadDiv").clone();
	var uploadResult = $(".uploadResult ul");
	
	function showUploadedFile(uploadResultArr){
		var str = "";
		console.log(uploadResultArr);
		$(uploadResultArr).each(function(i,obj){
			if (!obj.image) {
			str +=  "<li><img src='/resources/img/attach.png'>"+obj.fileName+"</li>"
			} else {
				/* str += "<li>"+obj.fileName+"</li>"; */
				var fileCallPath = encodeURIComponent(obj.uploadPath + "/s_"+obj.uuid+"_"+obj.fileName);
				console.log(fileCallPath);
				str +=  "<li>	<img src='/display?fileName="+fileCallPath+"'>"+obj.fileName+"</li>"
			}
		});
		console.log(str);
		uploadResult.append(str);
	}
	
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
				showUploadedFile(result);
				$(".uploadDiv").html(cloneObj.html());
			}
		});
		
	});
});
</script>
</body>
</html>