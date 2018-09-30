// ActionScript file

import com.spiel.Conexao;
import com.spiel.Cor;
import com.spiel.Marca;
import com.spiel.Modelo;
import com.spiel.Utils;
import com.spiel.Veiculo;

import mx.controls.Alert;
import mx.controls.Image;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;
import mx.managers.CursorManager;


[Bindable]
public var inputPlacaLength:Number = 0;

[Bindable]
public var validadorPlaca:RegExpValidator;

[Bindable]
public var validadorMovimentacao:RegExpValidator;

[Bindable]
public var isTabelaCheia:Boolean = false;

[Bindable]
public var dataProviderArrayStatus:Array = ["Dentro e fora do pátio", "No pátio", "Fora do pátio"];

[Bindable]
public var dataProviderArrayCredito:Array = ["Créd.: indiferente", "Créd.: igual a", "Créd.: maior que", "Créd.: menor que"];

[Bindable]
public var dataProviderArrayIsento:Array = ["Isentos e não isentos", "Isentos", "Não isentos"];

[Bindable]
public var painelEditarVeiculo:PainelEditarVeiculo;

public function resetFiltros():void
{
	CursorManager.removeBusyCursor();
	cbCorBusca.dataProvider = Utils.adicionarOpcaoTodosEspecifica(Cor.getNomesCores(), "cor");
	cbModeloBusca.dataProvider = Utils.adicionarOpcaoTodosEspecifica(Modelo.getNomesModelos(), "modelo");
	cbMarcaBusca.dataProvider = Utils.adicionarOpcaoTodosEspecifica(Marca.getNomesMarcas(), "marca");
	cbCreditoBusca.dataProvider = dataProviderArrayCredito;
	toggleStepperCredito();
	cbIsentoBusca.dataProvider = dataProviderArrayIsento;
	cbStatusBusca.dataProvider = dataProviderArrayStatus;
	toggleCodMovimentacao();
	
	inputPlacaBusca.text = "";
	inputMovimentacaoBusca.text = "";
	dFRegistroBusca.selectedDate = null;
	dFUltMovimentacaoBusca.selectedDate = null;
	
	atualizarTabelaBusca();
}

public function initBusca():void
{
	
	resetFiltros();
	escreverLabelNroVeiculos();
	
	botaoApagarRegistroBusca.enabled = false;
	botaoVisualizarDadosBusca.enabled = false;
	
	tabelaBusca.selectedItem = null;
	tabelaBusca.addEventListener(ListEvent.ITEM_CLICK, habilitarBotoes);
	
	validadorPlaca = new RegExpValidator();
	validadorPlaca.noMatchError = "Placa inválida";
	validadorPlaca.source = inputPlacaBusca;
	validadorPlaca.required = false;
	validadorPlaca.property = "text";
	validadorPlaca.expression = "^[A-Z]{3} [0-9]{4}$";
	
	validadorMovimentacao = new RegExpValidator();
	validadorMovimentacao.noMatchError = "Cód. de mov. inválido";
	validadorMovimentacao.source = inputMovimentacaoBusca;
	validadorMovimentacao.required = false;
	validadorMovimentacao.property = "text";
	validadorMovimentacao.expression = "^[0-9]+$";
}

public function habilitarBotoes(event:ListEvent):void
{
	botaoApagarRegistroBusca.enabled = 
	botaoVisualizarDadosBusca.enabled = true;
}

public function desabilitarBotoes():void
{
	botaoApagarRegistroBusca.enabled = 
	botaoVisualizarDadosBusca.enabled = false;
}

public function trataCliqueBotaoApagar():void
{
	var veiculo:Veiculo = new Veiculo();
	veiculo.obterDados(tabelaBusca.selectedItem.placa.toString());
	confirmarExclusaoVeiculo(veiculo);
}

public function trataCliqueBotaoEditar():void
{
	var veiculo:Veiculo = new Veiculo();
	veiculo.obterDados(tabelaBusca.selectedItem.placa.toString());
	mostrarPainelEditarVeiculo(veiculo.getPlaca());
}

public function confirmarExclusaoVeiculo(v:Veiculo):void
{
	Alert.show("Deseja realmente excluir este veículo e todos os dados associados (movimentações e anotações)?",
		v.getPlaca(),
		Alert.YES|Alert.NO,
		null,
		tratarConfirmarExclusao
		);
		
	function tratarConfirmarExclusao(event:CloseEvent):void
	{
		if (event.detail == Alert.YES)
		{
			v.remover();
			atualizarTabelaBusca();
			Application.application.atualizarEstatisticas();
			desabilitarBotoes();			
			Alert.show("Veículo excluído com sucesso.", "Veículo excluído");
		}
	}
}

