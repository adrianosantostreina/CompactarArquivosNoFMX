unit Unit1;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.ZLib,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Controls.Presentation,
  FMX.StdCtrls, MobilePermissions.Model.Signature,
  MobilePermissions.Model.Dangerous, MobilePermissions.Model.Standard,
  MobilePermissions.Component;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    MobilePermissions1: TMobilePermissions;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure ListarArquivosNoListBox(const pasta: string; listBox: TListBox);
    procedure CompactarArquivos(const arquivoCompactado: string;
      const arquivos: TArray<string>);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

procedure TForm1.ListarArquivosNoListBox(const pasta: string; listBox: TListBox);
var
  arquivos: TStringDynArray;
  arquivo: string;
begin
  listBox.Clear; // Limpa o ListBox antes de adicionar novos itens

  arquivos := TDirectory.GetFiles(pasta);

  for arquivo in arquivos do
    listBox.Items.Add(arquivo);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  arquivos: TArray<string>;
begin
  SetLength(arquivos, 3);

  arquivos[0] := TPath.Combine(TPath.GetDocumentsPath, 'arquivo1.txt');
  arquivos[1] := TPath.Combine(TPath.GetDocumentsPath, 'teste2.jpg');
  arquivos[2] := TPath.Combine(TPath.GetDocumentsPath, 'matteo1.jpeg');

  if FileExists(TPath.Combine(TPath.GetDocumentsPath, 'arquivo.zip')) then
    DeleteFile(TPath.Combine(TPath.GetDocumentsPath, 'arquivo.zip'));

  CompactarArquivos(TPath.Combine(TPath.GetDocumentsPath, 'arquivo.zip'), arquivos);

  ListarArquivosNoListBox(TPath.Combine(TPath.GetDocumentsPath), ListBox1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if FileExists(TPath.Combine(TPath.GetDocumentsPath, 'arquivo.zip')) then
    DeleteFile(TPath.Combine(TPath.GetDocumentsPath, 'arquivo.zip'));
  ListarArquivosNoListBox(TPath.Combine(TPath.GetDocumentsPath), ListBox1);
end;

procedure TForm1.CompactarArquivos(const arquivoCompactado: string; const arquivos: TArray<string>);
var
  zipStream: TFileStream;
  compressorStream: TCompressionStream;
  arquivo: string;
begin
  try
    zipStream := TFileStream.Create(arquivoCompactado, fmCreate);
    try
      compressorStream := TCompressionStream.Create(clMax, zipStream);
      try
        for arquivo in arquivos do
        begin
          compressorStream.CopyFrom(TFileStream.Create(arquivo, fmOpenRead), 0);
          compressorStream.Seek(0, soFromEnd); // Move o ponteiro para o final
        end;
      finally
        compressorStream.Free;
      end;

      ShowMessage('Compactação concluída com sucesso!');
    finally
      zipStream.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao compactar arquivos: ' + E.Message);
  end;
end;

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  MobilePermissions1.Dangerous.ReadExternalStorage := true;
  MobilePermissions1.Dangerous.WriteExternalStorage := true;
  MobilePermissions1.Apply;

  ListarArquivosNoListBox(TPath.Combine(TPath.GetDocumentsPath), ListBox1);
end;

end.
