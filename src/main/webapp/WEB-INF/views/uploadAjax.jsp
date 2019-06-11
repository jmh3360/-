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
		align-content: center;
		text-align: center;
	}
	.uploadResult ul li img{
		width: 100px;
	}
	.uploadResult ul li span{
		color: white;
	}
	.bigPictureWrapper{
		position:absolute;
		display: none;
		justify-content: center;
		align-items: center;
		top: 0%;
		width: 100%;
		height: 100%;
		background-color: gray;
		z-index: 100;
		background: rgba(255,255,255,0.5);
	}
	.bigPicture img{
		width: 600px;
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
	<div class="bigPictureWrapper">
		<div class="bigPicture"></div>
	</div>
	<script
  src="https://code.jquery.com/jquery-3.4.1.js" integrity="sha256-WpOohJOqMqqyKL9FccASB9O0KwACQJpFTUBLTYOVvVU=" crossorigin="anonymous">
	</script>
				
<script>
//원본 이미지 보여주기 원본 이미지를 보여줄 div 생성
function showImage(fileCallPath){
	//alert(fileCallPath);
	$(".bigPictureWrapper").css("display","flex").show();
	
	$(".bigPicture").html("<img src='/display?fileName="+encodeURI(fileCallPath)+"' />").animate({width:'100%',height:'100%'}, 1000);
}
$(document).ready(function(){
	var regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
	var maxSize = 5242880; //5MB
	var cloneObj = $(".uploadDiv").clone();
	var uploadResult = $(".uploadResult ul");
	$(".bigPictureWrapper").on("click",function(e){
		$(".bigPicture").animate({width:'0%',height:'0%'},1000);
			$(this).hide();
	});
	
	$(".uploadResult").on("click","span",function(e){
		var targetFile = $(this).data("file");
		var type =$(this).data("type");
		console.log(targetFile);
		
		$.ajax({
			url: '/deleteFile',
			data:{fileName:targetFile, type:type},
			dataType : 'text',
			type:'POST',
			success:function(result){
				console.log(result);
			}
		});
	});
	
	//클릭 시 다운로드 실행 
	//src에 controller 주소를 넣어  주면 컨트롤러 호출 된다 신기방기
	function showUploadedFile(uploadResultArr){
		var str = "";
		console.log(uploadResultArr);
		$(uploadResultArr).each(function(i,obj){
			if (!obj.image) {
				var fileCallPath = encodeURIComponent(obj.uploadPath+"/"+obj.uuid+"_"+obj.fileName); 
				var fileLink = fileCallPath.replace(new RegExp(/\\/g),"/");
				
				str +=  "<li><div><a href='/download?fileName="+fileCallPath+"'><img src='/resources/img/attach.png'>"+obj.fileName+"</a>"
						+"<span data-file=\'"+fileCallPath+"'\ data-type='file'>x</span></div></li>"
			} else {
				/* str += "<li>"+obj.fileName+"</li>"; */
				var fileCallPath = encodeURIComponent(obj.uploadPath + "/s_"+obj.uuid+"_"+obj.fileName);
				console.log(fileCallPath);
				var originPath = obj.uploadPath+"\\"+obj.uuid+"_"+obj.fileName;
				originPath = originPath.replace(new RegExp(/\\/g),"/");
				
				/* str +=  "<li><a href='/download?fileName="+fileCallPath+"'><img src='/display?fileName="+fileCallPath+"'></a></li>" */
				str += "<li><a href=\javascript:showImage(\'"+originPath+"\')\><img src='/display?fileName="+fileCallPath+"'></a>"+
						"<span data-file=\'"+fileCallPath+"'\ data-type='image'>x</span> </li>";
			}
		});
		console.log(str);
		uploadResult.append(str);
	}
	/* 파일 벨리데이션  체크 */
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