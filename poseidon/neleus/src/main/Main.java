package main;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.commons.logging.LogFactory;

import ask_google.Ask_Google;

public class Main {
	private String keyword=null , url=null , anchor=null ;
	private int thread=3,count=100;
	private Ask_Google ask_google;
	private CallBackFun callback;
	private ArrayList<String> comments = new ArrayList<String>();
	private Logger logger = Logger.getLogger("neleus.log");
	public Main(){
		FileHandler fileHandler;
		try {
			fileHandler = new FileHandler("neleus.log");
			fileHandler.setLevel(Level.ALL); 
	        logger.addHandler(fileHandler);
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
         
	}
	public void printUsage(){
		//logger.
		System.out.println("Usage:java -jar neleus.jar -k KEYWORD -a ANCHOR -r URL [-t THREAD=3] [-c COUNT=100]");
	}
	public boolean parseArgs(String[]args){
		if(args.length!=10 && args.length!=8 && args.length!=6){
			printUsage();
			return false;
		}
		for(int i=0;i<args.length/2;i++){
			if(args[i*2].equalsIgnoreCase("-k")){
				keyword = args[i*2+1];
			}else if(args[i*2].equalsIgnoreCase("-r")){
				url = args[i*2+1];
			}else if(args[i*2].equalsIgnoreCase("-a")){
				anchor = args[i*2+1];
			}else if(args[i*2].equalsIgnoreCase("-t")){
				try{
					thread = Integer.parseInt(args[i*2+1]);
				}catch(Exception e){
					printUsage();
					return false;
				}
			}else if(args[i*2].equalsIgnoreCase("-c")){
				try{
					count = Integer.parseInt(args[i*2+1]);
				}catch(Exception e){
					printUsage();
					return false;
				}
			}else{
				printUsage();
				return false;
			}
		}
		if(keyword==null || url ==null || anchor==null || thread<=0 ||count<=0){
			printUsage();
			return false;
		}
		count = count>1000?1000:count;
		if(keyword.equals("''")||keyword.equals("\"\"")) keyword="";
		keyword +=" \""+"Allowed HTML Tags: b, img, a, br, embed\"";
		return true;
	}
	public boolean readComment(){
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(new File("neleus-keywords"))));
			String line;
			while((line=br.readLine())!=null){
				comments.add(line);
			}
			br.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			System.out.println("File neleus-keywords not found!");
			return false;
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.out.println("Can't read file neleus-keywords!");
			return false;
		}
		return true;
	}
	public void start(){
		ask_google = new Ask_Google();
		callback = new CallBackFun(thread,comments,logger);
		ArrayList<String> list = ask_google.ask_Google(keyword, count, callback, 20, 25, logger);
	}
	public static void main(String[]args){
		LogFactory.getFactory().setAttribute("org.apache.commons.logging.Log", "org.apache.commons.logging.impl.NoOpLog");
		Main main  = new Main();
		if(!main.parseArgs(args))return;
		if(!main.readComment())return;
		main.start();
	}
}
