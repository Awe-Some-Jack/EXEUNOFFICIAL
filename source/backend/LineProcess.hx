package backend;

#if sys
import sys.io.Process;
import sys.thread.Deque;
import sys.thread.Thread;

final class LineProcess
{
	var process:Process;
	var lines:Deque<String> = new Deque<String>();
	var stdoutDone:Bool = false;
	var stderrDone:Bool = false;
	var killed:Bool = false;
	var released:Bool = false;

	public function new(command:String, ?args:Array<String>)
	{
		process = new Process(command, args ?? []);

		final stdout = process.stdout;
		final stderr = process.stderr;
		Thread.create(() ->
		{
			try
			{
				while (true) lines.add(stdout.readLine());
			}
			catch (e:Dynamic) {}
			stdoutDone = true;
		});
		Thread.create(() ->
		{
			try
			{
				while (true) stderr.readLine();
			}
			catch (e:Dynamic) {}
			stderrDone = true;
		});
	}

	public function isRunning():Bool
	{
		return !killed && !stdoutDone;
	}

	public function send(line:String):Bool
	{
		if (!isRunning()) return false;

		try
		{
			process.stdin.writeString(line + '\n');
			process.stdin.flush();
			return true;
		}
		catch (e:Dynamic)
		{
			kill();
			return false;
		}
	}

	public function poll():Array<String>
	{
		final received:Array<String> = [];
		var line:Null<String> = lines.pop(false);
		while (line != null)
		{
			received.push(line);
			line = lines.pop(false);
		}
		releaseIfDone();
		return received;
	}

	public function kill():Void
	{
		if (!killed)
		{
			killed = true;
			try
			{
				#if windows
				process.kill();
				#else
				Sys.command('kill', ['-9', Std.string(process.getPid())]);
				#end
			}
			catch (e:Dynamic) {}
		}
		releaseIfDone();
	}

	function releaseIfDone():Void
	{
		if (released || !stdoutDone || !stderrDone) return;

		released = true;
		try
		{
			process.close();
		}
		catch (e:Dynamic) {}
	}
}
#end
