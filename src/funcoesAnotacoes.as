// ActionScript file
import com.spiel.Anotacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.FocusEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.TextInput;
import mx.core.Application;
import mx.core.UITextField;
import mx.events.CloseEvent;
import mx.events.ListEvent;

[Bindable]
public var anotacaoSelecionada:Object;

public function salvarAnotacao():void
{	
	if (!Utils.validarInput(inputTituloAnotacao) || !Utils.validarInput(inputTextoAnotacao))
	{
		return;
	}
	
	var textoInputTituloAnotacao:String = inputTituloAnotacao.text;
	
	if (inputTituloAnotacao.text == "Insira aqui o título" && inputTituloAnotacao.getStyle("fontStyle") == "italic")
	{
		textoInputTituloAnotacao = "";
	}
	
	var textoInputTextoAnotacao:String = inputTextoAnotacao.text;
	
	if (inputTextoAnotacao.text == "Insira aqui o texto da anotação" && inputTextoAnotacao.getStyle("fontStyle") == "italic")
	{
		textoInputTextoAnotacao = "";
	}
	
	var anotacao:Anotacao;
	
	if (tabelaAnotacoes.selectedIndex == -1)
	{	
		anotacao = new Anotacao(	false, 
									textoInputTituloAnotacao, 
									textoInputTextoAnotacao, 
									Application.application.placaGatilhoAnotacaoNova, 
									Application.application.idMovimentacaoGatilhoAnotacaoNova
								);
		
		if (anotacao.registrar())
		{
			var d:String = Utils.dataFormatada(anotacao.getT()).substr(0, 10);
			var hora:String = Utils.dataFormatada(anotacao.getT()).substr(11, 8);
			mostrarCanvasMensagemGenerica("Anotação salva com sucesso.", hora, d);
		}
	}
	
	else
	{
		anotacao = new Anotacao(true, null, null, null, null);
		
		var timestamp:String = Utils.getStringInstanteDH(tabelaAnotacoes.selectedItem.dia.toString(), tabelaAnotacoes.selectedItem.hora.toString())
		anotacao.obterDados(timestamp);
		
		anotacao.setTexto(inputTextoAnotacao.text);
		anotacao.setTitulo(inputTituloAnotacao.text);
		
		if (anotacao.flush())
		{
			var dFlush:String = Utils.dataFormatada(anotacao.getT()).substr(0, 10);
			var horaFlush:String = Utils.dataFormatada(anotacao.getT()).substr(11, 8);
			mostrarCanvasMensagemGenerica("Anotação editada com sucesso.", horaFlush, dFlush);
		}
	}
	
	resetCamposAnotacoes();
	povoarTabelaAnotacoes();
}

public function povoarTabelaAnotacoes():void
{
	var dataProviderObtido:Array = new Array();
	//var anotacao:Object = new Object();

	var comandoObterDados:String =
			"SELECT * " + 
			"FROM ANOTACOES " + 
			"ORDER BY T DESC;"
			
	var tObtido:String;		
	var r:SQLResult;
	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	stmt.text = comandoObterDados;
	stmt.addEventListener(SQLEvent.RESULT, tratadoraObterDados);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterDadosErro);
	stmt.execute();
							
	function tratadoraObterDados(event:SQLEvent):void
	{
		r = stmt.getResult();
		
		if (r is Object && r.data is Object)
		{
			var i:Number;
			
			for (i = 0; i < r.data.length; i++)
			{
				var d:String = Utils.dataFormatada(r.data[i].T.toString());
				
				var anotacao:Object = new Object();
				anotacao.dia = d.substr(0, 10);
				anotacao.hora = d.substr(11, 8);
				anotacao.placa = (r.data[i].PLACA.toString() == "" ? "-" : r.data[i].PLACA.toString());
				anotacao.codigoDeEntrada = (r.data[i].ID_MOV.toString() == "-1" ? "-" : r.data[i].ID_MOV.toString());
				anotacao.titulo = (r.data[i].TITULO.toString() == "") ? "-" : r.data[i].TITULO.toString();
				anotacao.texto = r.data[i].TEXTO.toString();
				anotacao.previa = (String)(anotacao.texto).substr(0, 10);
				
				dataProviderObtido.push(anotacao);
			}
		}
		
		tabelaAnotacoes.dataProvider = dataProviderObtido;
	}
	
	function tratadoraObterDadosErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao povar tabela de anotações: " + event.error.details);
	}
}

