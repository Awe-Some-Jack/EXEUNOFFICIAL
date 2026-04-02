package backend;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;

class GifDecoder
{
	public var width:Int = 0;
	public var height:Int = 0;
	public var frames:Array<GifFrame> = [];

	var globalColorTable:Array<Int>;
	var bgColorIndex:Int = 0;
	var input:BytesInput;

	public function new() {}

	public static function fromBytes(data:Bytes):GifDecoder
	{
		var decoder = new GifDecoder();
		decoder.decode(data);
		return decoder;
	}

	public static function fromFile(path:String):GifDecoder
	{
		#if sys
		if (!sys.FileSystem.exists(path))
			return null;
		var data = sys.io.File.getBytes(path);
		return fromBytes(data);
		#else
		return null;
		#end
	}

	function decode(data:Bytes):Void
	{
		input = new BytesInput(data);

		// GIF87a or GIF89a
		var sig = readString(3);
		var ver = readString(3);
		if (sig != "GIF")
		{
			trace("GifDecoder: Not a GIF file");
			return;
		}

		width = readU16();
		height = readU16();
		var packed = readByte();
		bgColorIndex = readByte();
		var _pixelAspect = readByte();

		var gctFlag = (packed & 0x80) != 0;
		var gctSize = 1 << ((packed & 0x07) + 1);

		if (gctFlag)
			globalColorTable = readColorTable(gctSize);

		// Canvas for compositing frames
		var canvas = new BitmapData(width, height, true, 0x00000000);

		var disposalMethod:Int = 0;
		var transparentFlag:Bool = false;
		var transparentIndex:Int = 0;
		var delayTime:Int = 0;

		// Parse blocks
		while (input.position < data.length)
		{
			var blockType = readByte();

			switch (blockType)
			{
				case 0x21: // Extension
					var label = readByte();
					switch (label)
					{
						case 0xF9: // Graphics Control Extension
							var _blockSize = readByte(); // always 4
							var gcPacked = readByte();
							delayTime = readU16();
							transparentIndex = readByte();
							var _terminator = readByte();

							disposalMethod = (gcPacked >> 2) & 0x07;
							transparentFlag = (gcPacked & 0x01) != 0;

						default: 
							skipSubBlocks();
					}

				case 0x2C: 
					var imgLeft = readU16();
					var imgTop = readU16();
					var imgWidth = readU16();
					var imgHeight = readU16();
					var imgPacked = readByte();

					var lctFlag = (imgPacked & 0x80) != 0;
					var interlaced = (imgPacked & 0x40) != 0;
					var lctSize = 1 << ((imgPacked & 0x07) + 1);

					var colorTable = lctFlag ? readColorTable(lctSize) : globalColorTable;

					var prevCanvas = canvas.clone();

					var pixels = decodeLZW(imgWidth, imgHeight);

					if (interlaced)
						pixels = deinterlace(pixels, imgWidth, imgHeight);

					for (y in 0...imgHeight)
					{
						for (x in 0...imgWidth)
						{
							var idx = pixels[y * imgWidth + x];
							if (transparentFlag && idx == transparentIndex)
								continue;

							if (colorTable != null && idx < colorTable.length)
							{
								var color = colorTable[idx];
								var px = imgLeft + x;
								var py = imgTop + y;
								if (px < width && py < height)
									canvas.setPixel32(px, py, (0xFF << 24) | color);
							}
						}
					}

					var frame = new GifFrame();
					frame.bitmapData = canvas.clone();
					frame.delay = (delayTime <= 0) ? 10 : delayTime;
					frames.push(frame);

					// Handle disposal
					switch (disposalMethod)
					{
						case 2:
							var rect = new Rectangle(imgLeft, imgTop, imgWidth, imgHeight);
							canvas.fillRect(rect, 0x00000000);

						case 3: 
							canvas.dispose();
							canvas = prevCanvas;

						default: 
							prevCanvas.dispose();
					}

					disposalMethod = 0;
					transparentFlag = false;
					transparentIndex = 0;
					delayTime = 0;

				case 0x3B: 
					break;

				default:
					break;
			}
		}

		canvas.dispose();
	}

	function readColorTable(size:Int):Array<Int>
	{
		var table = new Array<Int>();
		for (i in 0...size)
		{
			var r = readByte();
			var g = readByte();
			var b = readByte();
			table.push((r << 16) | (g << 8) | b);
		}
		return table;
	}

