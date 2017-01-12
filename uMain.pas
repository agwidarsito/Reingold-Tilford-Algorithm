unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, TeeGenericTree, Vcl.StdCtrls,
  Vcl.ExtCtrls, Math;

type NodeInformation = packed record
  Name: String;
  LocalX: Integer;
  Modv: Integer;
end;

type
  TForm1 = class(TForm)
    Button1: TButton;
    PaintBox: TPaintBox;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Draw(Tree: TNode<NodeInformation>);
  end;



var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure CheckForConflicts(Tree: TNode<NodeInformation>);
begin
end;

procedure CalculateFinalX(Tree: TNode<NodeInformation>; ModvSum: Integer);
var
  I: Integer;
begin
  Inc(Tree.Data.LocalX, ModvSum div 20);
  Inc(ModvSum, Tree.Data.Modv);

  if (Tree.Count > 0) then begin
    for I := 0 to Tree.Count-1 do begin
      CalculateFinalX(Tree[I], ModvSum);
    end;
  end;
end;

procedure CalculateInitialX(Tree: TNode<NodeInformation>);
const
  NodeSize = 1;
  SiblingDistance = 0;
var
  I, Mid: Integer;
  LeftChild, RightChild: TNode<NodeInformation>;
begin
  if (Tree.Count > 0) then begin
    for I := 0 to Tree.Count-1 do begin
      CalculateInitialX(Tree[I]);
    end;
  end;

  // If a leaf
  if (Tree.Count = 0) then begin
    if (Tree.Index > 0) then begin
      Tree.Data.LocalX := Tree.Parent[Tree.Index - 1].Data.LocalX + NodeSize + SiblingDistance;
    end else
      Tree.Data.LocalX := 0;
  end

  else if (Tree.Count = 1) then begin
    if (Tree.Index = 0) then begin
      Tree.Data.LocalX := Tree[0].Data.LocalX;
    end else begin
      Tree.Data.LocalX := Tree.Parent[Tree.Index - 1].Data.LocalX + NodeSize + SiblingDistance;
      Tree.Data.Modv := Tree.Data.LocalX - Tree.Parent[0].Data.LocalX;
    end;
  end

  else begin
    if (Tree.Level <> 0) then begin
      LeftChild := Tree.Parent[0];
      RightChild := Tree.Parent[Tree.Count - 1];
      Mid := (LeftChild.Data.LocalX + RightChild.Data.LocalX) div 2;

      if (Tree = LeftChild) then
        Tree.Data.LocalX := Mid
      else begin
        Tree.Data.LocalX := Tree.Parent[Tree.Index - 1].Data.LocalX + NodeSize + SiblingDistance;
        Tree.Data.Modv := Tree.Data.LocalX - Mid;
      end;
    end;
  end;

  if (Tree.Count > 0) and (Tree.Index <> 0) then begin
    CheckForConflicts(Tree);
  end;
end;

procedure TForm1.Draw(Tree: TNode<NodeInformation>);
var
  I: Integer;
  X, Y, pX, pY, Radius: Integer;
  Angle: Single;
begin
  Radius := 30;

  if Tree.Count > 0 then begin
    for I := 0 to Tree.Count - 1 do begin
      Draw(Tree[I]);
    end;
  end;

  X := Tree.Data.LocalX * 100 + 100;
  Y := Tree.Level * 100 + 100;
  PaintBox.Canvas.Ellipse(X - Radius, Y - Radius, X + Radius, Y + Radius);
  PaintBox.Canvas.TextOut(
    X - (PaintBox.Canvas.TextWidth(Tree.Data.Name) div 2),
    Y - (PaintBox.Canvas.TextHeight(Tree.Data.Name) div 2),
    Tree.Data.Name
  );

  if (Tree.Parent <> nil) then begin
    pX := Tree.Parent.Data.LocalX * 100 + 100;
    pY := Tree.Parent.Level * 100 + 100;

    PaintBox.Canvas.MoveTo(pX - Floor(Radius * Sin(Angle)), pY - Floor(Radius * Cos(Angle)));
    PaintBox.Canvas.LineTo(X - Floor(Radius * Sin(Angle)), Y - Floor(Radius * Cos(Angle)));
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  TreeA, TreeB: TNode<NodeInformation>;
  DataA, DataB, DataC, DataD, DataE: NodeInformation;
begin
  DataA.Name := 'Root';
  DataA.LocalX := 0;
  TreeA := TNode<NodeInformation>.Create(DataA);

  DataB.Name := 'Child A';
  DataB.LocalX := 0;
  TreeA.Add(DataB);

  DataC.Name := 'Child B';
  DataC.LocalX := 0;
  TreeB := TreeA.Add(DataC);

  DataD.Name := 'Child C';
  DataD.LocalX := 0;
  TreeB.Add(DataD);

  DataE.Name := 'Child D';
  DataE.LocalX := 0;
  TreeB.Add(DataE);

  CalculateInitialX(TreeA);
  //CalculateFinalX(TreeA, 0);

  Draw(TreeA);
end;

end.
