// ActionScript file

import com.spiel.Conexao;
import com.spiel.Cor;
import com.spiel.Marca;
import com.spiel.Modelo;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.controls.List;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;
import mx.managers.CursorManager;

include "funcoesApp.as";

[Bindable]
public var inputPlacaLength:Number = 0;

[Bindable]
public var validador:RegExpValidator;
[Bindable]
public var resultadoValidacao:ValidationResultEvent;

[Bindable]
public var isTabelaCheia:Boolean = false;

[Bindable]
public var timerMensagemSaidaPatio:Timer = new Timer(3500);

public function initPatio():void
{
	resetFiltros();
	escreverLabelNroVeiculos();	
	stepperTempoPatioMaxH.value = 1 + Application.application.maximoHorasNoEstacionamento;
	stepperIntervaloMaxH.value = 23;
	stepperIntervaloMaxM.value = 59;
	
	validador = new RegExpValidator();
	validador.noMatchError = "Placa inválida";
	validador.source = inputPlacaPatio;
	validador.required = false;
	validador.property = "text";
	validador.expression = "^[A-Z]{3} [0-9]{4}$";
}

public function escreverLabelNroVeiculos():void
{
	var nroVeiculosNoPatio:Number = Veiculo.nroVeiculosNoPatio();
	var nroVeiculosExibidos:Number = tabelaPatio.dataProvider.length;
	
	if (nroVeiculosExibidos == 0)
	{
		labelNroVeiculos.text = "Nenhum veículo no pátio correspondente às definições dos filtros.";
	}
	
	else 
	{
		labelNroVeiculos.text = "Mostrando " + 
		nroVeiculosExibidos.toString() + 
		" de " + 
		nroVeiculosNoPatio.toString() +
		((nroVeiculosNoPatio > 1) ? " veículos" : " veículo") +
		 " no pátio.";
	}
}

public function atualizarTabelaPatio():void
{
	
	// Estabelecendo a flag para tipo de cobrança
												
	var flagCobranca:Number = 0;
	
	if (	checkboxCobrancaNaEntradaPatio.selected
			&& checkboxCobrancaNaSaidaPatio.selected
			&& checkboxIsentosPatio.selected
		)
	{
		flagCobranca = 0;
	}
	
	else if (	checkboxCobrancaNaEntradaPatio.selected
			&& checkboxCobrancaNaSaidaPatio.selected
			&& !checkboxIsentosPatio.selected
		)
	{
		flagCobranca = 1;
	}
	
	else if (	checkboxCobrancaNaEntradaPatio.selected
				&& !checkboxCobrancaNaSaidaPatio.selected
				&& checkboxIsentosPatio.selected
			)
	{
		flagCobranca = 2;
	}
	
	else if (	!checkboxCobrancaNaEntradaPatio.selected
				&& checkboxCobrancaNaSaidaPatio.selected
				&& checkboxIsentosPatio.selected
			)
	{
		flagCobranca = 3;
	}
	
	else if (	checkboxCobrancaNaEntradaPatio.selected
				&& !checkboxCobrancaNaSaidaPatio.selected
				&& !checkboxIsentosPatio.selected
			)
	{
		flagCobranca = 4;
	}
	
	else if (	!checkboxCobrancaNaEntradaPatio.selected
				&& checkboxCobrancaNaSaidaPatio.selected
				&& !checkboxIsentosPatio.selected
			)
	{
		flagCobranca = 5;
	}
	
	else if (	!checkboxCobrancaNaEntradaPatio.selected
				&& !checkboxCobrancaNaSaidaPatio.selected
				&& checkboxIsentosPatio.selected
			)
	{
		flagCobranca = 6;
	}
	
	else if (	!checkboxCobrancaNaEntradaPatio.selected
				&& !checkboxCobrancaNaSaidaPatio.selected
				&& !checkboxIsentosPatio.selected
			)
	{
		flagCobranca = 7;
	}
	
	// Estabelecendo intervalo de horários
	
	var horarioInicioH:String = "";
	var horarioInicioM:String = "";
	var horarioTerminoH:String = "";
	var horarioTerminoM:String = "";
	
	if (checkboxIntervalo.selected)
	{
		horarioInicioH += (stepperIntervaloMinH.value < 10) ? "0" : "";
		horarioInicioH += stepperIntervaloMinH.value.toString();
		
		horarioInicioM += (stepperIntervaloMinM.value < 10) ? "0" : "";
		horarioInicioM += stepperIntervaloMinM.value.toString();
		
		horarioTerminoH += (stepperIntervaloMaxH.value < 10) ? "0" : "";
		horarioTerminoH += stepperIntervaloMaxH.value.toString();
		
		horarioTerminoM += (stepperIntervaloMaxM.value < 10) ? "0" : "";
		horarioTerminoM += stepperIntervaloMaxM.value.toString();
	}
	
	// Estabelecendo tempo no pátio
	
	var tempoPatioMinH:String = "";
	var tempoPatioMinM:String = "";
	
	if (checkboxTempoPatioMin.selected)
	{
		tempoPatioMinH = stepperTempoPatioMinH.value.toString();
		tempoPatioMinM = stepperTempoPatioMinM.value.toString();
	}
	
	var tempoPatioMaxH:String = "";
	var tempoPatioMaxM:String = "";
	
	if (checkboxTempoPatioMax.selected)
	{
		tempoPatioMaxH = stepperTempoPatioMaxH.value.toString();
		tempoPatioMaxM = stepperTempoPatioMaxM.value.toString();
	}
		
	if (inputPlacaPatio.text.length != 8 && inputPlacaPatio.text != "" && !isTabelaCheia)
	{	
		tabelaPatio.povoar(
				"",
				cbMarcaPatio.text, 
				cbModeloPatio.text, 
				cbCorPatio.text,
				horarioInicioH,
				horarioInicioM,
				horarioTerminoH,
				horarioTerminoM,
				tempoPatioMinH,
				tempoPatioMinM,
				tempoPatioMaxH,
				tempoPatioMaxM,
				flagCobranca
				);
				
			isTabelaCheia = true;
	}
	
	else if (inputPlacaPatio.text.length == 8 || inputPlacaPatio.text.length == 0) {	
		
		tabelaPatio.povoar(
			inputPlacaPatio.text,
			cbMarcaPatio.text, 
			cbModeloPatio.text, 
			cbCorPatio.text,
			horarioInicioH,
			horarioInicioM,
			horarioTerminoH,
			horarioTerminoM,
			tempoPatioMinH,
			tempoPatioMinM,
			tempoPatioMaxH,
			tempoPatioMaxM,
			flagCobranca
			);
		
		isTabelaCheia = false;
	}
	
	escreverLabelNroVeiculos();
}