	function decodeLZW(imgWidth:Int, imgHeight:Int):Array<Int>
	{
		var minCodeSize = readByte();
		var clearCode = 1 << minCodeSize;
		var eoiCode = clearCode + 1;

		var codeSize = minCodeSize + 1;
		var codeMask = (1 << codeSize) - 1;
		var nextCode = eoiCode + 1;

		// Read all sub-block data into a single buffer
		var blockData = new haxe.io.BytesBuffer();
		while (true)
		{
			var subBlockSize = readByte();
			if (subBlockSize == 0)
				break;
			for (i in 0...subBlockSize)
				blockData.addByte(readByte());
		}
		var compressedData = blockData.getBytes();

		var maxTableSize = 4096;
		var prefixes = new Array<Int>();
		var suffixes = new Array<Int>();
		var tableStack = new Array<Int>();

		prefixes.resize(maxTableSize);
		suffixes.resize(maxTableSize);

		for (i in 0...clearCode)
		{
			prefixes[i] = -1;
			suffixes[i] = i;
		}

		var pixels = new Array<Int>();
		var totalPixels = imgWidth * imgHeight;

		var bitBuf:Int = 0;
		var bitCount:Int = 0;
		var bytePos:Int = 0;

		inline function readCode():Int
		{
			while (bitCount < codeSize && bytePos < compressedData.length)
			{
				bitBuf |= (compressedData.get(bytePos) & 0xFF) << bitCount;
				bytePos++;
				bitCount += 8;
			}
			var code = bitBuf & codeMask;
			bitBuf >>= codeSize;
			bitCount -= codeSize;
			return code;
		}

		var oldCode:Int = -1;
		var firstChar:Int = 0;

		while (pixels.length < totalPixels)
		{
			var code = readCode();

			if (code == clearCode)
			{
				codeSize = minCodeSize + 1;
				codeMask = (1 << codeSize) - 1;
				nextCode = eoiCode + 1;
				oldCode = -1;
				continue;
			}

			if (code == eoiCode)
				break;

			var inTable = code < nextCode;
			var curCode = code;

			tableStack.resize(0);

			if (!inTable)
			{
				tableStack.push(firstChar);
				curCode = oldCode;
			}

			while (curCode >= clearCode + 2)
			{
				tableStack.push(suffixes[curCode]);
				curCode = prefixes[curCode];
				if (tableStack.length > maxTableSize)
					break;
			}
			firstChar = suffixes[curCode];
			tableStack.push(firstChar);

			var i = tableStack.length - 1;
			while (i >= 0 && pixels.length < totalPixels)
			{
				pixels.push(tableStack[i]);
				i--;
			}

			// Add to code table
			if (oldCode >= 0 && nextCode < maxTableSize)
			{
				prefixes[nextCode] = oldCode;
				suffixes[nextCode] = firstChar;
				nextCode++;

				if (nextCode > codeMask && codeSize < 12)
				{
					codeSize++;
					codeMask = (1 << codeSize) - 1;
				}
			}

			oldCode = code;
		}

		return pixels;
	}

	function deinterlace(pixels:Array<Int>, w:Int, h:Int):Array<Int>
	{
		var result = new Array<Int>();
		result.resize(w * h);

		var passes = [
			{start: 0, step: 8},
			{start: 4, step: 8},
			{start: 2, step: 4},
			{start: 1, step: 2}
		];

		var srcRow = 0;
		for (pass in passes)
		{
			var y = pass.start;
			while (y < h)
			{
				for (x in 0...w)
					result[y * w + x] = pixels[srcRow * w + x];
				srcRow++;
				y += pass.step;
			}
		}
		return result;
	}

	function skipSubBlocks():Void
	{
		while (true)
		{
			var size = readByte();
			if (size == 0) break;
			for (i in 0...size)
				readByte();
		}
	}

	inline function readByte():Int
	{
		return input.readByte() & 0xFF;
	}

	function readU16():Int
	{
		var lo = readByte();
		var hi = readByte();
		return (hi << 8) | lo;
	}

	function readString(len:Int):String
	{
		var s = "";
		for (i in 0...len)
			s += String.fromCharCode(readByte());
		return s;
	}
}

class GifFrame
{
	public var bitmapData:BitmapData;
	public var delay:Int; 

	public function new() {}
}
