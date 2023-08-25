{ Circuit Object [C_CrcObj.Pas]
  P931023
  ------------------------------
  (c) Copyright 1993 Peter Illes
  All rights reserved.
}

Unit C_CrcObj;

{$F+}

Interface

Uses
    Texts
  , IniFiles
  , WinTypes, WinProcs
  , Classes
  , Controls
  , SysUtils
  , Objects
  , OBSS_DR2
  , C_RootMs
  , C_UndoSt
  , Canvas
  , TCrsrs
  ;

Type

  PCircObj = ^TCircObj;

  TCircObj = Object( TOObject )
{    Private}
      BDrawn: Boolean;
      BUnDrawing: Boolean;
      BSelected: Boolean;
      BDragging: Boolean;
      wcUpLeftX, wcUpLeftY: TWrldCoord;
      wcDragBakUpLeftX,
      wcDragBakUpLeftY: TWrldCoord;
      FidDragTracker, FFlags: Integer;

    Public
      Constructor Init;
      Function _InitVars_: Boolean; Virtual; {True=Success}
{      Destructor Done; Virtual; It's the same as TOObject.Done }


      { OBSS SUPPORT }

      Constructor obssLoad( Var voStream: toOBSS;
                            wObjID, wObjVer: Word; liObjSize: LongInt );
      Function    obssReadData( Var voStream: toOBSS;
             wObjID, wObjVer: Word; liObjSize: LongInt ): Boolean; Virtual;

      Procedure   obssSave( Var voStream: toOBSS;
                            wObjID, wObjVer: Word; liObjSize: LongInt );
                            Virtual;
      Function    obssGetID: Word; Virtual;  {!!ABSTRACT!!}
      Function    obssGetVer(voStream: toOBSS): Word; Virtual;  {!!ABSTRACT!!}
      Function    obssGetSize(voStream: toOBSS): LongInt; Virtual;
      Procedure   obssWriteData( Var voStream: toOBSS ); Virtual;


      { COPY SUPPORT }

      Function  CloneMe: PCircObj; Virtual;
      Procedure _CopyData( pInto: PCircObj ); Virtual;


      { PRESENTATION METHODS }

      Procedure VRcWcGetBounds( pCnv: PTCanvas; Var vrcMe: TORect ); Virtual;
      Function  WcGetWidth( pCnv: PTCanvas ): TWrldCoord; Virtual; {!!ABSTRACT!!}
      Function  WcGetHeight( pCnv: PTCanvas ): TWrldCoord; Virtual; {!!ABSTRACT!!}
      Procedure VRcWcGetRealBounds( pCnv: PTCanvas; Var vrcMe: TORect ); Virtual; {!!ABSTRACT!!}
      Function  WcGetRealWidth( pCnv: PTCanvas ): TWrldCoord; Virtual; {!!ABSTRACT!!}
      Function  WcGetRealHeight( pCnv: PTCanvas ): TWrldCoord; Virtual; {!!ABSTRACT!!}
      Function  WcGetRealArea( pCnv: PTCanvas ): TWrldCoord; Virtual; {!!ABSTRACT!!}
      Function  IsInRect(pCnv: PTCanvas; rcIn : TORect; NoLabel, AppendValueToLabel,
        AppendToleranceToLabel, AppendUnitToLabel: Boolean; Precision: ShortInt) : Boolean; virtual;
      Function  IsFullyInRect( pCnv: PTCanvas; rcIn : TORect ) : Boolean; virtual;
      Function  HasCursor( pCnv: PTCanvas; wcX, wcY: TWrldCoord ) : Boolean; virtual;

      Procedure Draw( pCnv: PTCanvas ); virtual; {!!ABSTRACT!!}
      Procedure UnDraw( pCnv: PTCanvas ); virtual; {!!ABSTRACT!!}
      Procedure Select( pCnv: PTCanvas; fCheckLabel: Boolean ); virtual; {!!ABSTRACT!!}
      Procedure UnSelect( pCnv: PTCanvas ); virtual; {!!ABSTRACT!!}
      Function  IsSelected: Boolean; virtual;
      Procedure BeginDrag( pCnv: PTCanvas; idTracker: Integer ); virtual; {!!ABSTRACT!!}
      Procedure Dragging( pCnv: PTCanvas; wcX, wcY : TWrldCoord ); virtual; {!!ABSTRACT!!}
      Procedure EndDrag( pCnv: PTCanvas; ARealDragFinished: Boolean ); virtual; {!!ABSTRACT!!}
      Procedure AbortDrag( pCnv: PTCanvas ); virtual; {!!ABSTRACT!!}

      Procedure MoveTo( pCnv: PTCanvas; wcX, wcY : TWrldCoord ); virtual;
      Procedure Mirror( pCnv: PTCanvas; BMirror: Boolean; ExternalCOR: Boolean;
        CORX, CORY: Integer ); Virtual;

      Function GetClassID: Word; virtual;
      Function EditAttributes( pCnv: PTCanvas ): Boolean; virtual; {!!ABSTRACT!!}
      Function EditAttributesIsDblClick( pCnv: PTCanvas; bDoubleClick: Boolean ): Boolean; virtual;

      { Graph generation interface }
      Function  ConsiderInGraph : Boolean; virtual;

      { Trick for inheritance stuff }
      Function IsGraphable: Boolean; Virtual;

      { For the Canvas object only }
      Procedure _Render_( pCnv: PTCanvas ); Virtual;

      Function  GetCaptionPrefix: String; virtual;

      { Tracker interface }
      Function GetCursor( pCnv: PTCanvas; wcAtX, wcAtY: Integer ): TCursor; virtual;
      Function TrackerGetID( pCnv: PTCanvas; wcAtX, wcAtY: Integer ): Integer; virtual;
      Function TrackerGetNextPos( pCnv: PTCanvas; ALastTracker: Integer;
                                  Var pt: TPoint ): Boolean; virtual;
                                  { true if value returned }
      Procedure TrackerBeginDrag( pCnv: PTCanvas; idTracker: Integer ); virtual;
      Procedure TrackerDragging( pCnv: PTCanvas; wcX, wcY : TWrldCoord ); virtual;
      Procedure TrackerEndDrag( pCnv: PTCanvas ); virtual;
      Procedure TrackerAbortDrag( pCnv: PTCanvas ); virtual;
      Procedure TrackerDraw( pCnv: PTCanvas; bUnDraw: Boolean ); virtual;

      { Undo/Redo support }
      function undoGetData( eOpCode: TUROpCode ): Pointer; virtual;
      procedure undoReleaseData( eOpCode: TUROpCode; pData: Pointer ); virtual;
      procedure undoPerform( eOpCode: TUROpCode; pData: Pointer ); virtual;

      { Link support }
      function HasLink: Boolean; virtual;
      procedure DoLink; virtual;

      { Z order support }
      function GetZOrder: Integer; virtual;
      procedure SetZOrder(iNewZ: Integer); virtual;
      function HasZOrder: Boolean; virtual;

      { Defaults support }
      function GetRuntimeObjectClassID: String; virtual;

      procedure SendObjectToEdison(SendIt: Boolean; List: TStringList = Nil;
        Move: Boolean = False); virtual;
      procedure SendObjectAttrsToEdison(SendIt: Boolean; List: TStringList = Nil); virtual;
  End;

Implementation

Uses
    Error
  ;


Constructor TCircObj.Init;
Begin
  Inherited Init;
  If Not _InitVars_ Then Fail;
End;

Function TCircObj._InitVars_: Boolean;
Begin
  _InitVars_ := True;

  BDrawn := False;
  BUnDrawing:= False;
  BSelected := False;
  BDragging := False;
  wcUpLeftX := 0;
  wcUpLeftY := 0;
  wcDragBakUpLeftX := 0;
  wcDragBakUpLeftY := 0;
  FFlags := 0;
End;

Constructor  TCircObj.obssLoad( Var voStream: toOBSS;
                      wObjID, wObjVer: Word; liObjSize: LongInt );
Var fFailed: Boolean;
Begin
  Inherited Init;
  If Not _InitVars_ Then Fail;

  fFailed := False;
  If voStream.ErrorStatus = 0 Then
  Begin
    fFailed := obssReadData( voStream, wObjID, wObjVer, liObjSize );
  End;
  If fFailed Or (voStream.ErrorStatus <> 0) Then Fail;
End;

Function  TCircObj.obssReadData( Var voStream: toOBSS;
             wObjID, wObjVer: Word; liObjSize: LongInt ): Boolean;
var si: SmallInt;
Begin
  obssReadData := False; {Success}
  voStream.ReadObjectData( si, SizeOf({wcUpLeftX}SmallInt) ); wcUpLeftX := si;
  voStream.ReadObjectData( si, SizeOf({wcUpLeftX}SmallInt) ); wcUpLeftY := si;
End;

Procedure   TCircObj.obssSave( Var voStream: toOBSS;
                      wObjID, wObjVer: Word; liObjSize: LongInt );
var
  wID: Word;
Begin
  If voStream.ErrorStatus = 0 Then
  Begin
    wID := obssGetID;
    if wID > 0 then
    begin
      voStream.WriteNextObjectHeaderX( obssGetID,
                                       obssGetVer(voStream),
                                       obssGetSize(voStream) );
      obssWriteData( voStream );
    end;
  End;
End;

Function  TCircObj.obssGetID: Word;
Begin
  obssGetID := 0;
End;

Function  TCircObj.obssGetVer(voStream: toOBSS): Word;
Begin
  obssGetVer := 0;
End;

Function  TCircObj.obssGetSize(voStream: toOBSS): LongInt;
Begin
  Result := SizeOf( {wcUpLeftX}SmallInt ) +
            SizeOf( {wcUpLeftY}SmallInt );
End;

Procedure TCircObj.obssWriteData( Var voStream: toOBSS );
var si: SmallInt;
Begin
  If voStream.ErrorStatus = 0 Then
  Begin
    si := wcUpLeftX; voStream.WriteObjectData( si, SizeOf({wcUpLeftX}SmallInt) );
    si := wcUpLeftY; voStream.WriteObjectData( si, SizeOf({wcUpLeftX}SmallInt) );
  End;
End;

Function  TCircObj.CloneMe: PCircObj;
{ This method *MUST* be implemented in all classes. That's why the check
  is done in the first line. }
Var pNew: PCircObj;
Begin
{$IFNDEF Release}
  If TypeOf(Self) <> TypeOf(TCircObj) Then
    BetaError( '<PRE> TCircObj.CloneMe: Inherited.' );
{$ENDIF}
  pNew := New( PCircObj, Init );
  _CopyData( pNew );
  CloneMe := pNew;
End;

Procedure TCircObj._CopyData( pInto: PCircObj );
Begin
  pInto^.wcUpLeftX := wcUpLeftX;
  pInto^.wcUpLeftY := wcUpLeftY;
  pInto^.FFlags := FFlags;
{
      BDrawn: Boolean;
      BUnDrawing: Boolean;
      BSelected: Boolean;
      BDragging: Boolean;
      wcDragBakUpLeftX,
      wcDragBakUpLeftY: TWrldCoord;
}
End;

Procedure TCircObj.VRcWcGetBounds( pCnv: PTCanvas; Var vrcMe: TORect );
Begin
  vrcMe.Assign( wcUpLeftX, wcUpLeftY,
                wcUpLeftX+WcGetWidth(pCnv), wcUpLeftY+WcGetHeight(pCnv) );
End;

Function  TCircObj.WcGetWidth( pCnv: PTCanvas ): TWrldCoord;
Begin
  WriteLn('ABSTRACT:TCircObj.WcGetWidth');
  Abstract;
End;

Function  TCircObj.WcGetHeight( pCnv: PTCanvas ): TWrldCoord;
Begin
  WriteLn('ABSTRACT:TCircObj.WcGetHeight');
  Abstract;
End;

Procedure TCircObj.VRcWcGetRealBounds( pCnv: PTCanvas; Var vrcMe: TORect );
Begin
  VRcWcGetBounds(pCnv, vrcMe);
End;

Function  TCircObj.WcGetRealWidth( pCnv: PTCanvas ): TWrldCoord;
Begin
  Result := WcGetWidth(pCnv);
End;

Function  TCircObj.WcGetRealHeight( pCnv: PTCanvas ): TWrldCoord;
Begin
  Result := WcGetHeight(pCnv);
End;

Function  TCircObj.WcGetRealArea( pCnv: PTCanvas ): TWrldCoord;
Begin
  Result := WcGetWidth(pCnv) * WcGetHeight(pCnv);
End;

Function TCircObj.IsInRect(pCnv: PTCanvas; rcIn : TORect; NoLabel, AppendValueToLabel,
  AppendToleranceToLabel, AppendUnitToLabel: Boolean; Precision: ShortInt) : Boolean;
Var rcMe: TORect;
Begin
  VRcWcGetRealBounds( pCnv, rcMe );
  rcMe.Intersect( rcIn );
  If( rcMe.Empty ) Then IsInRect := False
                   Else IsInRect := True;
End;

Function TCircObj.IsFullyInRect( pCnv: PTCanvas; rcIn : TORect ) : Boolean;
Var rcMe: TORect;
Begin
  VRcWcGetRealBounds( pCnv, rcMe );
  rcIn.Intersect( rcMe );
  If( rcMe.Equals( rcIn ) ) Then IsFullyInRect := True
                            Else IsFullyInRect := False;
End;

Function TCircObj.HasCursor( pCnv: PTCanvas; wcX, wcY: TWrldCoord ) : Boolean;
Var rcMe: TORect;
    P: TOPoint;
Begin
  { This is a basic point-in-rect test. Should be detailed for
    each circuit object. }
  P.X := wcX; P.Y := wcY;
  VRcWcGetBounds( pCnv, rcMe );
  HasCursor := rcMe.Contains( P )
End;

{ Call this as the first statement in your own Draw }
Procedure TCircObj.Draw( pCnv: PTCanvas );
Begin
  If BDrawn Then UnDraw( pCnv );
  BDrawn := True;
End;

{ Call this as the last statement in your own UnDraw }
Procedure TCircObj.UnDraw( pCnv: PTCanvas );
Begin
  BDrawn := False;
{ would be nice - need to know the *bounding* rectangle...
  If (pCnv <> Nil) And Not BDragging Then
    pCnv^.Invalidate( wcUpLeftX-5, wcUpLeftY-5,
                      wcUpLeftX+WcGetWidth+5,
                      wcUpLeftY+WcGetHeight+5 );
}
End;


Procedure TCircObj.BeginDrag( pCnv: PTCanvas; idTracker: Integer );
Var fBakDrawn: Boolean;
Begin
  wcDragBakUpLeftX := wcUpLeftX;
  wcDragBakUpLeftY := wcUpLeftY;
  FidDragTracker := idTracker;
  fBakDrawn := BDrawn;
  If BDrawn Then UnDraw( pCnv );
  BDragging := True;
  TrackerBeginDrag( pCnv, idTracker );
  If fBakDrawn Then Draw( pCnv );
End;

Procedure TCircObj.Dragging( pCnv: PTCanvas; wcX, wcY : TWrldCoord );
Var fBakDrawn: Boolean;
Begin
  fBakDrawn := BDrawn;
  If BDrawn Then UnDraw( pCnv );
  TrackerDragging( pCnv, wcX, wcY );
{  MoveTo( pCnv, wcDragBakUpLeftX + wcX, wcDragBakUpLeftY + wcY );}
  If fBakDrawn Then Draw( pCnv );

  If Not BDrawn And Not gfSkipModalMouseMove Then Draw( pCnv ); {P941107-bug fix}
  gfSkipModalMouseMove := False;
End;

Procedure TCircObj.EndDrag( pCnv: PTCanvas; ARealDragFinished: Boolean );
Var
  fBakDrawn: Boolean;
Begin
  fBakDrawn := BDrawn;
  If BDrawn Then UnDraw( pCnv );
  BDragging := False;
  TrackerEndDrag( pCnv );
  If fBakDrawn Then Draw( pCnv );
End;

Procedure TCircObj.AbortDrag( pCnv: PTCanvas );
Var fBakDrawn: Boolean;
Begin
  fBakDrawn := BDrawn;
  If BDrawn Then UnDraw( pCnv );
  wcUpLeftX := wcDragBakUpLeftX;
  wcUpLeftY := wcDragBakUpLeftY;
  BDragging := False;
  TrackerAbortDrag( pCnv );
  If fBakDrawn Then Draw( pCnv );
End;


Procedure TCircObj.MoveTo( pCnv: PTCanvas; wcX, wcY : TWrldCoord );
Var BAux: Boolean;
Begin
  BAux := BDrawn;
  If BDrawn Then UnDraw( pCnv );

  wcUpLeftX := wcX;
  wcUpLeftY := wcY;

  If BAux Then Draw( pCnv );
End;

Procedure TCircObj.Mirror( pCnv: PTCanvas; BMirror: Boolean; ExternalCOR: Boolean;
  CORX, CORY: Integer );
begin
end;

Function TCircObj.GetClassID: Word;
Begin
  Result := $FFFF;
end;

Function TCircObj.EditAttributes( pCnv: PTCanvas ): Boolean;
Begin
  WriteLn('ABSTRACT:TCircObj.EditAttributes');
  Abstract;
End;

Function TCircObj.EditAttributesIsDblClick( pCnv: PTCanvas;
                                             bDoubleClick: Boolean ): Boolean;
Begin
  Result := EditAttributes(pCnv);
End;

{ Graph generation interface }
Function  TCircObj.ConsiderInGraph : Boolean;
Begin
  ConsiderInGraph := False;
End;

Function TCircObj.IsGraphable: Boolean;
Begin
  { True only for TGraphable and its children }
  IsGraphable := False;
End;

{ For the Canvas object only }
Procedure TCircObj._Render_( pCnv: PTCanvas );
Begin
End;

Procedure TCircObj.Select( pCnv: PTCanvas; fCheckLabel: Boolean );
Var fBakDrawn: Boolean;
Begin
  If BSelected Then Exit;
(*
{  Inc( pCurCircuit^.iSelectedCount );}
  BSelected := True;
  if BDrawn then
  begin
    BDrawn := False;
    Draw( pCnv );
  end;
{
*)
  fBakDrawn := BDrawn;
  If BDrawn Then UnDraw( pCnv );
  BSelected := True;
  If fBakDrawn Then Draw( pCnv );
{}
End;

Procedure TCircObj.UnSelect( pCnv: PTCanvas );
Var fBakDrawn: Boolean;
Begin
(*
  If Not BSelected Then Exit;
{  Dec( pCurCircuit^.iSelectedCount );}
  BSelected := False;
  if BDrawn then
  begin
    BDrawn := False;
    Draw( pCnv );
  end;
{
*)
  fBakDrawn := BDrawn;
  If BDrawn Then UnDraw( pCnv );
  BSelected := False;
  If fBakDrawn Then Draw( pCnv );
{}
End;

Function  TCircObj.IsSelected: Boolean;
Begin
  IsSelected := BSelected;
End;

Function  TCircObj.GetCaptionPrefix: String;
Begin
  Result := '';
End;

Function TCircObj.GetCursor( pCnv: PTCanvas; wcAtX, wcAtY: Integer ): TCursor;
Begin
  Result := crDefault;
  if BSelected then
  begin
    if TrackerGetID( pCnv, wcAtX, wcAtY ) > -1 then
      Result := crOverTracker;
  end;
End;

Function TCircObj.TrackerGetID( pCnv: PTCanvas; wcAtX, wcAtY: Integer ): Integer;
Var iLT: Integer;
    pt: TPoint;
Begin
  Result := -1;
  iLT := -1;

  If BSelected Then Begin
    iLT := -1;
    While TrackerGetNextPos( pCnv, iLT, pt ) Do Begin
      If PtInRect( Rect( pt.X-3, pt.Y-3, pt.X+4, pt.Y+4 ),
                 Point(wcAtX, wcAtY) ) Then Result := iLT+1;
      Inc(iLT);
    End;
  End;
End;

Function TCircObj.TrackerGetNextPos( pCnv: PTCanvas; ALastTracker: Integer;
  Var pt: TPoint ): Boolean;
Begin
  Result := False;
End;

Procedure TCircObj.TrackerBeginDrag( pCnv: PTCanvas; idTracker: Integer );
Begin
End;

Procedure TCircObj.TrackerDragging( pCnv: PTCanvas; wcX, wcY : TWrldCoord );
Begin
  if FidDragTracker = -1 then
    MoveTo( pCnv, wcDragBakUpLeftX + wcX, wcDragBakUpLeftY + wcY );
End;

Procedure TCircObj.TrackerEndDrag( pCnv: PTCanvas );
Begin
End;

Procedure TCircObj.TrackerAbortDrag( pCnv: PTCanvas );
Begin
End;

Procedure TCircObj.TrackerDraw( pCnv: PTCanvas; bUnDraw: Boolean );
Var iLT: Integer;
    pt: TPoint;
Begin
{$IFNDEF ISAPI}
  { Draw Trackers }
  If BSelected Then Begin
    iLT := -1;
    While TrackerGetNextPos( pCnv, iLT, pt ) Do Begin
      pCnv^.Tracker( pt.X, pt.Y, bUnDraw );
      Inc(iLT);
    End;
  End;
{$ENDIF}
End;

      { Undo/Redo support }
function TCircObj.undoGetData( eOpCode: TUROpCode ): Pointer;
begin
  Result := Nil;
end;

procedure TCircObj.undoReleaseData( eOpCode: TUROpCode; pData: Pointer );
begin
end;

procedure TCircObj.undoPerform( eOpCode: TUROpCode; pData: Pointer );
begin
end;

{ *** Link support ********************************************************** }

function TCircObj.HasLink: Boolean;
begin
  Result := False;
end;

procedure TCircObj.DoLink;
begin
  if not HasLink then Exit;
end;

function TCircObj.GetZOrder: Integer;
begin
  Result := 0;
end;

procedure TCircObj.SetZOrder(iNewZ: Integer);
begin
  //
end;

function TCircObj.HasZOrder: Boolean;
begin
  Result := False;
end;

function TCircObj.GetRuntimeObjectClassID: String;
begin
  Result := IntToHex(LONG_PTR(TypeOf(Self)), 8);
end;

procedure TCircObj.SendObjectToEdison(SendIt: Boolean; List: TStringList = Nil;
  Move: Boolean = False);
begin
end;

procedure TCircObj.SendObjectAttrsToEdison(SendIt: Boolean; List: TStringList = Nil);
begin
end;

End.
