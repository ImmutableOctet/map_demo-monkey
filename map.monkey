Strict

' Imports:
Import mojo

' Functions:
Function Main:Int()
	New Game()
	
	' Return the default response.
	' Please don't return 1, that's usually defined as an error code.
	Return 0
End

' Classes:
Class Game Extends App
	' Constant variable(s):
	Const MAX_SIZE:Float = 2048
	Const HALF_SIZE:= (MAX_SIZE / 2.0)
	
	Const TILE_SIZE:Int = 256
	
	' Fields:
	
	' Resources:
	Field mapImage:Image
	
	' World:
	Field mapX:Float, mapY:Float
	Field cameraX:Float, cameraY:Float
	
	' Observation:
	Field zoom:Float = 1.0
	
	Field deviceWidth:Float, deviceHeight:Float
	Field hDeviceWidth:Float, hDeviceHeight:Float
	
	' Meta (Collections):
	Field markerList:List<MapMarker>
	
	' Constructor(s):
	Method OnCreate:Int()
		' Set the update-rate to the refresh-rate.
		SetUpdateRate(0) ' 60
		
		' Set an initial seed.
		CreateRandomSeed()
		
		' Update the screen. (Cache)
		UpdateScreen()
		
		' Initialize the map.
		InitMap()
		
		' Create some random markers.
		MakeMarkers()
		
		Return 0
	End
	
	Method CreateRandomSeed:Void()
		Local date:Int[] = GetDate()
		
		Seed = date[5] + date[6] ' Millisecs()
		
		Return
	End
	
	Method InitMap:Void()
		Local tmpImage:Image = LoadImage("map.jpg")
		
		mapImage = tmpImage.GrabImage( 0, 0, TILE_SIZE, TILE_SIZE, 64)
		
		cameraX = hDeviceWidth
		cameraY = hDeviceHeight
		
		' Uncomment these to immediately see the effects of centered viewports:
		'mapX = cameraX
		'mapY = cameraY
		
		Return
	End
	
	Method MakeMarkers:Void()
		' Create our markers:
		markerList = New List<MapMarker>()
		
		For Local I:= 1 To 50 ' 0 Until 50
			markerList.AddLast(New MapMarker(Rnd(0, MAX_SIZE), Rnd(0, MAX_SIZE)))
		Next
		
		Return
	End
	
	' Methods:
	Method UpdateZoom:Void(delta:Float)
		Const maxScale:= 2.0
		
		Local minScale:= (deviceWidth / MAX_SIZE)
		
		zoom = Clamp(zoom+delta, minScale, maxScale)
		
		Return
	End
	
	Method Controls:Void()
		If (KeyDown(KEY_UP)) Then
			cameraY -= 5.0
		Endif
		
		If (KeyDown(KEY_DOWN)) Then
			cameraY += 5.0
		Endif
		
		If (KeyDown(KEY_RIGHT))
			cameraX += 5.0
		Endif
		
		If (KeyDown(KEY_LEFT)) Then
			cameraX -= 5.0
		Endif
		
		If (KeyDown(KEY_W)) Then
			UpdateZoom(0.01)
		Endif
		
		If (KeyDown(KEY_S)) Then
			UpdateZoom(-0.01)
		Endif
		
		' Contain the view:
		cameraX = Clamp(cameraX, mapX, mapX + (MAX_SIZE))
		cameraY = Clamp(cameraY, mapY, mapY + (MAX_SIZE))
		
		Return
	End
	
	Method UpdateScreen:Void()
		' Not the best option; use 'OnResize' if available:
		deviceWidth = Float(DeviceWidth())
		deviceHeight = Float(DeviceHeight())
		
		hDeviceWidth = (deviceWidth / 2.0)
		hDeviceHeight = (deviceHeight / 2.0)
		
		Return
	End
	
	Method OnUpdate:Int()
		UpdateScreen()
		
		Controls()
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		' Clear the screen.
		Cls()
		
		' Render the world:
		PushMatrix()
		
		Translate(hDeviceWidth, hDeviceHeight)
		
		Scale(zoom, zoom)
		Translate(-cameraX, -cameraY)
		
		RenderMap(True)
		
		PopMatrix()
		
		' Debugging:
		DrawText("Camera: " + cameraX + ", " + cameraY, 8, 8)
		DrawText("Map: " + mapX + ", " + mapY, 8, 8+16)
		DrawText("Zoom : " + zoom, 8, 8+16+16)
		
		' Return the default response.
		Return 0
	End
	
	Method RenderMap:Void(markers:Bool)
		PushMatrix()
		
		Translate(mapX, mapY)
		
		Local frame:Int = 0
		
		For Local Y:Int = 0 To 7
			For Local X:Int = 0 To 7
				DrawImage(mapImage, (TILE_SIZE * X), (TILE_SIZE * Y), 0, 1.0, 1.0, frame)
				
				frame += 1
			Next
		Next
		
		If (markers) Then
			RenderMarkers()
		Endif
		
		PopMatrix()
		
		Return
	End
	
	Method RenderMarkers:Void()
		For Local m:= Eachin markerList
			m.Draw()
		Next
		
		Return
	End
End

Class MapMarker
	' Fields:
	Field x:Float, y:Float
	Field ox:Float, oy:Float
	Field size:Float = 10
	
	' Constructor(s):
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
		Self.ox = x
		Self.oy = y
	End
	
	' Methods:
	Method Draw:Void(offsetX:Float=0.0, offsetY:Float=0.0)
		DrawOval((x - size / 2) - offsetX, (y - size / 2) - offsetY, size, size)
		
		Return
	End
End
