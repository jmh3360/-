package org.zerock.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.zerock.domain.AttachFileDTO;

import lombok.extern.log4j.Log4j;
import net.coobird.thumbnailator.Thumbnailator;

@Controller
@Log4j
public class UploadController {
	
//	오늘 날짜 기준으로 폴더를 생성해준다 ex 2019/06/11
	private String getFolder() {
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
		
		Date date = new Date();
		
		String str = sdf.format(date);
		
		return str.replace("-", File.separator);
	}
//	파일 형채를 체크
	private boolean checkImageType(File file) {
		
		try {
			String contentType = Files.probeContentType(file.toPath());
			
			return contentType.startsWith("image");
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return false;
	}
	
	@GetMapping("/uploadForm")
	public void uploadForm() {
		
		log.info("upload form");
	}
	@PostMapping("/uploadFormAction")
	public void uploadFormPost(MultipartFile[] uploadFile, Model model) {
		String uploadFolder = "C:\\upload";
		for (MultipartFile multipartFile: uploadFile) {
			log.info("===========================================================================================");
			log.info("Upload File Name : " + multipartFile.getOriginalFilename());
			log.info("Upload File  Size : " + multipartFile.getSize());
			
			File saveFile = new File(uploadFolder,multipartFile.getOriginalFilename());
			
			try {
				multipartFile.transferTo(saveFile);
			} catch (Exception  e) {
				log.error(e.getMessage());
			}
		}// end  for
	}
	@GetMapping("/uploadAjax")
	public void uploadAjax() {
		
		log.info("upload Ajax");
	}
	@PostMapping(value="/uploadAjaxAction",produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
	@ResponseBody
	public ResponseEntity<List<AttachFileDTO>> uploadAjaxPost(MultipartFile[] uploadFile) {
		
		List<AttachFileDTO> list = new ArrayList<>();
		log.info("update ajax post.............");
		
		String uploadFolder = "C:\\upload";
		
		String uploadFolderPath = getFolder();
		// make folder -----------------------
		// 파라미터를 두개 전달한 이유는 앞에 것은 부모 디렉토리 그다음 것은 자식 디렉토리이다.
		File uploadPath = new File(uploadFolder, uploadFolderPath);
		log.info("upload path : " + uploadPath);
		
		if (uploadPath.exists() ==  false) {
			uploadPath.mkdirs();
		}
			
		for (MultipartFile multipartFile: uploadFile) {
			log.info("=====================================================================================================================");
			log.info("Upload File Name : " + multipartFile.getOriginalFilename());
			log.info("Upload File  Size : " + multipartFile.getSize());
			AttachFileDTO attachDTO = new AttachFileDTO();
			
			String uploadFileName = multipartFile.getOriginalFilename();
			//IE 버젼때문에 아래 작업을 수행해야 함
			uploadFileName = uploadFileName.substring(uploadFileName.indexOf("\\") + 1);
			log.info("only file  name : "+ uploadFileName);
			attachDTO.setFileName(uploadFileName);
			//유니크한 아이디 생성
			UUID uuid = UUID.randomUUID();
			//파일이름과 붙인다.
			uploadFileName = uuid.toString() + "_" + uploadFileName;
			
			/* File saveFile = new File(uploadFolder,uploadFileName); */
			
			try {
				//올린 파일과  동일한이름에 파일을 하나 만든다
				File saveFile = new File(uploadPath,uploadFileName);
				//잘 모름
				multipartFile.transferTo(saveFile);
				
				attachDTO.setUuid(uuid.toString());
				attachDTO.setUploadPath(uploadFolderPath);
				
				//올린 파일이  이미지 일 경우 화면에 보여줄 썸네일을 생성한다.
				if (checkImageType(saveFile)) {
					attachDTO.setImage(true);
					FileOutputStream thumbnail = new FileOutputStream(new File(uploadPath,"s_" +uploadFileName));
					Thumbnailator.createThumbnail(multipartFile.getInputStream(),thumbnail,100,100);
					thumbnail.close();
				}
				list.add(attachDTO);
			} catch (Exception  e) {
				log.error(e.getMessage());
			}
		}// end  for
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	@GetMapping("/display")
	@ResponseBody
	public ResponseEntity<byte[]> getFile(String fileName){
		log.info("fileName : " + fileName);
		
		File file = new File("C:\\upload\\" +fileName);
		
		log.info("file : " + file);
		
		ResponseEntity<byte[]>  result =  null;
		
		try {
			HttpHeaders  header =  new HttpHeaders();
			header.add("Content-Type", Files.probeContentType(file.toPath()));
			result = new ResponseEntity<>(FileCopyUtils.copyToByteArray(file),header,HttpStatus.OK);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return result;
	}
	@GetMapping(value="/download",produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	@ResponseBody
	public ResponseEntity<Resource> downloadFile(@RequestHeader("User-Agent")String userAgent, String fileName){
		
		log.info("download file : " + fileName);
		Resource resource = new FileSystemResource("c:\\upload\\"+fileName);
		if (resource.exists() ==false) {
			return new ResponseEntity<>(HttpStatus.NOT_FOUND);
		}
		
		log.info("resources : " +resource);
		String resoureceName = resource.getFilename();
//		remove  UUID
		String resourceOriginalName = resoureceName.substring(resoureceName.indexOf("_")+1);
		HttpHeaders headers = new HttpHeaders();
		try {
			String downloadName = null;
			if (userAgent.contains("Trident")) {
				log.info("IE Browser");
				downloadName  = URLEncoder.encode(resourceOriginalName,"UTF-8").replaceAll("\\\\", " ");
				
			}else if(userAgent.contains("Edge")) {
				log.info("Edge browser");
				downloadName  = URLEncoder.encode(resourceOriginalName,"UTF-8");
				log.info("Edge name :  " + downloadName);
			}else {
				log.info("Chrome brower");
				downloadName = new String(resourceOriginalName.getBytes("UTF-8"),"ISO-8859-1");
			}
			headers.add("Content-disposition", "attachment; filename="+downloadName);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return new ResponseEntity<Resource>(resource,headers,HttpStatus.OK);
	}
	@PostMapping("/deleteFile")
	@ResponseBody
	public ResponseEntity<String> deleteFile(String fileName, String type){
		
		log.info("deleteFile : " + fileName);
		
		File file;
		
		try {
			file = new File("c:\\upload\\"+URLDecoder.decode(fileName, "UTF-8"));
			file.delete();
			if (type.equals("image")) {
				String largeFileName = file.getAbsolutePath().replace("s_"," ");
				log.info("largeFile Name : "+largeFileName);
				file = new File(largeFileName);
				file.delete();
			}
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return new ResponseEntity<String>(HttpStatus.NOT_FOUND);
		}
		return new ResponseEntity<>("delete",HttpStatus.OK);
	}
}