public function atualizarComboboxBuscaModelos():void
{
	if (cbMarcaBusca.text == "Todas as marcas")
	{
		cbModeloBusca.dataProvider = Utils.adicionarOpcaoTodosEspecifica(Modelo.getNomesModelos(), "modelo");
		return;
	}
	
	var marca:Marca = new Marca(true, null);
	marca.obterDados(cbMarcaBusca.text);
	cbModeloBusca.dataProvider = Utils.adicionarOpcaoTodosEspecifica(marca.getNomesModelos(), "modelo");
}

public function toggleStepperCredito():void
{
	stepperCreditoBusca.enabled = (cbCreditoBusca.text != "Créd.: indiferente");
}

public function toggleCodMovimentacao():void
{
	inputMovimentacaoBusca.enabled = (cbStatusBusca.text != "Fora do pátio");
}

public function escreverLabelNroVeiculos():void
{
	var nroVeiculos:Number = Veiculo.nroVeiculos();
	var nroVeiculosExibidos:Number = tabelaBusca.dataProvider.length;
	
	if (nroVeiculosExibidos == 0)
	{
		textoNroVeiculosBusca.text = "Nenhum veículo correspondente às definições dos filtros.";
	}
	
	else 
	{
		textoNroVeiculosBusca.text = "Mostrando " + 
			nroVeiculosExibidos.toString() + 
			" de " + 
			nroVeiculos.toString() +
			((nroVeiculos > 1) ? " veículos registrados. " : " veículo registrado. ");
			
		textoNroVeiculosBusca.text += "Clique duas vezes sobre um registro para editá-lo.";
	}
}

public function atualizarTabelaBusca():void
{	

	if (inputPlacaBusca.text.length != 8 && inputPlacaBusca.text != "" && !isTabelaCheia)
	{	
		tabelaBusca.povoar(
				"",
				cbMarcaBusca.text, 
				cbModeloBusca.text, 
				cbCorBusca.text,
				cbStatusBusca.text,
				inputMovimentacaoBusca.text,
				dFRegistroBusca.selectedDate,
				dFUltMovimentacaoBusca.selectedDate,
				cbCreditoBusca.text,
				stepperCreditoBusca.value,
				cbIsentoBusca.text
				);
				
			isTabelaCheia = true;
	}
	
	else if (inputPlacaBusca.text.length == 8 || inputPlacaBusca.text.length == 0) {	
		
		tabelaBusca.povoar(
				inputPlacaBusca.text,
				cbMarcaBusca.text, 
				cbModeloBusca.text, 
				cbCorBusca.text,
				cbStatusBusca.text,
				inputMovimentacaoBusca.text,
				dFRegistroBusca.selectedDate,
				dFUltMovimentacaoBusca.selectedDate,
				cbCreditoBusca.text,
				stepperCreditoBusca.value,
				cbIsentoBusca.text
				);
		
		isTabelaCheia = false;
	}
	
	escreverLabelNroVeiculos();
}

public function resolverInputMovimentacaoBusca():void
{
	//formatarTextoPlacaBusca();
	abrirSugestoesMovimentacaoBusca(inputMovimentacaoBusca, "MOVIMENTACOES", "ID", sugestoesMovimentacaoBusca);
	
	if (validadorMovimentacao.validate().type == ValidationResultEvent.VALID)
	{
		atualizarTabelaBusca();
	}
}

public function resolverInputPlacaBusca():void
{
	formatarTextoPlacaBusca();
	abrirSugestoesPlacaBusca(inputPlacaBusca, "VEICULOS", "PLACA", sugestoesPlacaBusca);
	
	if (validadorPlaca.validate().type == ValidationResultEvent.VALID)
	{
		atualizarTabelaBusca();
	}
}

public function formatarTextoPlacaBusca():void
{	
	inputPlacaBusca.text = inputPlacaBusca.text.toUpperCase();
		
	var expColocarEspaco:RegExp = /^[A-Z]{3}$/;
	
	if (expColocarEspaco.test(inputPlacaBusca.text) && inputPlacaLength == 2)
	{
		inputPlacaBusca.text = inputPlacaBusca.text.substr(0, 3) + " " + inputPlacaBusca.text.substr(3, 1);
		inputPlacaBusca.setSelection(5, 5);
	}
	
	inputPlacaLength = inputPlacaBusca.text.length;
}


