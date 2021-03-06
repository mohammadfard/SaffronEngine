package nativeClasses
{
	
	import flash.display.BitmapData;
	import flash.utils.getDefinitionByName;

	public class Sharing
	{
		private var shareClass:Class,
					shareOptionClass:Class,
					shareEventClass:Class;
		
		private var _isSupports:Boolean = false ;
		
		private var _isClassesLoaded:Boolean = false ;
		
		
		/**You have to call setUp function first*/
		public function isSupports():Boolean
		{
			return _isSupports; 
		}
		
		public function isNativeLoaded():Boolean
		{
			return _isClassesLoaded ;
		}
		
		/**Share this text*/
		public function shareText(str:String,downloadLinkLable:String='',imageBirmapData:BitmapData=null):void
		{
			var sharedString:String = str+'\n\n'+DevicePrefrence.appName+'\n'+downloadLinkLable+'\n'
				+((DevicePrefrence.downloadLink_iOS=='')?'':'Apple Store: '+DevicePrefrence.downloadLink_iOS+'\n\n')
				+((DevicePrefrence.downloadLink_playStore=='')?'':'Android Play Store: '+DevicePrefrence.downloadLink_playStore+'\n\n')
				+((DevicePrefrence.downloadLink_cafeBazar=='')?'':'کافه بازار: '+DevicePrefrence.downloadLink_cafeBazar+'\n\n')
				+((DevicePrefrence.downloadLink_myketStore=='')?'':'مایکت: '+DevicePrefrence.downloadLink_myketStore);
			trace("sharedString : "+sharedString);
			if(isSupports())
			{
				var options:* = new shareOptionClass();
				options.title = "Share with ...";
				options.showOpenIn = false;
				
				shareClass.service.share(sharedString,imageBirmapData);
			}
		}
		
		/**You have to call Setup function to make it work*/
		public function Sharing()
		{
		}
		
		/**If your code was wrong, it will throw an error*/
		public function setUp(APP_KEY:String):void
		{
			DevicePrefrence.createDownloadLink();
			try
			{
				shareClass = getDefinitionByName("com.distriqt.extension.share.Share") as Class ;
				shareOptionClass = getDefinitionByName("com.distriqt.extension.share.ShareOptions") as Class ;
				shareEventClass = getDefinitionByName("com.distriqt.extension.share.events.ShareEvent") as Class ;
				
				if(shareClass!=null)
				{
					_isClassesLoaded = true ;
				}
			}
			catch(e)
			{
				throw 'Add \n\n\t<extensionID>com.distriqt.Share</extensionID>\n\t<extensionID>com.distriqt.Core</extensionID>\n\n to your project xmls';// and below permitions to the <application> tag : \n\n<activity \n\n\tandroid:name="com.distriqt.extension.share.activities.ShareActivity" \n\n\tandroid:theme="@android:style/Theme.Translucent.NoTitleBar" />\n\n\t\n\n<provider\n\n\tandroid:name="android.support.v4.content.FileProvider"\n\n\tandroid:authorities="air.'+DevicePrefrence.appID+'"\n\n\tandroid:grantUriPermissions="true"\n\n\tandroid:exported="false">\n\n\t<meta-data\n\n\t\tandroid:name="android.support.FILE_PROVIDER_PATHS"\n\n\t\tandroid:resource="@xml/distriqt_paths" />\n\n</provider>';
			}
			try
			{
				trace("Set the Share key : "+APP_KEY);
				(shareClass as Object).init( APP_KEY );
				
				getDefinitionByName("com.distriqt.extension.core.Core").init(APP_KEY);
				
				shareClass.service.addEventListener( shareEventClass.COMPLETE,	share_shareHandler, false, 0, true );
				shareClass.service.addEventListener( shareEventClass.CANCELLED,	share_shareHandler, false, 0, true );
				shareClass.service.addEventListener( shareEventClass.FAILED,  	share_shareHandler, false, 0, true );
				shareClass.service.addEventListener( shareEventClass.CLOSED,  	share_shareHandler, false, 0, true );
				
				if (shareClass.isSupported)
				{
					//	Functionality here
					trace("Share is supports");
					_isSupports = true ;
				}
				else
				{
					trace("Share is not supports");
					_isSupports = false ;
				}
			}
			catch (e:Error)
			{
				// Check if your APP_KEY is correct
				throw "The district app id was wrong!! get a new one for this id ("+DevicePrefrence.appID+") from : airnativeextensions.com/user/2299/applications" ;
				_isSupports = false ;
			}
		}
		
		
		
		
		private function share_shareHandler( event:* ):void
		{
			trace( event.type + "::" + event.activityType + "::" + event.error );
		}
	}
}