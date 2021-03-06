﻿package fileBrowser
{
	import com.mteamapp.StringFunctions;
	
	import contents.Contents;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import popForm.Hints;
	import popForm.PopButtonData;
	import popForm.PopMenuContent;
	import popForm.PopMenuEvent;
	import popForm.PopMenuFields;

	public class FileBrowser2
	{
		private static var eventListen:Sprite = new Sprite();
		
		
		public static var selectedFile:File ;
		public static var selectedFileBytes:ByteArray ;
		
		private static var onDone:Function ;
		
		private static var lastLocation:File ;
		
		private static var Name:String ;
		
		private static var driveFrame:uint = 8,
							folderFrame:uint=9,
							fileFrame:uint=10,
							noFileFrame:uint=11,
							searchButtonFrame:uint=5,
							backButtonFrame:uint=6,
							defaultButtonFrame:uint=7;
		
		/**1: load file, 2:save file*/
		private static var mode:uint = 0;
		
		private static var foundedFiles:Vector.<File>,
							lastSearchVal:String,
							queEndTime:Number,
							lastSearchedFolder:File,
							searchQue:Vector.<File>,
							frameTimes:Number,
							searchTF:MTTextField;

		private static var baseFolder:File,
							baseFolderTarget:String;
							
		private static var rootPath:String = null ;
		
		/**Set the Popmenu frames here*/
		public static function setUp(DriveButtonFrame:uint,FolderButtonsFrame:uint,
									 FilesButtonFrame:uint,NoFileButtonFrame:uint,
									 SearchButtonFrame:uint=5,BackButtonFrame:uint=6,DefaultButtonFrame:uint=7):void
		{
			driveFrame = DriveButtonFrame ;
			folderFrame = FolderButtonsFrame;
			fileFrame = FilesButtonFrame;
			noFileFrame = NoFileButtonFrame ;
			searchButtonFrame = SearchButtonFrame ;
			backButtonFrame = BackButtonFrame ;
			defaultButtonFrame = DefaultButtonFrame ;
			
			var neededLang:String = "" ;
			
			neededLang+=controlLang("cansel","لغو") ;
			neededLang+=controlLang("back_folder","بازگشت به بالا") ;
			neededLang+=controlLang("save","ذخیره") ;
			neededLang+=controlLang("search","جستجو") ;
			neededLang+=controlLang("no_file_here","هیچ فایلی در این مسیر وجود ندارد") ;
			neededLang+=controlLang("file_selector_title","انتخاب فایل") ;
			neededLang+=controlLang("see_the_result","مشاهده") ;
			neededLang+=controlLang("founded_items","فایل های یافت شده:") ;
			neededLang+=controlLang("founded_files_with","فایل های یافت شده با نام :") ;
			neededLang+=controlLang("please_wait","لطفاً کمی صبر کنید ...") ;
			
			if(neededLang!='')
			{
				throw "Please add below tags to the Language.xml file for FileBrowser class.\n\n"+neededLang ;
			}
			
			lastLocation = File.userDirectory ;
		}
		
		/**Set default location for firs openning*/
		public static function setDefaultPath(file:File):void
		{
			lastLocation = file ;
		}
		
		private static function controlLang(langName:String,defaultText:String):String
		{
			if(Contents.lang.t[langName] == null)
			{
				return "\t<"+langName+">\n\t\t<fa>"+defaultText+"</fa>\n\t</"+langName+">\n";
			}
			return '' ;
		}

		public static function get isSupported():Boolean
		{
			trace("Check the iOS action for file browser first");
			return true ;
		}
		
		public static function browsToLoad(onFileSelected:Function):void
		{
			selectedFile = null ;
			selectedFileBytes = null ;
			mode = 1 ;
			onDone = onFileSelected ;
			showBrowser(lastLocation);
		}
		
		public static function browsToSave(targetBytes:ByteArray,fileName:String):void
		{
			trace("Save the file with the name ; "+fileName);
			selectedFileBytes = targetBytes ;
			mode = 2;
			Name = fileName ;
			onDone = new Function();
			showBrowser(lastLocation);
		}
		
		public static function showBrowser(target:File,hint:String='',addBackButton:Boolean=true):void
		{
			lastLocation = target ;
			//var buttons:Array = [Contents.lang.t.cansel,''] ;
			var buttons:Array = new Array();
		
			buttons.push(new PopButtonData(Contents.lang.t.cansel,defaultButtonFrame,null,true,true)) ;
			baseFolderTarget = '' ;
			if(/*true || */DevicePrefrence.isIOS())
			{
				baseFolder = File.applicationStorageDirectory.resolvePath('FileManager');
				if(!baseFolder.exists)
				{
					baseFolder.createDirectory();
				}
				baseFolderTarget = baseFolder.nativePath ;
			}
			trace("lastLocation : "+lastLocation+' vs '+baseFolder)
			if(lastLocation==null)
			{
				lastLocation = baseFolder ;
			}
			else
			{
				trace("Location was not null : "+lastLocation.nativePath);
			}
			
			if(
				lastLocation!=null 
				&& 
				(
					baseFolder==null 
					|| 
					lastLocation.nativePath!=baseFolder.nativePath
				) 
				&& 
				(
					lastLocation.nativePath != rootPath
				)
			)
			{
				buttons.push(new PopButtonData(Contents.lang.t.back_folder,defaultButtonFrame,null,true,true));
			}
			if(mode==2 && lastLocation!=null)
			{
				buttons.push(new PopButtonData(Contents.lang.t.save,defaultButtonFrame,null,true,true));
			}
			else if(lastLocation!=null)
			{
				buttons.push(new PopButtonData(Contents.lang.t.search,defaultButtonFrame,null,true,true));
			}
			var button:PopButtonData ;
			var i:int ;
			var currentFile:File ;
			
			var hadSub:Boolean = false ;
			
			if(lastLocation!=null)
			{
				var location:String = lastLocation.nativePath;
				if(baseFolderTarget!='')
				{
					location = location.split(baseFolderTarget).join('');
				}
				if(hint!='')
				{
					hint = hint+'\n'+location ;
				}
				else
				{
					hint = location ;
				}
			}
			
			if(lastLocation == null)
			{
				var bases:Array = File.getRootDirectories() ;
				if(bases.length==1)
				{
					rootPath = (bases[0] as File).nativePath ;
					showBrowser(bases[0] as File,'',false);
					return ;
				}
				for(i = 0 ; i<bases.length ; i++)
				{
					hadSub = true ;
					var baseFile:File = bases[i] as File ;
					button = new PopButtonData(baseFile.name,driveFrame,baseFile);
					buttons.push(button);
				}
			}
			else
			{
				var sub:Array = lastLocation.getDirectoryListing() ;
				sub = sub.sort(sortFolders);
				for(i = 0 ; i<sub.length ; i++)
				{
					hadSub = true ;
					currentFile = sub[i] as File ;
					var buttonFrame:uint ;
					if(currentFile.isDirectory)
					{
						buttonFrame = folderFrame ;
					}
					else
					{
						buttonFrame = fileFrame ;
						if(mode==2)
						{
							continue ;
						}
					}
					button = new PopButtonData(currentFile.name,buttonFrame,currentFile);
					buttons.push(button);
				}
			}
			
			if(!hadSub)
			{
				button = new PopButtonData(Contents.lang.t.no_file_here,noFileFrame,null,false);
				buttons.push(button);
			}
			
			var popText:PopMenuContent = new PopMenuContent(hint,null,buttons);
			trace("Open browser");
			PopMenu1.popUp(Contents.lang.t.file_selector_title,null,popText,0,onFileSelected);
		}
			
		/**Sort files by their name*/
		private static function sortFolders(a:File,b:File):int
		{
			trace("Compair "+a.name+" vs "+b.name+" = "+StringFunctions.compairFarsiString(a.name,b.name));
			return StringFunctions.compairFarsiString(a.name,b.name);
		}
		
		private static function onFileSelected(e:PopMenuEvent):void
		{
			//trace('e :',JSON.stringify(e));
			var myFile:File ;
			
			if(e.buttonTitle == Contents.lang.t.back_folder)
			{
				showBrowser(lastLocation.parent);
			}
			else if(e.buttonTitle == Contents.lang.t.search)
			{
				searchPage('');
			}
			else if(e.buttonTitle == Contents.lang.t.cansel)
			{
				selectedFile = null;
				selectedFileBytes = null ;
				//onDone();
			}
			else if(e.buttonTitle == Contents.lang.t.save)
			{
				var saveTarget:File = lastLocation.resolvePath(Name);
				
				var index:uint = 1 ;
				var extention:String = Name.substring(Name.lastIndexOf('.'));
				var baseName:String = Name.substring(0,Name.lastIndexOf('.'));
				while(saveTarget.exists)
				{
					saveTarget = lastLocation.resolvePath(baseName+'_'+index+extention);
					index++ ;
				}
				trace("File saved to : "+saveTarget.nativePath);
				var status:String = FileManager.seveFile(saveTarget,selectedFileBytes);
				if(status!='')
				{
					showBrowser(lastLocation,status);
				}
				else
				{
					var popContent:PopMenuContent = new PopMenuContent('فایل با نام \n'+saveTarget.name+'\n ذخیره شد.',null,[Contents.lang.t.back]);
					PopMenu1.popUp('',null,popContent,10000);
				}
			}
			else if(e.buttonID is File)
			{
				myFile = e.buttonID as File;
				if(myFile.isDirectory)
				{
					showBrowser(myFile); 
				}
				else
				{
					selectThisFile(myFile);
				}
			}
		}
		
		/**Finish the browse*/
		private static function selectThisFile(file:File):void
		{
			
			selectedFile = file ;
			
			selectedFileBytes = FileManager.loadFile(selectedFile);
			onDone();
		}
		
		private static function searchPage(searchVal:String=null):void
		{
			
			if(searchVal!=null)
			{
				lastSearchVal = searchVal ;
			}
			foundedFiles = new Vector.<File>();
			frameTimes = 1000/30 ;
			var fields:PopMenuFields = new PopMenuFields();
			fields.addField(Contents.lang.t.search,lastSearchVal,null,false);
			
			var buttons:Array = new Array();
			var newButt1:PopButtonData = new PopButtonData(Contents.lang.t.search,searchButtonFrame,null,true,true);
			buttons.push(newButt1)
			var newButt2:PopButtonData = new PopButtonData(Contents.lang.t.back,backButtonFrame,null,true,true);
			buttons.push(newButt2)
			//var buttons:Array = [Contents.lang.t.search,Contents.lang.t.back];
			var popText:PopMenuContent = new PopMenuContent('',fields,buttons);
			PopMenu1.popUp(Contents.lang.t.file_selector_title,null,popText,0,onSearchButton);
		}
		
		private static function onSearchButton(e:PopMenuEvent):void
		{
			if(e.buttonTitle == Contents.lang.t.search)
			{
				//Start search
				lastSearchVal = e.field[Contents.lang.t.search] as String;
				if(lastSearchVal == '')
				{
					searchPage();
				}
				else
				{
					startSearch();
				}
			}
			else
			{
				showBrowser(lastLocation);
			}
		}
		
		private static function startSearch():void
		{
			trace("Start the search about : "+lastSearchVal);
			
			var searchMC:MovieClip = new MovieClip();
			searchTF = new MTTextField(0,30,"B Yekan Regular");
			searchTF.width = 400 ;
			searchMC.addChild(searchTF);
			searchTF.x = searchTF.width/-2;
			searchTF.text = '0';
			lastSearchedFolder = lastLocation ;
			
			startSearchig();
			
			var buttons:Array = [Contents.lang.t.back,Contents.lang.t.see_the_result];
			
			var popText:PopMenuContent = new PopMenuContent(Contents.lang.t.founded_items,null,buttons,searchMC);
			PopMenu1.popUp(Contents.lang.t.please_wait,null,popText,0,onSearchButton2);
		}
		
		private static function startSearchig():void
		{
			searchQue = new Vector.<File>();
			var bases:Array = File.getRootDirectories();
			for(var i = 0 ; i<bases.length ; i++)
			{
				searchQue.push(bases[i] as File);
			}
			//queEndTime = getTimer()+10/*frameTimes*/;
			
			eventListen.addEventListener(Event.ENTER_FRAME,SearchOnQue);
		}
		
			protected static function SearchOnQue(event:Event):void
			{
				
				searchTF.text = foundedFiles.length.toString();
				/*for(var i = 0 ; i<searchQue.length ; i++)
				{
					searchOn(searchQue[i]);
				}
				searchQue = new Vector.<File>();*/
				queEndTime = getTimer()+(frameTimes)*4/5;
				while(getTimer()<queEndTime)
				{
					//trace("lastSearchedFolder : "+getTimer()+'<'+queEndTime);
					if(lastSearchedFolder!=null)
					{
						//trace("Continue searching...");
						searchOn2(lastSearchedFolder);
					}
					else
					{
						//trace("Finished");
						stopSearching();
						ShowSearchResult();
						break;
					}
				}
				
				//stopSearching();
			}
			
			private static function searchOn2(myFile:File):void
			{
				//trace("Check this : "+file.nativePath);
				
				if(myFile.isDirectory)
				{
					var sub:Array = myFile.getDirectoryListing();
					if(sub.length > 0)
					{
						lastSearchedFolder = sub[0] as File ;
						return ;
					}
					else
					{
						//Same as file
					}
				}
				else if(myFile.name.indexOf(lastSearchVal)!=-1)
				{
					foundedFiles.push(myFile);
				}
				
				while(myFile.nativePath!=lastLocation.nativePath && myFile!=null)
				{
					var nextFolder:File = myFile.parent;
					if(nextFolder==null)
					{
						lastSearchedFolder = null;
						return ;
					}
					var myIndex:uint = 0;
					var sisters:Array = nextFolder.getDirectoryListing();
					for(var i = 0 ; i<sisters.length ; i++)
					{
						if((sisters[i] as File).name == myFile.name)
						{
							myIndex = i ;
							break ;
						}
					}
					if(i+1<sisters.length)
					{
						lastSearchedFolder = sisters[i+1] as File;
						return ;
					}
					else
					{
						myFile = nextFolder ;
					}
					//trace("loop on : "+file.nativePath);
				}
				lastSearchedFolder = null ;
				/*for(var i = 0 ; i<sub.length ; i++)
				{
					subFile = sub[i];
					if(subFile.isDirectory)
					{
						lastSearchedFolder = subFile ;
						return ;
					}
					else if(subFile.name.indexOf(lastSearchVal)!=-1)
					{
						foundedFiles.push(subFile);
					}
				}*/
			}
			
				private static function searchOn(myFile:File):void
				{
					if(getTimer()>queEndTime)
					{
						searchQue.push(myFile);
						//trace("Time out on : "+file.nativePath);
						return ;
					}
					
					var sub:Array = myFile.getDirectoryListing() ;
					var file2:File
					for(var i = 0 ; i<sub.length ; i++)
					{
						file2 = sub[i];
						if(file2.isDirectory)
						{
							searchOn(file2);
							//searchQue.push(file);
						}
						else
						{
							if(file2.name.indexOf(lastSearchVal)!=-1)
							{
								foundedFiles.push(file2);
							}
						}
					}
				}
		
		private static function stopSearching():void
		{
			
			eventListen.removeEventListener(Event.ENTER_FRAME,SearchOnQue);
		}
		
		private static function onSearchButton2(e:PopMenuEvent)
		{
			//Stop the searches
			stopSearching();
			if(e.buttonTitle == Contents.lang.t.back)
			{
				searchPage();
			}
			else
			{
				ShowSearchResult();
			}
		}
		
		private static function ShowSearchResult():void
		{
			
			var buttons:Array = [Contents.lang.t.back,''];
			
			for(var i = 0 ; i<foundedFiles.length ; i++)
			{
				var newButt:PopButtonData = new PopButtonData(foundedFiles[i].name,fileFrame,foundedFiles[i]);
				buttons.push(newButt);
			}
			
			var popText:PopMenuContent = new PopMenuContent(Contents.lang.t.founded_files_with+lastSearchVal,null,buttons);
			PopMenu1.popUp(Contents.lang.t.search,null,popText,0,onResultButton);
		}
		
		private static function onResultButton(e:PopMenuEvent):void
		{
			if(e.buttonID is File)
			{
				selectThisFile(e.buttonID as File);
			}
			else
			{
				searchPage();
			}
		}
		
	}
}