public function abrirSugestoesPlacaBusca(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
{	
	if 	(		textInput.text == "" 
		)
	{
		sugestoes.visible = false;
		return;
	}
	
	if (!sugestoes.hasEventListener(ListEvent.ITEM_CLICK))
	{
		sugestoes.addEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.addEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
	}
	
	textInput.addEventListener(KeyboardEvent.KEY_DOWN, rolarSugestoes);
					
	var app:TelaBusca = this;				
	app.addEventListener(MouseEvent.CLICK, tratarClique);
	app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	
	var outputSugestoes:Array = new Array();
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	
	
	stmt.text = '' +
		'SELECT M.PLACA AS P ' +
		'FROM VEICULOS AS M ' +
		'WHERE P LIKE "' + textInput.text + '%" ' +
		'ORDER BY P;';
		
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAbrirSugestoes);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAbrirSugestoesErro);
	stmt.execute();
	stmt.sqlConnection.close();
							
	if (outputSugestoes.length == 1)
	{
		sugestoes.height = 22.5;
	}
	
	else if (outputSugestoes.length == 2)
	{
		sugestoes.height = 48;
	}
		
	else
	{
		sugestoes.height = 55;
	}
						
	function tratadoraAbrirSugestoes(event:SQLEvent):void
	{
		// Responsável por povoar a List e exibi-la.
		
		r = stmt.getResult();					
		
		if (r.data is Object)
		{	
			outputSugestoes = new Array();
			
			for (var i:int = 0; i < r.data.length; i++)
		  	{
		    	outputSugestoes.push(r.data[i].P.toString());
		    }

		    sugestoes.dataProvider = outputSugestoes;
		    sugestoes.visible = !(outputSugestoes.length == 1 && outputSugestoes[0].toString() == textInput.text);					    		    		
		}
		
		else
		{
			sugestoes.visible = false;
			return;
		}
	}
	
	function tratadoraAbrirSugestoesErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao sugerir resultados para a caixa de texto: " + event.text);
	}
									
	function fecharSugestoes(event:Event):void
	{
		// Fecha a lista, adequando seu índice e o cursor, além de
		// lidar com event listeners que não são mais necessários.
		
		//Alert.show("fecharSugestoes()");
		
		sugestoes.visible = false;
		app.removeEventListener(MouseEvent.CLICK, tratarClique);
		app.removeEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
		sugestoes.removeEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.removeEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
		sugestoes.selectedIndex= -1;
		//textInput.setFocus();
		textInput.setSelection(textInput.text.length, textInput.text.length);
	}
	
	function capturarSugestao(event:Event):void
	{
		
		// Captura um clique de mouse ou teclada sobre a List
		// e exibe o resultado no textInput
		// Uma teclada com a seta direta volta o foco sobre
		// o textInput
		
		if (event is KeyboardEvent)
		{
			if ((KeyboardEvent)(event).keyCode == Keyboard.RIGHT)
			{
				fecharSugestoes(event);
			}
			
			else if ((KeyboardEvent)(event).keyCode == Keyboard.ENTER)
			{//Alert.show('==Keyboard.Enter');
				//rolarSugestoes(event);
			}
			
			else if ((KeyboardEvent)(event).keyCode == Keyboard.BACKSPACE)
			{
				textInput.text = textInput.text.substr(0, textInput.text.length - 2);
				fecharSugestoes(event);
				return;
			}
			
			else
			{
				return;
			}
		}
		
		try
		{
			textInput.text = event.currentTarget.selectedItem.toString();
			textInput.dispatchEvent(new Event(Event.CHANGE));
		}
		
		catch (e:Error)
		{
		}
		
		fecharSugestoes(event);		
	}
	
	function tratarClique(event:MouseEvent):void
	{				
		if 	(		!sugestoes.contains((DisplayObject)(event.target)) 
				&& 	!textInput.contains((DisplayObject)(event.target))
			)
		
			fecharSugestoes(event);
	}
	
	function tratarTeclada(event:KeyboardEvent):void
	{
		if (event.charCode == Keyboard.TAB)
		{
			fecharSugestoes(event);
		}
	}
	
	function rolarSugestoes(event:KeyboardEvent):void
	{
		if (!sugestoes.visible || event.keyCode != Keyboard.DOWN)
		{//Alert.show('1');
			//fecharSugestoes(event);
			return;
		}
		
		if (event.keyCode == Keyboard.DOWN)
		{//Alert.show('2');
			sugestoes.setFocus();
			sugestoes.selectedIndex = 0;
		}
		
		textInput.removeEventListener(KeyboardEvent.KEY_DOWN, rolarSugestoes);
	}
}

