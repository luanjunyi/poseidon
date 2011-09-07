package ask_google;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Random;
import java.util.logging.Logger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlElement;
import com.gargoylesoftware.htmlunit.html.HtmlPage;

public class Ask_Google {	
	/**
	 * 
	 * @param keyword the keyword to search
	 * @param needs the number of returned urls
	 * @param callback the callback function to deal each url
	 * @param sleep_min the min time(second) to sleep after a search
	 * @param sleep_max the min time(second) to sleep after a search
	 * @param logger the logger
	 */
	public ArrayList<String> ask_Google(String keyword,int needs,CallBackFunction callback,int sleep_min,int sleep_max,Logger logger){
		WebClient client = new WebClient();
		HtmlPage page = null;
		boolean exit = false;
		Random random = new Random(System.currentTimeMillis());
		int try_time,curPage=1;
		ArrayList<String> urlList = new ArrayList<String>();
		String url="";
		client.setJavaScriptEnabled(false);
		client.setThrowExceptionOnScriptError(false);
		
		if(logger!=null)
			logger.info("search "+keyword+" for "+needs+" results from google");
		//encode the keyword 
		try {
			keyword = URLEncoder.encode(keyword,"utf-8");
			url ="http://www.google.com/search?q="+keyword;
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			if(logger!=null)
					logger.severe("ask_google encode keyword failed , keyword="+keyword);
			return urlList;
		}
		
		OuterLoop:while(urlList.size()<needs && !exit){
			try_time = 5;
			exit = true;
			//open one page
			while((try_time--)>0){
				try {
					if(curPage==1){
						page = client.getPage(url);
						exit = false;
					}else{
						for(HtmlElement element:page.getElementsByTagName("a")){
							if(element.getAttribute("id").equalsIgnoreCase("pnnext")){
								page = element.click();
								exit = false;
								break;
							}
						}
					}
					break;
				} catch (Exception e){
					if(try_time<=0){
						if(logger!=null)
							logger.severe("ask_google fetching failed:"+url);
						break OuterLoop;
					}
				}finally{
					if(page!=null && page.getWebResponse()!=null && page.getWebResponse().getStatusCode()==503){
						logger.severe("503 encoutered, I\'ll quit and the sever should take a rest too.");
					}
				}
			}
			//parse one page
			try{
				for(HtmlElement element:page.getElementsByTagName("li")){
					if(!element.getAttribute("class").equalsIgnoreCase("g"))
						continue;
					String link =element.getElementsByTagName("a").get(0).getAttribute("href");
					if(link.toLowerCase().startsWith("http://") && urlList.size()<needs){
						urlList.add(link);
						if(callback!=null)
							callback.deal_one_url(link);
					}
				}
			}catch(Exception e){}
			//sleep a while
			try {
				if(urlList.size()<needs && !exit){
					int sec = sleep_min+random.nextInt(sleep_max-sleep_min);
					logger.info("ask_google sleep "+sec+" s, result("+urlList.size()+")");
					Thread.sleep(sec*1000);
				}
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				if(logger!=null)
					logger.severe("ask_google sleep failed");
			}
			curPage++;
		}//end of while
		if(logger!=null)
			logger.info("Totallly searched "+urlList.size()+" urls");
		if(callback!=null)
			callback.search_over();
		return urlList;
		
	}

	
}
