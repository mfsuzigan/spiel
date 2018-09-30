// ActionScript file
import com.spiel.Cor;

import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.controls.Label;
import mx.events.CloseEvent;

//include "funcoesTelaTransito.as";			

public function initCores(painelCores:PainelCores):void
{
	painelCores.setFocus();
	var children:Array = painelCores.getChildren();
	var idExaminado:String = ""; //Alert.show((children[0] is Grid).toString());
	
	for (var i:Number = 0; i < children.length; i++)
	{
		if (children[i] is Grid)
		{
			var childrenGrid:Array = (Grid)(children[i]).getChildren();
			
			for (var j:Number = 0; j < childrenGrid.length; j++)
			{
				var childrenGridRow:Array = (GridRow)(childrenGrid[j]).getChildren();			
				
				for (var k:Number = 0; k < childrenGridRow.length; k++)
				{
					idExaminado = (GridItem)(childrenGridRow[k]).id;
					
					if (idExaminado.substr(0, 2) != "GI")
					{
						var grid:GridItem = childrenGridRow[k];
						grid.setStyle("backgroundColor", toHex0x(grid.id));
					}	
				}
			}
		}
	}
}

public function toHexHash(nomeCor:String):String
{
	var codCor:String = Cor.getCodigo(nomeCor);
	
	return "#" + Number(codCor).toString(16);
}

public function toHex0x(nomeCor:String):String
{
	if (nomeCor == "Lilas") nomeCor = "Lilás";
	
	var codCor:String = Cor.getCodigo(nomeCor);
	
	return "0x" + Number(codCor).toString(16);
}

public function highlightGrid(event:MouseEvent):void
{
	var gridItem:GridItem = (GridItem) (event.currentTarget);
	gridItem.setStyle("borderStyle", "solid");
	gridItem.setStyle("borderThickness", "2");
	gridItem.setStyle("borderColor", 0x1c9af3);
	
	//var cor:String = identificarCor(event);
}

public function downlightGrid(event:MouseEvent):void
{
	var gridItem:GridItem = (GridItem) (event.currentTarget);
	gridItem.clearStyle("borderStyle");
	gridItem.clearStyle("borderThickness");
	gridItem.clearStyle("borderColor");
}

public function highlightGridBG(event:MouseEvent):void
{
	var gridItem:GridItem = (GridItem) (event.currentTarget);					
	var corBG:String = Cor.getNome(gridItem.getStyle("backgroundColor").toString());
	
	switch (corBG)
	{
		case "Prata":
		
			GIPrata.setStyle("borderStyle", "solid");
			GIPrata.setStyle("borderThickness", "2");
			GIPrata.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Preto":
		
			GIPreto.setStyle("borderStyle", "solid");
			GIPreto.setStyle("borderThickness", "2");
			GIPreto.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Branco":
		
			GIBranco.setStyle("borderStyle", "solid");
			GIBranco.setStyle("borderThickness", "2");
			GIBranco.setStyle("borderColor", 0x1c9af3);
			break;
		case "Cinza":
		
			GICinza.setStyle("borderStyle", "solid");
			GICinza.setStyle("borderThickness", "2");
			GICinza.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Vermelho":
		
			GIVermelho.setStyle("borderStyle", "solid");
			GIVermelho.setStyle("borderThickness", "2");
			GIVermelho.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Azul":
		
			GIAzul.setStyle("borderStyle", "solid");
			GIAzul.setStyle("borderThickness", "2");
			GIAzul.setStyle("borderColor", 0x1c9af3);
			break;
			
		case "Bege":
		
			GIBege.setStyle("borderStyle", "solid");
			GIBege.setStyle("borderThickness", "2");
			GIBege.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Marrom":
		
			GIMarrom.setStyle("borderStyle", "solid");
			GIMarrom.setStyle("borderThickness", "2");
			GIMarrom.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Verde":
		
			GIVerde.setStyle("borderStyle", "solid");
			GIVerde.setStyle("borderThickness", "2");
			GIVerde.setStyle("borderColor", 0x1c9af3);
			break;
		case "Amarelo":
		
			GIAmarelo.setStyle("borderStyle", "solid");
			GIAmarelo.setStyle("borderThickness", "2");
			GIAmarelo.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Ouro":
		
			GIOuro.setStyle("borderStyle", "solid");
			GIOuro.setStyle("borderThickness", "2");
			GIOuro.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Laranja":
		
			GILaranja.setStyle("borderStyle", "solid");
			GILaranja.setStyle("borderThickness", "2");
			GILaranja.setStyle("borderColor", 0x1c9af3);
			break;
			
		case "Rosa":
		
			GIRosa.setStyle("borderStyle", "solid");
			GIRosa.setStyle("borderThickness", "2");
			GIRosa.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Roxo":
		
			GIRoxo.setStyle("borderStyle", "solid");
			GIRoxo.setStyle("borderThickness", "2");
			GIRoxo.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Chumbo":
		
			GIChumbo.setStyle("borderStyle", "solid");
			GIChumbo.setStyle("borderThickness", "2");
			GIChumbo.setStyle("borderColor", 0x1c9af3);
			break;
			
		case "Urano":
		
			GIUrano.setStyle("borderStyle", "solid");
			GIUrano.setStyle("borderThickness", "2");
			GIUrano.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Vinho":
		
			GIVinho.setStyle("borderStyle", "solid");
			GIVinho.setStyle("borderThickness", "2");
			GIVinho.setStyle("borderColor", 0x1c9af3);
			break;
			
		case "Champanhe":
		
			GIChampanhe.setStyle("borderStyle", "solid");
			GIChampanhe.setStyle("borderThickness", "2");
			GIChampanhe.setStyle("borderColor", 0x1c9af3);
			break;
			
		case "Lilás":
		
			GILilas.setStyle("borderStyle", "solid");
			GILilas.setStyle("borderThickness", "2");
			GILilas.setStyle("borderColor", 0x1c9af3);
			break;
		
		case "Outra":
		
			GIOutra.setStyle("borderStyle", "solid");
			GIOutra.setStyle("borderThickness", "2");
			GIOutra.setStyle("borderColor", 0x1c9af3);
			break;
			
	}
	
}