public function abrirSugestoesMovimentacaoBusca(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
{	
	if 	(		textInput.text == "" 
		)
	{
		sugestoes.visible = false;
		return;
	}
	
	if (!sugestoes.hasEventListener(ListEvent.ITEM_CLICK))
	{
		sugestoes.addEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.addEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
	}
	
	textInput.addEventListener(KeyboardEvent.KEY_DOWN, rolarSugestoes);
					
	var app:TelaBusca = this;				
	app.addEventListener(MouseEvent.CLICK, tratarClique);
	app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	
	var outputSugestoes:Array = new Array();
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	
	
	stmt.text = '' +
		'SELECT ID, PLACA AS P ' +
		'FROM MOVIMENTACOES ' +
		'WHERE ID LIKE "' + textInput.text + '%" ' + 
		'AND CODIGO = 1 ' + 
		'AND T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) ' +
		'ORDER BY P;';
		
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAbrirSugestoes);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAbrirSugestoesErro);
	stmt.execute();
	stmt.sqlConnection.close();
							
	if (outputSugestoes.length == 1)
	{
		sugestoes.height = 22.5;
	}
	
	else if (outputSugestoes.length == 2)
	{
		sugestoes.height = 48;
	}
		
	else
	{
		sugestoes.height = 55;
	}
						
	function tratadoraAbrirSugestoes(event:SQLEvent):void
	{
		// Responsável por povoar a List e exibi-la.
		
		r = stmt.getResult();					
		
		if (r.data is Object)
		{	
			outputSugestoes = new Array();
			
			for (var i:int = 0; i < r.data.length; i++)
		  	{
		    	outputSugestoes.push(r.data[i].ID.toString());
		    }

		    sugestoes.dataProvider = outputSugestoes;
		    sugestoes.visible = !(outputSugestoes.length == 1 && outputSugestoes[0].toString() == textInput.text);					    		    		
		}
		
		else
		{
			sugestoes.visible = false;
			return;
		}
	}
	
	function tratadoraAbrirSugestoesErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao sugerir resultados para a caixa de texto: " + event.text);
	}
									
	function fecharSugestoes(event:Event):void
	{
		// Fecha a lista, adequando seu índice e o cursor, além de
		// lidar com event listeners que não são mais necessários.
		
		//Alert.show("fecharSugestoes()");
		
		sugestoes.visible = false;
		app.removeEventListener(MouseEvent.CLICK, tratarClique);
		app.removeEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
		sugestoes.removeEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.removeEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
		sugestoes.selectedIndex= -1;
		//textInput.setFocus();
		textInput.setSelection(textInput.text.length, textInput.text.length);
	}
	
	function capturarSugestao(event:Event):void
	{
		
		// Captura um clique de mouse ou teclada sobre a List
		// e exibe o resultado no textInput
		// Uma teclada com a seta direta volta o foco sobre
		// o textInput
		
		if (event is KeyboardEvent)
		{
			if ((KeyboardEvent)(event).keyCode == Keyboard.RIGHT)
			{
				fecharSugestoes(event);
			}
			
			else if ((KeyboardEvent)(event).keyCode == Keyboard.ENTER)
			{//Alert.show('==Keyboard.Enter');
				//rolarSugestoes(event);
			}
			
			else if ((KeyboardEvent)(event).keyCode == Keyboard.BACKSPACE)
			{
				textInput.text = textInput.text.substr(0, textInput.text.length - 2);
				fecharSugestoes(event);
				return;
			}
			
			else
			{
				return;
			}
		}
		
		try
		{
			textInput.text = event.currentTarget.selectedItem.toString();
			textInput.dispatchEvent(new Event(Event.CHANGE));
		}
		
		catch (e:Error)
		{
		}
		
		fecharSugestoes(event);		
	}
	
	function tratarClique(event:MouseEvent):void
	{				
		if 	(		!sugestoes.contains((DisplayObject)(event.target)) 
				&& 	!textInput.contains((DisplayObject)(event.target))
			)
		
			fecharSugestoes(event);
	}
	
	function tratarTeclada(event:KeyboardEvent):void
	{
		if (event.charCode == Keyboard.TAB)
		{
			fecharSugestoes(event);
		}
	}
	
	function rolarSugestoes(event:KeyboardEvent):void
	{
		if (!sugestoes.visible || event.keyCode != Keyboard.DOWN)
		{//Alert.show('1');
			//fecharSugestoes(event);
			return;
		}
		
		if (event.keyCode == Keyboard.DOWN)
		{//Alert.show('2');
			sugestoes.setFocus();
			sugestoes.selectedIndex = 0;
		}
		
		textInput.removeEventListener(KeyboardEvent.KEY_DOWN, rolarSugestoes);
	}
}

public function mostrarPainelEditarVeiculo(placa:String):void
{
	painelEditarVeiculo = new PainelEditarVeiculo();
	painelEditarVeiculo.setStyle("horizontalCenter", 0);
	painelEditarVeiculo.setStyle("verticalCenter", 0);
						
	painelEditarVeiculo.addEventListener(CloseEvent.CLOSE, fecharPainelEditarVeiculo);
	
	Application.application.addChild(painelEditarVeiculo);
	painelEditarVeiculo.setFocus();
	painelEditarVeiculo.povoar(placa);		
	Application.application.desabilitarAplicacaoExceto(painelEditarVeiculo);
}

public function fecharPainelEditarVeiculo(event:CloseEvent):void
{
	Application.application.removeChild(painelEditarVeiculo);
	Application.application.habilitarAplicacao();
	atualizarTabelaBusca();
	desabilitarBotoes();	
}
