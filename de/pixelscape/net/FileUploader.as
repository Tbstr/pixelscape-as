package de.pixelscape.net 
{
	import de.pixelscape.output.notifier.Notifier;	
	
	import flash.net.FileFilter;	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	/**
	 * @author Tobias Friese
	 * 
	 * This class provides simple access to uploading mechanisms in AS3.
	 */
	public class FileUploader extends EventDispatcher 
	{
		/* variables */
		private var _file:FileReference;
		
		private var _targetURL:URLRequest;
		private var _uploadDataFieldName:String;
		private var _testUpload:Boolean;
		
		private var _fileFilters:Array;
		
		private var _returnDataType:String;
		private var _returnData:*;
		
		private var _bytesLoaded:uint;		private var _bytesTotal:uint;
		
		/* constants */
		/** defines the exptected return type as plain text */
		public static const RETURN_DATATYPE_PLAIN:String = "returnDataTypePlain";
		/** defines the exptected return type as XML */		public static const RETURN_DATATYPE_XML:String = "returnDataTypeXML";
		/** defines the exptected return type as UrlVariables */		public static const RETURN_DATATYPE_URLVARIABLES:String = "returnDataTypeURLVariables";
		
		/** dispatched if file selection has been cancelled */
		public static const SELECTION_CANCEL:String = "selectionCancel";
		/** dispatched if file selection has been finished */		public static const SELECTION_FINISHED:String = "selectionFinished";
		
		/** dispatched if upload starts */
		public static const UPLOAD_START:String = "uploadStart";
		/** dispatched while upload is in progess */		public static const UPLOAD_PROGRESS:String = "uploadProgress";
		/** dispatched if upload is completed */		public static const UPLOAD_COMPLETE:String = "uploadComplete";
		/** dispatched if upload is completed and the returned data has been interpreted */		public static const UPLOAD_COMPLETE_DATA:String = "uploadCompleteData";
		
		/** dispatched if input/output error occurs */
		public static const IO_ERROR:String = "IOError";
		/** dispatched if security error occurs */		public static const SECURITY_ERROR:String = "securityError";
		/** dispatched if http status sets or changes */		public static const HTTP_STATUS:String = "httpStatus";
		
		/** FileUploader constructor
		 * 
		 * @param targetURL the URL to the script that manages the upload data
		 * @param uploadDataFieldName the name of the field with which the data will be sent
		 * @param returnDataType the type of the returned data (plainText, xml or url variables, choose from static constants)
		 */
		public function FileUploader(targetURL:String, uploadDataFieldName:String = "Filedata", returnDataType:String = RETURN_DATATYPE_PLAIN)
		{
			this._targetURL				= new URLRequest(targetURL);
			this._uploadDataFieldName	= uploadDataFieldName;
			this._returnDataType		= returnDataType;
			
			this._fileFilters			= new Array();
			this._testUpload			= false;
			this._bytesLoaded			= 1;			this._bytesTotal			= 1;
		}
		
		/* getter methods */
		
		/** returns the URL to the upload script */
		public function get targetURL():String
		{
			return _targetURL.url;
		}
		
		/** returns the field name with which the data will be sent */
		public function get uploadDataFieldName():String
		{
			return _uploadDataFieldName;
		}
		
		/** returns the return datatype as String */
		public function get returnDataType():String
		{
			return _returnDataType;
		}
		
		/** returns the actual test upload setting */
		public function get testUpload():Boolean
		{
			return _testUpload;
		}
		
		/** returns the amount of loaded bytes from the actual or the last uploading process */
		public function get bytesLoaded():uint
		{
			return _bytesLoaded;
		}
		
		/** returns the amount of total bytes from the actual or the last uploading process */
		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
		/** returns the returned data from the last uploading process. Depends on the defined return type.*/
		public function get returnData():*
		{
			return _returnData;
		}
		
		/** returns the the creation date of the actually uploading or the last uploaded file */
		public function get fileCreationDate():Date
		{
			if(_file != null)
			{
				return _file.creationDate;
			}
			
			return null;
		}
		
		/** returns the the creator of the actually uploading or the last uploaded file */
		public function get fileCreator():String
		{
			if(_file != null)
			{
				return _file.creator;
			}
			
			return null;
		}
		
		/** returns the the modification date of the actually uploading or the last uploaded file */
		public function get fileModificationDate():Date
		{
			if(_file != null)
			{
				return _file.modificationDate;
			}
			
			return null;
		}
		
		/** returns the the file name of the actually uploading or the last uploaded file */
		public function get fileName():String
		{
			if(_file != null)
			{
				return _file.name;
			}
			
			return null;
		}
		
		/** returns the the size of the actually uploading or the last uploaded file */
		public function get fileSize():uint
		{
			if(_file != null)
			{
				return _file.size;
			}
			
			return 0;
		}
		
		/** returns the the type of the actually uploading or the last uploaded file */
		public function get fileType():String
		{
			if(_file != null)
			{
				return _file.type;
			}
			
			return null;
		}
		
		/* setter methods */
		
		/** defines the URL to the upload script */
		public function set targetURL(value:String):void
		{
			_targetURL.url = value;
		}
		
		/** defines the field name with which the data will be sent */
		public function set uploadDataFieldName(value:String):void
		{
			_uploadDataFieldName = value;
		}
		
		/** defines the return datatype as String */
		public function set returnDataType(value:String):void
		{
			_returnDataType = value;
		}
		
		/** defines whether the upload is a test upload or nor. */
		public function set testUpload(value:Boolean):void
		{
			_testUpload = value;
		}
		
		// methods
		
		/**
		 * With this method one can add FileFilter objects for constraining the datatypes that
		 * are available through the system open-window.
		 */
		public function addFileFilter(...args):void
		{
			for(var i:uint = 0; i < args.length; i++)
			{
				if(args[i] is FileFilter)
				{
					_fileFilters.push(args[i]);
				}
			}
		}
		
		/**
		 * Cancels a currently uploading file.
		 */
		public function cancel() : void
		{
			if(_file != null) _file.cancel();
		}
		
		/**
		 * Opens a system open-window for file selection and starts uploading
		 * after successful selection.
		 */
		public function browse():void
		{
			// create file reference
			_file = new FileReference();
			
			// apply event handler
			_file.addEventListener(Event.CANCEL, cancelHandler);
            _file.addEventListener(Event.COMPLETE, uploadCompleteHandler);
            _file.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            _file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _file.addEventListener(Event.OPEN, openHandler);
            _file.addEventListener(ProgressEvent.PROGRESS, uploadProgressHandler);
            _file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _file.addEventListener(Event.SELECT, selectHandler);
            _file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
			
			// start browsing
			_file.browse(_fileFilters);
		}
		
		private function unregisterListeners():void
		{
			_file.removeEventListener(Event.CANCEL, cancelHandler);
            _file.removeEventListener(Event.COMPLETE, uploadCompleteHandler);
            _file.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _file.removeEventListener(Event.OPEN, openHandler);
            _file.removeEventListener(ProgressEvent.PROGRESS, uploadProgressHandler);
            _file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _file.removeEventListener(Event.SELECT, selectHandler);
            _file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
		}
		
		/* event handler */
		private function openHandler(e:Event):void
		{
			dispatchEvent(new Event(UPLOAD_START));
		}
		
		private function cancelHandler(e:Event):void
		{
			dispatchEvent(new Event(SELECTION_CANCEL));
		}
		
		private function selectHandler(e:Event):void
		{
			dispatchEvent(new Event(SELECTION_FINISHED));
			_file.upload(_targetURL, _uploadDataFieldName, _testUpload);
		}

		private function ioErrorHandler(e:IOErrorEvent):void
		{
			var ioError:IOErrorEvent = new IOErrorEvent(IO_ERROR, false, false, e.text);
			dispatchEvent(ioError);
		}

		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			var securityError:SecurityErrorEvent = new SecurityErrorEvent(SECURITY_ERROR, false, false, e.text);
			dispatchEvent(securityError);
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			var httpStatusEvent:HTTPStatusEvent = new HTTPStatusEvent(HTTP_STATUS, false, false, e.status);
			dispatchEvent(httpStatusEvent);
		}

		private function uploadProgressHandler(e:ProgressEvent):void
		{
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
			
			var progressEvent:ProgressEvent = new ProgressEvent(UPLOAD_PROGRESS, false, false, e.bytesLoaded, e.bytesTotal);
			dispatchEvent(progressEvent);
		}
		
		private function uploadCompleteHandler(e:Event):void
		{
			dispatchEvent(new Event(UPLOAD_COMPLETE));
		}
		
		private function uploadCompleteDataHandler(e:DataEvent):void
		{
			switch(_returnDataType)
			{
				case RETURN_DATATYPE_PLAIN:
					_returnData = e.data;
					break;
					
				case RETURN_DATATYPE_XML:
					_returnData = new XML(e.data);
					break;
					
				case RETURN_DATATYPE_URLVARIABLES:
					_returnData = new URLVariables(e.data);
					break;
			}
			
			// unregister listeners
			unregisterListeners();
			
			// dispatch
			dispatchEvent(new Event(UPLOAD_COMPLETE_DATA));
		}
	}
}