public function downlightGridBG(event:MouseEvent):void
{
	var gridItem:GridItem = (GridItem) (event.currentTarget);					
	var corBG:String = Cor.getNome(gridItem.getStyle("backgroundColor").toString());
						
	switch (corBG)
	{
		case "Prata":
		
			GIPrata.clearStyle("borderStyle");
			GIPrata.clearStyle("borderThickness");
			GIPrata.clearStyle("borderColor");
			break;
		
		case "Preto":
		
			GIPreto.clearStyle("borderStyle");
			GIPreto.clearStyle("borderThickness");
			GIPreto.clearStyle("borderColor");
			break;
		
		case "Branco":
		
			GIBranco.clearStyle("borderStyle");
			GIBranco.clearStyle("borderThickness");
			GIBranco.clearStyle("borderColor");
			break;
		case "Cinza":
		
			GICinza.clearStyle("borderStyle");
			GICinza.clearStyle("borderThickness");
			GICinza.clearStyle("borderColor");
			break;
		
		case "Vermelho":
		
			GIVermelho.clearStyle("borderStyle");
			GIVermelho.clearStyle("borderThickness");
			GIVermelho.clearStyle("borderColor");
			break;
		
		case "Azul":
		
			GIAzul.clearStyle("borderStyle");
			GIAzul.clearStyle("borderThickness");
			GIAzul.clearStyle("borderColor");
			break;
		case "Bege":
		
			GIBege.clearStyle("borderStyle");
			GIBege.clearStyle("borderThickness");
			GIBege.clearStyle("borderColor");
			break;
		
		case "Marrom":
		
			GIMarrom.clearStyle("borderStyle");
			GIMarrom.clearStyle("borderThickness");
			GIMarrom.clearStyle("borderColor");
			break;
		
		case "Verde":
		
			GIVerde.clearStyle("borderStyle");
			GIVerde.clearStyle("borderThickness");
			GIVerde.clearStyle("borderColor");
			break;
		case "Amarelo":
		
			GIAmarelo.clearStyle("borderStyle");
			GIAmarelo.clearStyle("borderThickness");
			GIAmarelo.clearStyle("borderColor");
			break;
		
		case "Ouro":
		
			GIOuro.clearStyle("borderStyle");
			GIOuro.clearStyle("borderThickness");
			GIOuro.clearStyle("borderColor");
			break;
		
		case "Laranja":
		
			GILaranja.clearStyle("borderStyle");
			GILaranja.clearStyle("borderThickness");
			GILaranja.clearStyle("borderColor");
			break;
		case "Rosa":
		
			GIRosa.clearStyle("borderStyle");
			GIRosa.clearStyle("borderThickness");
			GIRosa.clearStyle("borderColor");
			break;
		
		case "Roxo":
		
			GIRoxo.clearStyle("borderStyle");
			GIRoxo.clearStyle("borderThickness");
			GIRoxo.clearStyle("borderColor");
			break;
		
		case "Chumbo":
		
			GIChumbo.clearStyle("borderStyle");
			GIChumbo.clearStyle("borderThickness");
			GIChumbo.clearStyle("borderColor");
			break;
		case "Urano":
		
			GIUrano.clearStyle("borderStyle");
			GIUrano.clearStyle("borderThickness");
			GIUrano.clearStyle("borderColor");
			break;
		
		case "Vinho":
		
			GIVinho.clearStyle("borderStyle");
			GIVinho.clearStyle("borderThickness");
			GIVinho.clearStyle("borderColor");
			break;
			
		case "Champanhe":
		
			GIChampanhe.clearStyle("borderStyle");
			GIChampanhe.clearStyle("borderThickness");
			GIChampanhe.clearStyle("borderColor");
			break;
			
		case "Lilás":
		
			GILilas.clearStyle("borderStyle");
			GILilas.clearStyle("borderThickness");
			GILilas.clearStyle("borderColor");
			break;
		
		case "Outra":
		
			GIOutra.clearStyle("borderStyle");
			GIOutra.clearStyle("borderThickness");
			GIOutra.clearStyle("borderColor");
			break;
			
	}
}

[Bindable]
public var corSelecionada:String = "";

public function selecionarCor(event:MouseEvent):void
{
	var corSelec:String;
	
	if ((GridItem)(event.currentTarget).getChildren().length != 0)
	{
		var labelCor:Label = (Label)((DisplayObject)(event.currentTarget).getChildAt(0));
		corSelec = (labelCor.text == "!") ? (GridItem)(event.currentTarget).id : labelCor.text;
	}
		
	else
	{
		corSelec = (GridItem)(event.currentTarget).id;
		if (corSelec == "Lilas") corSelec = "Lilás";
	}
	
	corSelecionada = corSelec;					
	this.dispatchEvent(new CloseEvent(Event.CLOSE));
}
				