public function resetFiltros():void
{
	inputPlacaPatio.text = "";
	cbMarcaPatio.dataProvider = Utils.adicionarOpcaoTodos(Marca.getNomesMarcas(), false);
	cbModeloPatio.dataProvider = Utils.adicionarOpcaoTodos(Modelo.getNomesModelos(), true);
	cbCorPatio.dataProvider = Utils.adicionarOpcaoTodos(Cor.getNomesCores(), false);
	
	checkboxTempoPatioMin.selected =
	checkboxTempoPatioMax.selected =
	checkboxIntervalo.selected = false;
	
	toggleTempoMaiorQue();
	toggleTempoMenorQue();
	toggleHorarios();
	
	checkboxCobrancaNaEntradaPatio.selected =
	checkboxCobrancaNaSaidaPatio.selected =
	checkboxIsentosPatio.selected = true;
	
	atualizarTabelaPatio();
}

public function toggleTempoMaiorQue():void
{
	stepperTempoPatioMinH.enabled = 
	stepperTempoPatioMinM.enabled = checkboxTempoPatioMin.selected;
}

public function toggleTempoMenorQue():void
{
	stepperTempoPatioMaxH.enabled = 
	stepperTempoPatioMaxM.enabled = checkboxTempoPatioMax.selected
}

public function toggleHorarios():void
{
	stepperIntervaloMaxH.enabled =
	stepperIntervaloMaxM.enabled =
	stepperIntervaloMinH.enabled =
	stepperIntervaloMinM.enabled = checkboxIntervalo.selected;
}

public function atualizarComboboxModelos():void
{
	if (cbMarcaPatio.text == "Todas")
	{
		cbModeloPatio.dataProvider = Utils.adicionarOpcaoTodos(Modelo.getNomesModelos(), true);
		return;
	}
	
	var marca:Marca = new Marca(true, null);
	marca.obterDados(cbMarcaPatio.text);
	cbModeloPatio.dataProvider = Utils.adicionarOpcaoTodos(marca.getNomesModelos(), true);
}

public function resolverInputPlacaPatio():void
{
	formatarTextoPlacaPatio();
	abrirSugestoesPlacaPatio(inputPlacaPatio, "VEICULOS", "PLACA", sugestoesPlacaPatio);
	
	if (validador.validate().type == ValidationResultEvent.VALID)
	{
		atualizarTabelaPatio();
	}
}

public function formatarTextoPlacaPatio():void
{	
	inputPlacaPatio.text = inputPlacaPatio.text.toUpperCase();
		
	var expColocarEspaco:RegExp = /^[A-Z]{3}$/;
	
	if (expColocarEspaco.test(inputPlacaPatio.text) && inputPlacaLength == 2)
	{
		inputPlacaPatio.text = inputPlacaPatio.text.substr(0, 3) + " " + inputPlacaPatio.text.substr(3, 1);
		inputPlacaPatio.setSelection(5, 5);
	}
	
	inputPlacaLength = inputPlacaPatio.text.length;
}

public function abrirSugestoesPlacaPatio(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
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
					
	var app:TelaPatio = this;				
	app.addEventListener(MouseEvent.CLICK, tratarClique);
	app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	
	var outputSugestoes:Array = new Array();
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	
	
	stmt.text = '' +
		'SELECT M.PLACA AS P ' +
		'FROM MOVIMENTACOES AS M ' +
		'WHERE P LIKE "' + textInput.text + '%" ' +
		'AND M.T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) ' + 
		'AND M.CODIGO = 1 ' + 
		'ORDER BY P;';
		
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAbrirSugestoes);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAbrirSugestoesErro);
	stmt.execute();
	stmt.sqlConnection.close();
							
	if (outputSugestoes.length == 1)
	{
		sugestoes.height = 22.5;
	}
		
	else
	{
		sugestoes.height = 48;
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

public function validarInputPlacaPatio(event:Event):void
{	
	atualizarTabelaPatio();	
}
