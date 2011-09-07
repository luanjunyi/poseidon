package main;

import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

import org.apache.commons.logging.Log;

import ask_google.CallBackFunction;

public class CallBackFun implements CallBackFunction{
	private ThreadPoolExecutor threadPool = null;
	private ArrayList<String>comments;
	private Random random;
	public static int succ_num =0;
	public static int fail_num =0;
	public static int total_sum =0 ;
	private Logger logger;

	public CallBackFun(int thread , ArrayList<String> comments,Logger logger){
		threadPool = new ThreadPoolExecutor((3>thread?thread:3), thread, 30, TimeUnit. SECONDS ,  
				new ArrayBlockingQueue<Runnable>(1000), new ThreadPoolExecutor.DiscardOldestPolicy() );
		this.comments = comments;
		random = new Random(System.currentTimeMillis());
		this.logger = logger;
	}
	@Override
	public void deal_one_url(String url) {
		// TODO Auto-generated method stub
		total_sum ++;
		threadPool.execute(new ThreadTask(url,comments.get(random.nextInt(comments.size())),logger));
	}
	@Override
	public void search_over() {
		// TODO Auto-generated method stub
		threadPool.shutdown();
	}
	
}