public function prepararCamposAnotacoesEntrada(event:Event):void
{
	if 	(	(UITextField)(event.target).text == "Insira aqui o título" 
		&& 	(UITextField)(event.target).getStyle("fontStyle") == "italic"
		)
	{
		inputTituloAnotacao.setStyle("fontStyle", "normal");
		inputTituloAnotacao.text = "";
	}
	
	else if 	(	(UITextField)(event.target).text == "Insira aqui o texto da anotação" 
				&& 	(UITextField)(event.target).getStyle("fontStyle") == "italic"
				)
	{
		inputTextoAnotacao.setStyle("fontStyle", "normal")
		inputTextoAnotacao.text = "";
	}
}

public function prepararCamposAnotacoesSaida(event:FocusEvent):void
{
	if 	(	(UITextField)(event.target).text == "" 
		&&	(event.currentTarget) is TextInput
		)
	{
		inputTituloAnotacao.setStyle("fontStyle", "italic");
		inputTituloAnotacao.text = "Insira aqui o título";
	}
	
	else if 	(	(UITextField)(event.target).text == "" 
				&&	(event.currentTarget) is TextArea
				)
	{
		inputTextoAnotacao.setStyle("fontStyle", "italic");
		inputTextoAnotacao.text = "Insira aqui o texto da anotação";
	}
}

public function resetCamposAnotacoes():void
{
	inputTituloAnotacao.text = "Insira aqui o título";
	inputTituloAnotacao.setStyle("fontStyle", "italic");
	
	inputTextoAnotacao.text = "Insira aqui o texto da anotação";
	inputTextoAnotacao.setStyle("fontStyle", "italic");
	
	tabelaAnotacoes.selectedIndex = -1;
		
	botaoExcluirAnotacao.enabled = false;
	
	Application.application.indiceAnotacaoSelecionada = -1;
	
	limparPopupAnotacao();
	//botaoEditarGatilho.enabled = false;
}

public function mostrarAnotacao(event:ListEvent):void
{
	if (event.currentTarget.selectedItem.titulo.toString() != "-")
	{
		inputTituloAnotacao.clearStyle("fontStyle");
		inputTituloAnotacao.text = event.currentTarget.selectedItem.titulo.toString();
	}
	
	else
	{
		inputTituloAnotacao.setStyle("fontStyle", "italic");
		inputTituloAnotacao.text = "Insira aqui o título";
	}
	
	if (event.currentTarget.selectedItem.texto.toString() != "")
	{
		inputTextoAnotacao.clearStyle("fontStyle");
		inputTextoAnotacao.text = event.currentTarget.selectedItem.texto.toString();
	}
	
	else
	{
		inputTextoAnotacao.setStyle("fontStyle", "italic");
		inputTextoAnotacao.text = "Insira aqui o texto da anotação";
	}
	
	botaoExcluirAnotacao.enabled = true;
	botaoEditarGatilho.enabled = true;
	
	Application.application.anotacaoSelecionada = tabelaAnotacoes.selectedItem;
	Application.application.indiceAnotacaoSelecionada = tabelaAnotacoes.selectedIndex;
}

public function excluirAnotacao(event:CloseEvent):void
{
	
	if (event.detail == Alert.NO)
	{
		return;
	}
	
	var anotacao:Anotacao = new Anotacao(true, null, null, null, null);
	
	var timestamp:String = Utils.getStringInstanteDH(tabelaAnotacoes.selectedItem.dia.toString(), tabelaAnotacoes.selectedItem.hora.toString())
	anotacao.obterDados(timestamp);
	
	if (anotacao.deletar())
	{
		var d:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(0, 10);
		var hora:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(11, 8);
		mostrarCanvasMensagemGenerica("Anotação excluída com sucesso.", d, hora);
		
		botaoExcluirAnotacao.enabled = false;
		botaoEditarGatilho.enabled = false;
		
		resetCamposAnotacoes();
	}
		
	povoarTabelaAnotacoes();
}

