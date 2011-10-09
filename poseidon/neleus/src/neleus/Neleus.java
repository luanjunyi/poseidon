package neleus;
import com.gargoylesoftware.htmlunit.NicelyResynchronizingAjaxController;
import com.gargoylesoftware.htmlunit.WebClient;
import com.gargoylesoftware.htmlunit.html.HtmlElement;
import com.gargoylesoftware.htmlunit.html.HtmlPage;

public class Neleus {
    private String comment_body="comment_body";
    private String comment_submit="comment_submit";
    WebClient client= null;
    public Neleus(){
        try{
            client = new WebClient();
            client.setJavaScriptEnabled(true);
            client.setThrowExceptionOnScriptError(false);
            client.setJavaScriptTimeout(30000);
            client.setAjaxController(new NicelyResynchronizingAjaxController());
            client.waitForBackgroundJavaScript(10000);
        }catch(Exception e){
            client = null;
        }
    }
    private void analyseHtml(HtmlPage page){
        try{
            for(HtmlElement element:page.getElementsByTagName("form")){
                if(element.asText().toLowerCase().contains("Allowed HTML Tags: b, img, a, br, embed".toLowerCase())){
                    HtmlElement element_body = element.getElementsByTagName("textarea").get(0);
                    HtmlElement element_submit = null;
                    for(HtmlElement element2:element.getElementsByTagName("input")){
                        if (element2.getAttribute("type").toLowerCase().contains("submit")){
                            element_submit = element2;
                            break;
                        }
                    }
                    comment_body=element_body.getAttribute("id");
                    comment_submit = element_submit.getAttribute("id");
                    break;
                }
            }
        }catch(Exception e){
            comment_body="comment_body";
            comment_submit = "comment_submit";
        }
    }
    public boolean submit(String url,String comment){
        if(client==null) return false;
        boolean ret = true;
        int try_time = 5;
        while(try_time>0){
            try{
                client.setJavaScriptTimeout(10000);
                HtmlPage page = client.getPage(url);
                client.setJavaScriptTimeout(5000);
                analyseHtml(page);
                HtmlElement element1 = page.getHtmlElementById(comment_body);
                HtmlElement element2 = page.getHtmlElementById(comment_submit);
                if(element1==null || element2==null) throw new Exception();
                element1.type(comment);
                page = element2.click();
                if(page.getWebResponse().getStatusCode()==200)
                    ret = true;
                else 
                    ret = false;
                break;
            }catch(Exception e){
                ret = false;
            }finally{
                try{
                    client.closeAllWindows();
                }catch(Exception e){}
            }
            try_time--;
        }
        return ret;
    }
}
