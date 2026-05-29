package states.editors.content;

import haxe.Exception;
import sys.io.File;
import lime.ui.FileDialog;
import lime.ui.FileDialogFilter;
import lime.app.Application;

import flixel.FlxBasic;

class FileDialogHandler extends FlxBasic
{
	public var onComplete:Void->Void;
	public var onCancel:Void->Void;
	public var onError:Void->Void;

	public var data:String;
	public var path:String;
	public var completed:Bool = true;

	public function new()
	{
		super();
	}

	public function save(fileName:String = '', dataToSave:String = '', ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void)
	{
		if (!completed)
			throw new Exception('You must finish previous operation before starting a new one.');

		_startUp(onComplete, onCancel, onError);

		final window = Application.current?.window ?? null;
		FileDialog.saveFile(window, "Save File", function(savePath:String, filter:FileDialogFilter) {
			if (savePath != null) 
			{
				try 
				{
					File.saveContent(savePath, dataToSave);
					this.path = savePath;
					this.completed = true;
					trace('Saved file to: $path');
					if (this.onComplete != null) this.onComplete();
				} 
				catch (e:Dynamic) 
				{
					this.completed = true;
					if (this.onError != null) this.onError();
				}
			} 
			else 
			{
				this.completed = true;
				if (this.onCancel != null) this.onCancel();
			}
		}, null, fileName);
	}

	public function open(defaultName:String = null, ?title:String = null, ?filters:Array<FileDialogFilter> = null, ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void)
	{
		if (!completed)
			throw new Exception('You must finish previous operation before starting a new one.');

		_startUp(onComplete, onCancel, onError);
		
		filters ??= [new FileDialogFilter('JSON', 'json')];
		#if mac
		filters = null;
		#end

		final window = Application.current?.window ?? null;
		FileDialog.openFile(window, title, function(files:Array<String>, filter:FileDialogFilter) {
			if (files != null && files.length > 0) 
			{
				try 
				{
					this.path = files[0];
					this.data = File.getContent(this.path);
					this.completed = true;
					trace('Loaded file from: $path');
					if (this.onComplete != null) this.onComplete();
				} 
				catch (e:Dynamic) 
				{
					this.completed = true;
					if (this.onError != null) this.onError();
				}
			} 
			else 
			{
				this.completed = true;
				if (this.onCancel != null) this.onCancel();
			}
		}, filters, defaultName, false);
	}

	public function openDirectory(?title:String = null, ?onComplete:Void->Void, ?onCancel:Void->Void, ?onError:Void->Void)
	{
		if (!completed)
			throw new Exception('You must finish previous operation before starting a new one.');

		_startUp(onComplete, onCancel, onError);

		final window = Application.current?.window ?? null;
		FileDialog.openDirectory(window, title, function(directories:Array<String>) {
			if (directories?.length > 0) 
			{
				this.path = directories[0];
				this.completed = true;
				trace('Loaded directory: $path');
				if (this.onComplete != null) this.onComplete();
			} 
			else 
			{
				this.completed = true;
				if (this.onCancel != null) this.onCancel();
			}
		}, null, false);
	}

	function _startUp(onComplete:Void->Void, onCancel:Void->Void, onError:Void->Void)
	{
		this.onComplete = onComplete;
		this.onCancel = onCancel;
		this.onError = onError;
		this.completed = false;
		this.data = null;
		this.path = null;
	}

	override function destroy()
	{
		onComplete = null;
		onCancel = null;
		onError = null;
		data = null;
		path = null;
		completed = true;
		super.destroy();
	}
}