public function excluirTodasAnotacoes(event:CloseEvent):void
{
	if (event.detail == Alert.NO)
	{
		return;
	}
	
	if (Anotacao.deletarAnotacoes())
	{
		var d:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(0, 10);
		var hora:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(11, 8);
		mostrarCanvasMensagemGenerica("Anotações excluídas com sucesso.", d, hora);
		
		botaoExcluirAnotacao.enabled = false;
		botaoEditarGatilho.enabled = false;
		
		resetCamposAnotacoes();
	}
		
	povoarTabelaAnotacoes();
}


public function confirmarExclusaoAnotacao(todasAnotacoes:Boolean):void
{
	var stringAlerta:String = (todasAnotacoes) 
								? "Tem certeza que deseja excluir todas as anotações?"
								: "Tem certeza que deseja excluir esta anotação?"
								;
								
	var stringAlertaTitulo:String = (todasAnotacoes) 
								? "Confirmação de exclusão das anotações"
								: "Confirmação de exclusão de anotação"
								;
	
	var handler:Function = (todasAnotacoes) ? excluirTodasAnotacoes : excluirAnotacao;
	
	Alert.show(stringAlerta, stringAlertaTitulo, Alert.YES|Alert.NO, null, handler);
}

public function popupAnotacao():void
{	
	if (Anotacao.getNroAnotacoesAssociadas(inputVeiculo.text) != 0)
	{
		if (!accordionAnotacoes.visible)
		{
			disparaEfeitoAccordionAnotacoes();
		}
			
		tabelaAnotacoes.styleFunction = funcaoEstiloDataGrid;
		tabelaAnotacoes.invalidateList();
		
		var d:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(0, 10);
		var hora:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(11, 8);
		var mensagem:String = 	"Uma ou mais anotações associadas " +
									(Veiculo.isPlaca(inputVeiculo.text)
										? "a esta placa "
										: "a este código de entrada "
									) +
								"encontradas (ver abaixo).";
								
		mostrarCanvasMensagemGenerica(mensagem, d, hora);
		var indicesSelecionados:ArrayCollection = new ArrayCollection(Anotacao.getIndicesAnotacoesAssociadas(inputVeiculo.text).sort());
		tabelaAnotacoes.selectedIndex = Number(indicesSelecionados.getItemAt(0));
		tabelaAnotacoes.dispatchEvent(new ListEvent(ListEvent.ITEM_CLICK));
	}	   
}

public function limparPopupAnotacao():void
{
	tabelaAnotacoes.styleFunction = funcaoEstiloDataGridLimpar;
	tabelaAnotacoes.invalidateList();
}

public function funcaoEstiloDataGrid(data:Object, col:AdvancedDataGridColumn):Object
{
	 if (data["placa"] == inputVeiculo.text || data["codigoDeEntrada"] == inputVeiculo.text)
	 	 
        return {fontWeight:"bold"}; 
    
    return null;
}

public function funcaoEstiloDataGridLimpar(data:Object, col:AdvancedDataGridColumn):Object
{   
    return null;
}   

public function mostrarJanelaEditarGatilhos():void
{
	Application.application.painelGatilhos = new PainelGatilhosAnotacoes();
	Application.application.painelGatilhos.setStyle("horizontalCenter", 0);
	Application.application.painelGatilhos.setStyle("verticalCenter", 0);
	Application.application.painelGatilhos.addEventListener(CloseEvent.CLOSE, fecharJanelaEditarGatilhos);
	Application.application.atualizacaoGatilho = false;
	Application.application.addChild(Application.application.painelGatilhos);
	desabilitarAplicacaoExceto(Application.application.painelGatilhos);
	Application.application.painelGatilhos.setFocus();
}

public function fecharJanelaEditarGatilhos(event:CloseEvent):void
{
	Application.application.removeChild(Application.application.painelGatilhos);
	habilitarAplicacao();
	povoarTabelaAnotacoes();
	//resetCamposAnotacoes();
	
	if (Application.application.atualizacaoGatilho && Application.application.indiceAnotacaoSelecionada != -1)
	{
		var d:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(0, 10);
		var hora:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(11, 8);
		mostrarCanvasMensagemGenerica("Gatilho para a anotação configurado com sucesso.", d, hora);
	}
}
