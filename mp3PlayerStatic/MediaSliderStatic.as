package mp3PlayerStatic
	//mp3PlayerStatic.MediaSliderStatic
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MediaSliderStatic extends MovieClip
	{
		public static var  backColor:uint;
		public static var mainColor:uint;
		public static var backColorALpha:Number;
		public static var mainColorAlpha:Number;

		
		private var currentPrecent:Number ;
		
		private var floatedPrecent:Number = 1 ;
		
		private var myWidth:Number ; 
		private var myHeight:Number ;
		private var lastFloatedPrecent:Number;
		private var slideSpeed:Number = 4 ;
		
		/**userSlideEnabled()<br>
		 * setUp()<br>
		 * setPrecent(precent:Number)
		 * */
		public function MediaSliderStatic()
		{
			super();
			currentPrecent = MediaPlayerStatic.currentPrecent
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			this.addEventListener(Event.ENTER_FRAME,cheker)	
			
			
			this.buttonMode = true ;
			this.mouseChildren = false;
			
			myWidth = this.width ;
			myHeight = this.height ;
			this.scaleX = this.scaleY = 1 ;
			
			this.removeChildren();
			this.addEventListener(Event.ENTER_FRAME,chekDownLoad)
			
		}
		
		protected function chekDownLoad(event:Event):void
		{
			
			if(MediaPlayerStatic.downLoadCompelete)
			{
				userSlideEnabled()
				this.removeEventListener(Event.ENTER_FRAME,chekDownLoad)
			}
		}
		
		protected function cheker(event:Event):void
		{
			
			if(MediaPlayerStatic.isReady)
			{
				this.removeEventListener(Event.ENTER_FRAME,cheker)	
				MediaPlayerStatic.evt.addEventListener(MediaPlayerEventStatic.CURRENT_PRECENT,getCurrentPrecent)
				MediaPlayerStatic.evt.addEventListener(MediaPlayerEventStatic.SOUND_PRESENT,getSoundPrecent)	
				MediaPlayerStatic.evt.addEventListener(MediaPlayerEventStatic.START_DOWNLOAD,startDownLoad)	
			//	this.addEventListener(Event.ENTER_FRAME,animIt);
				
				setPrecent(0);
				animIt();
			}
		}
		
		protected function startDownLoad(event:Event):void
		{
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE,changePrecent);
			this.addEventListener(Event.ENTER_FRAME,chekDownLoad)
		}
		protected function getSoundPrecent(event:MediaPlayerEventStatic):void
		{
			
			setPrecent(event.soundPrecent);
		}
		
		protected function getCurrentPrecent(event:MediaPlayerEventStatic):void
		{
			
			currentPrecent = event.currentPrecent
		}
		
		protected function unLoad(event:Event):void
		{
			
			this.removeEventListener(Event.ENTER_FRAME,animIt);
			this.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			this.removeEventListener(MouseEvent.CLICK,changePrecent);
			this.removeEventListener(Event.ENTER_FRAME,cheker)
			this.removeEventListener(Event.ENTER_FRAME,chekDownLoad)
			if(MediaPlayerStatic.evt!=null)
			{
				MediaPlayerStatic.evt.removeEventListener(MediaPlayerEventStatic.CURRENT_PRECENT,getCurrentPrecent)
				MediaPlayerStatic.evt.removeEventListener(MediaPlayerEventStatic.SOUND_PRESENT,getSoundPrecent)	
				MediaPlayerStatic.evt.removeEventListener(MediaPlayerEventStatic.START_DOWNLOAD,startDownLoad)	
			}
		}
		
		/**precent changed*/
		protected function changePrecent(event:MouseEvent):void
		{
			
			if(MediaPlayerStatic.isReady)
			{
				var myPrecent:Number = this.mouseX / myWidth;
				if(myPrecent<0)
				{
					myPrecent = 0 ;
				}
				else if(myPrecent > 1)
				{
					myPrecent = 1 ;
				}
				
				MediaPlayerStatic.evt.dispatchEvent(new MediaPlayerEventStatic(MediaPlayerEventStatic.CURRENT_PRECENT,1,myPrecent))
				MediaPlayerStatic.evt.dispatchEvent(new MediaPlayerEventStatic(MediaPlayerEventStatic.PLAY))
				
			}
		}
		
		/**set up the slider*/
		public function setUp(MainColor:uint,BackColor:uint,MainColorAlpha:Number=1,BackColorALpha:Number=1)
		{
			mainColor = MainColor ;
			backColor = BackColor ;
			BackColorALpha = BackColorALpha;
			MainColorAlpha = MainColorAlpha;
		}
		
		/**From now , user can select the slider precent*/
		public function userSlideEnabled():void
		{
			this.addEventListener(MouseEvent.MOUSE_MOVE,changePrecent);
		}
		
		/**set the slider to this stage*/
		public function setPrecent(precent:Number)
		{
			if(precent <0)
			{
				precent = 0 ;
			}
			else if(precent>1)
			{
				precent = 1 ;
			}
			
			currentPrecent = precent ;
			animIt();
		}
		
		/**animate the slider*/
		private function animIt(e:Event=null)
		{
			floatedPrecent += (currentPrecent-floatedPrecent)/slideSpeed;
			
			if(floatedPrecent!=lastFloatedPrecent)
			{
				var gra:Graphics = this.graphics ;
				gra.clear();
				gra.beginFill(mainColor,mainColorAlpha);
				var currentX:Number = floatedPrecent*myWidth ;
				gra.drawRect(0,0,currentX,myHeight);
				gra.beginFill(backColor,backColorALpha);
				gra.drawRect(currentX,0,myWidth-currentX,myHeight);
				
				lastFloatedPrecent = floatedPrecent ;
			}
		}
	}
}