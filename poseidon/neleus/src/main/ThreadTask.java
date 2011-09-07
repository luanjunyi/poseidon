package main;

import java.util.logging.Logger;

import neleus.Neleus;

public class ThreadTask implements Runnable {
	private String url,comment;
	private Logger logger;
	public ThreadTask(String url,String comment,Logger logger){
		this.url = url;
		this.comment = comment;
		this.logger = logger;
	}
	@Override
	public void run() {
		// TODO Auto-generated method stub
		Neleus  neleus = new Neleus();
		if(neleus.submit(url, comment)){
			CallBackFun.succ_num++;
			if(logger!=null)
				logger.info("spamed succ("+CallBackFun.succ_num+"):"+url);
		}else{
			CallBackFun.fail_num++;
			if(logger!=null)
				logger.severe("spamed fail("+CallBackFun.fail_num+"):"+url);
		}
		if(logger!=null)
			logger.info("current success rate = "+ (int)((CallBackFun.succ_num)*100.0/(CallBackFun.succ_num+CallBackFun.fail_num))+"%");
	}

}
